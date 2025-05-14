# tool/upload_plans_to_firestore.py
import os
import json
from google.cloud import firestore # Ensure: pip install google-cloud-firestore

# --- CONFIGURATION ---
# 1. Your Firebase Project ID
FIREBASE_PROJECT_ID = 'wwjd-459421'  # Verify this matches your project

# 2. Path to the directory containing your individual reading plan JSON files.
#    This path is relative to the project root (where you'll run the script from).
PLANS_JSON_DIR_RELATIVE_PATH = os.path.join('assets', 'reading_plans_uploaded_to_database_not_local')

# 3. The name of the Firestore collection
FIRESTORE_COLLECTION_NAME = 'reading_plans'
# --- END CONFIGURATION ---

def upload_plans():
    # Initialize Firestore client.
    # It will use Application Default Credentials if you've run 'gcloud auth application-default login'.
    try:
        db = firestore.Client(project=FIREBASE_PROJECT_ID)
        print(f"Successfully initialized Firestore client for project: {FIREBASE_PROJECT_ID}")
    except Exception as e:
        print(f"Error initializing Firestore client: {e}")
        print("Please ensure:")
        print("1. You have run 'pip install google-cloud-firestore'.")
        print("2. You have authenticated via 'gcloud auth application-default login'.")
        print("3. The project ID '{FIREBASE_PROJECT_ID}' is correct and has Firestore (Native mode) enabled.")
        return

    # Determine the absolute path to the JSON files directory.
    # Assumes this script is run with the project root as the current working directory.
    project_root = os.getcwd() # This will be S:\Code\wwjd\wwjd if you run from there
    plans_directory_path = os.path.join(project_root, PLANS_JSON_DIR_RELATIVE_PATH)

    if not os.path.isdir(plans_directory_path):
        print(f"Error: Directory with JSON plans not found at '{plans_directory_path}'")
        print("Please check the PLANS_JSON_DIR_RELATIVE_PATH variable in this script.")
        return
    print(f"Scanning for JSON plan files in: {plans_directory_path}")

    success_count = 0
    error_count = 0
    skipped_count = 0
    batch_commit_size = 0
    batch = db.batch()

    for filename in os.listdir(plans_directory_path):
        if filename.endswith(".json"):
            file_path = os.path.join(plans_directory_path, filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    plan_data = json.load(f)

                if not isinstance(plan_data, dict):
                    print(f"Warning: Content of {filename} is not a JSON object. Skipping.")
                    skipped_count += 1
                    continue

                plan_id = plan_data.get('id')
                if not plan_id:
                    print(f"Warning: Plan data in {filename} is missing an 'id' field. Skipping.")
                    skipped_count += 1
                    continue

                doc_ref = db.collection(FIRESTORE_COLLECTION_NAME).document(plan_id)
                batch.set(doc_ref, plan_data)
                batch_commit_size += 1
                print(f"Added to batch: {filename} (Document ID: {plan_id})")

                if batch_commit_size >= 490: # Commit in chunks
                    print(f"Committing batch of {batch_commit_size} plans...")
                    batch.commit()
                    print("Batch committed.")
                    batch = db.batch() # Reset for next batch
                    batch_commit_size = 0

                success_count +=1 # Count as success for adding to batch

            except json.JSONDecodeError as e:
                print(f"Error decoding JSON from file {filename}: {e}")
                error_count += 1
            except Exception as e:
                print(f"Error processing or batching file {filename}: {e}")
                error_count += 1

    # Commit any remaining items in the last batch
    if batch_commit_size > 0:
        print(f"Committing final batch of {batch_commit_size} plans...")
        try:
            batch.commit()
            print("Final batch committed.")
        except Exception as e:
            print(f"Error committing final batch: {e}")
            error_count += batch_commit_size # These were not successful
            success_count -= batch_commit_size


    print(f"\n--- Upload Summary ---")
    print(f"Successfully uploaded (or batched for upload): {success_count} plans.")
    if error_count > 0:
        print(f"Errors encountered for: {error_count} plans.")
    if skipped_count > 0:
        print(f"Skipped files (not JSON or missing ID): {skipped_count}.")
    print(f"Check your Firestore console for the '{FIRESTORE_COLLECTION_NAME}' collection in project '{FIREBASE_PROJECT_ID}'.")

if __name__ == '__main__':
    print("Starting reading plan upload script...")
    print(f"Current working directory: {os.getcwd()}")
    print("Make sure you are running this script from your Flutter project's root directory (e.g., S:\\Code\\wwjd\\wwjd).")
    upload_plans()