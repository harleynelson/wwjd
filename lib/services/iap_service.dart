// File: lib/services/iap_service.dart
// Path: lib/services/iap_service.dart
// Updated: Corrected IAPError instantiation in _onPurchaseUpdate to use a String for source.

import 'dart:async';
import 'dart:io'; // For Platform.isIOS etc.
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; 

// iOS specific imports
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart'; 
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart'; 

import '../config/iap_constants.dart'; 
import 'auth_service.dart'; 

typedef PremiumStatusUpdatedCallback = void Function(bool isPremium);

class IAPService with ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  
  List<ProductDetails> _products = [];
  bool _isStoreAvailable = false;
  bool _isLoadingProducts = false;
  bool _isPurchasing = false; 

  AuthService? _authService; 
  PremiumStatusUpdatedCallback? _onPremiumStatusUpdated;

  List<ProductDetails> get products => _products;
  bool get isStoreAvailable => _isStoreAvailable;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isPurchasing => _isPurchasing;

  IAPService() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _purchaseSubscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () {
        _purchaseSubscription?.cancel();
      },
      onError: (error) {
        print("IAPService: Purchase stream error: $error");
      },
    );
    initializeIAP();
  }

  void setAuthService(AuthService authService, PremiumStatusUpdatedCallback onPremiumStatusUpdated) {
    _authService = authService;
    _onPremiumStatusUpdated = onPremiumStatusUpdated;
  }

  Future<void> initializeIAP() async {
    _isStoreAvailable = await _iap.isAvailable();
    print("IAPService: Store available: $_isStoreAvailable");

    if (_isStoreAvailable) {
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      }
      
      await loadProducts();
      await restorePurchases(); 
    }
    notifyListeners();
  }

  Future<void> loadProducts() async {
    if (!_isStoreAvailable) {
      print("IAPService: Store not available, cannot load products.");
      return;
    }
    _isLoadingProducts = true;
    notifyListeners();

    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(kProductIds);
      if (response.error != null) {
        print('IAPService: Error loading products: ${response.error?.code} - ${response.error?.message}');
        _products = [];
      } else {
        _products = response.productDetails;
        print("IAPService: Loaded ${_products.length} products.");
        for (var p in _products) {
          print(" - ID: ${p.id}, Title: ${p.title}, Price: ${p.price}");
        }
      }
    } catch (e) {
      print("IAPService: Exception loading products: $e");
      _products = [];
    }

    _isLoadingProducts = false;
    notifyListeners();
  }

  Future<void> buyProduct(ProductDetails productDetails) async {
    if (!_isStoreAvailable) {
      _showErrorDialog("Store not available. Please try again later.");
      return;
    }
    if (_isPurchasing) {
      print("IAPService: Purchase already in progress for another item.");
      return;
    }

    _isPurchasing = true;
    notifyListeners();

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print("IAPService: Error initiating purchase for ${productDetails.id}: $e");
      _showErrorDialog("Could not initiate purchase. Please try again. Error: ${e.toString()}");
      _isPurchasing = false; 
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    if (!_isStoreAvailable) {
      print("IAPService: Store not available for restoring purchases.");
      return;
    }
    print("IAPService: Attempting to restore purchases...");
    try {
      await _iap.restorePurchases();
      print("IAPService: Restore purchases call initiated. Listening for updates.");
    } catch (e) {
      print("IAPService: Error restoring purchases: $e");
       _showErrorDialog("Could not restore purchases. Error: ${e.toString()}");
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    print("IAPService: Purchase update received. Count: ${purchaseDetailsList.length}");
    bool purchaseFlowActive = _isPurchasing; 

    for (var purchaseDetails in purchaseDetailsList) {
      print("IAPService: Processing purchase ID: ${purchaseDetails.productID}, Status: ${purchaseDetails.status}");
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("IAPService: Purchase pending: ${purchaseDetails.productID}");
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("IAPService: Purchase error for ${purchaseDetails.productID}: ${purchaseDetails.error?.message}");
          _handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          print("IAPService: Purchase successful or restored: ${purchaseDetails.productID}");
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _deliverPurchase(purchaseDetails);
          } else {
            print("IAPService: Purchase verification failed: ${purchaseDetails.productID}");
            // --- CORRECTED LINE: Using a String for 'source' ---
            _handleError(IAPError(
                source: "App.Verification", // Changed from PurchaseSource.unknown
                code: "VERIFICATION_FAILED", 
                message: "Purchase verification failed. Please contact support."
            ));
            // --- END CORRECTION ---
          }
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
            try {
                await _iap.completePurchase(purchaseDetails);
                print("IAPService: Purchase completed with store: ${purchaseDetails.productID}");
            } catch (e) {
                print("IAPService: Error completing purchase ${purchaseDetails.productID} with store: $e");
            }
        }
      }
    }
    
    if (purchaseFlowActive && !purchaseDetailsList.any((pd) => pd.status == PurchaseStatus.pending)) {
        _isPurchasing = false;
    }
    notifyListeners();
  }
  
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    print("IAPService: Verifying purchase for ${purchaseDetails.productID}");
    if (purchaseDetails.verificationData.serverVerificationData.isEmpty) {
        print("IAPService: WARNING - No serverVerificationData found for ${purchaseDetails.productID}. Cannot securely verify.");
        return false; 
    }
    print("IAPService: Placeholder for server-side verification. Assuming valid if serverVerificationData exists.");
    return true; 
  }

  Future<void> _deliverPurchase(PurchaseDetails purchaseDetails) async {
    print("IAPService: Delivering purchase for ${purchaseDetails.productID}");
    if (purchaseDetails.productID == kProductIdPremiumUnlock) {
      print("IAPService: Granting premium access for ${kProductIdPremiumUnlock}.");
      if (_authService != null) {
          await _authService!.updateUserPremiumStatus(true); 
          _onPremiumStatusUpdated?.call(true); 
          print("IAPService: Premium status update triggered in AuthService and via callback.");
      } else {
          print("IAPService: AuthService is null. Cannot update premium status via AuthService.");
      }
    }
    notifyListeners(); 
  }

  void _handleError(IAPError? error) {
    if (error != null) {
      print("IAPService: Purchase Error - Code: ${error.code}, Source: ${error.source}, Message: ${error.message}");
      _showErrorDialog("Purchase failed: ${error.message} (Code: ${error.code}, Source: ${error.source})");
    }
    if (_isPurchasing) { 
        _isPurchasing = false;
    }
    notifyListeners();
  }
  
  void _showErrorDialog(String message) {
    print("IAPService UI ERROR: $message");
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    print("IAPService iOS Delegate: shouldContinueTransaction for ${transaction.payment.productIdentifier}");
    return true; 
  }

  @override
  bool shouldShowPriceConsent() {
    print("IAPService iOS Delegate: shouldShowPriceConsent");
    return false; 
  }
}

