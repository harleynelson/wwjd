// File: lib/widgets/prayer_form.dart
// Purpose: A reusable form widget for submitting a prayer request.

import 'package:flutter/material.dart';

class PrayerForm extends StatefulWidget {
  // Callback function triggered when the form is submitted with valid data.
  // Passes the prayer text and optional location approximation.
  final Function(String prayerText, String? locationApproximation) onSubmit;
  final bool isLoading; // Flag to indicate if a submission is in progress.

  const PrayerForm({
    Key? key,
    required this.onSubmit,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<PrayerForm> createState() => _PrayerFormState();
}

class _PrayerFormState extends State<PrayerForm> {
  final _formKey = GlobalKey<FormState>(); // Key to manage form state and validation.
  final _prayerTextController = TextEditingController(); // Controller for the prayer text input.
  String? _selectedLocation; // Currently selected location approximation.

  // Example list of locations for the dropdown.
  // This could be fetched from a configuration or be a static list.
  final List<String> _locations = [
    'Global', // Represents no specific region / worldwide.
    'North America',
    'South America',
    'Europe',
    'Asia',
    'Africa',
    'Oceania'
  ];

  @override
  void dispose() {
    _prayerTextController.dispose(); // Dispose the controller when the widget is removed.
    super.dispose();
  }

  // Handles form submission. Validates the form and calls the onSubmit callback.
  void _trySubmitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus(); // Dismiss keyboard.

    if (isValid) {
      widget.onSubmit(
        _prayerTextController.text.trim(),
        // Send null for location if "Global" is selected, otherwise send the selected location.
        (_selectedLocation == 'Global' || _selectedLocation == null) ? null : _selectedLocation,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Make children take full width.
          mainAxisSize: MainAxisSize.min, // Column takes minimum vertical space.
          children: <Widget>[
            Text(
              'Share Your Prayer Request',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Text field for entering the prayer.
            TextFormField(
              controller: _prayerTextController,
              decoration: InputDecoration(
                labelText: 'Prayer Request',
                hintText: 'Enter your prayer here (e.g., "Pray for peace and healing for my family.")',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true, // Aligns label with hint when text field is empty.
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 5, // Allows multiple lines for longer prayers.
              maxLength: 500, // Maximum character length for a prayer.
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Prayer request cannot be empty.';
                }
                if (value.trim().length < 10) {
                  return 'Please enter at least 10 characters for your prayer.';
                }
                // Add profanity check here if doing client-side (less secure)
                return null; // Return null if valid.
              },
            ),
            const SizedBox(height: 16),
            // Dropdown for selecting an optional general region.
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Optional: Share General Region',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              ),
              value: _selectedLocation,
              hint: const Text('Select a region (optional)'),
              isExpanded: true, // Makes the dropdown take full width.
              items: _locations.map((String location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLocation = newValue;
                });
              },
              // No validator needed for an optional field.
            ),
            const SizedBox(height: 24),
            // Show loading indicator or submit button based on isLoading state.
            if (widget.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit Prayer Anonymously'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: _trySubmitForm,
              ),
            const SizedBox(height: 12),
            Text(
              'Your prayer will be submitted anonymously. Our team will review it before it appears on the Prayer Wall.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
