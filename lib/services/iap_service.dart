// File: lib/services/iap_service.dart
// Path: lib/services/iap_service.dart
// Updated: Overhaul to match Huedoku implementation with robust error handling (Already Owned) and silent restore.

import 'dart:async';
import 'dart:io'; 
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; 
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart'; 
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart'; 

import '../config/iap_constants.dart'; 
import 'auth_service.dart'; 

// Callback typedef kept for backward compatibility if needed, though we primarily use AuthService now
typedef PremiumStatusUpdatedCallback = void Function(bool isPremium);

class IAPService with ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  
  List<ProductDetails> _products = [];
  bool _isStoreAvailable = false;
  bool _isLoading = false;
  String? _error;

  // Dependencies
  AuthService? _authService; 
  PremiumStatusUpdatedCallback? _onPremiumStatusUpdated;

  // Getters
  List<ProductDetails> get products => _products;
  bool get isStoreAvailable => _isStoreAvailable;
  bool get isLoading => _isLoading;
  String? get error => _error;

  IAPService() {
    // We call init immediately to maintain behavior with main.dart
    init();
  }

  void setAuthService(AuthService authService, PremiumStatusUpdatedCallback onPremiumStatusUpdated) {
    _authService = authService;
    _onPremiumStatusUpdated = onPremiumStatusUpdated;
    if (kDebugMode) print("IAPService: AuthService linked.");
  }

  /// Main initialization method
  Future<void> init() async {
    if (kDebugMode) print("IAPService: Initializing...");
    _setError(null, notify: false);
    _isLoading = true;
    notifyListeners();

    try {
      _isStoreAvailable = await _iap.isAvailable();
      if (!_isStoreAvailable) {
        if (kDebugMode) print("IAPService: Store not available.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      }

      _purchaseSubscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () {
          if (kDebugMode) print("IAPService: Purchase stream 'onDone'.");
          _purchaseSubscription?.cancel();
        },
        onError: (error) {
          if (kDebugMode) print("IAPService: Purchase stream 'onError': $error");
          _setError("Purchase stream error: $error");
        },
      );

      await loadProducts();

      // --- Silent Restore for Android ---
      // Syncs Play Store cache with app state (crucial for promo codes or reinstalls)
      if (Platform.isAndroid) {
         if (kDebugMode) print("IAPService: Android detected. Attempting silent restore...");
         await _iap.restorePurchases();
      }

    } catch (e) {
      if (kDebugMode) print("IAPService: Initialization Error: $e");
      _setError(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    if (kDebugMode) print("IAPService: Loading products...");
    
    // Using kProductIds from config/iap_constants.dart
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(kProductIds);

      if (response.error != null) {
        if (kDebugMode) print('IAPService: Error loading products: ${response.error?.message}');
        _setError("Failed to load products: ${response.error?.message}");
        _products = [];
      } else {
        _products = response.productDetails;
        if (kDebugMode) {
          print("IAPService: Loaded ${_products.length} products.");
          for (var p in _products) {
            print(" - ID: ${p.id}, Title: ${p.title}, Price: ${p.price}");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("IAPService: Exception loading products: $e");
      _setError("Exception loading products: $e");
      _products = [];
    }
    notifyListeners();
  }

  /// Buy the premium unlock
  Future<void> buyProduct(ProductDetails productDetails) async {
    if (!_isStoreAvailable) {
      _setError("Store not available. Please try again later.");
      return;
    }
    
    _setError(null); // Clear previous errors
    _isLoading = true; // Show loading state if UI observes it
    notifyListeners();

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    if (kDebugMode) print("IAPService: Initiating purchase for ${productDetails.id}...");

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      // The result comes via the stream
    } catch (e) {
      if (kDebugMode) print("IAPService: Error initiating purchase: $e");
      _setError("Could not initiate purchase: ${e.toString()}");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    if (!_isStoreAvailable) {
      _setError("Store not available for restoring purchases.");
      return;
    }
    if (kDebugMode) print("IAPService: Attempting to restore purchases manually...");
    _setError(null);
    
    try {
      await _iap.restorePurchases();
      if (kDebugMode) print("IAPService: Restore initiated.");
    } catch (e) {
      if (kDebugMode) print("IAPService: Error restoring purchases: $e");
       _setError("Could not restore purchases: ${e.toString()}");
    }
  }

  /// iOS Only: Presents the native code redemption sheet.
  Future<void> presentCodeRedemptionSheet() async {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.presentCodeRedemptionSheet();
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    if (kDebugMode) print("IAPService: Received ${purchaseDetailsList.length} purchase update(s).");
    
    for (var purchaseDetails in purchaseDetailsList) {
      if (kDebugMode) print("IAPService: Processing ID: ${purchaseDetails.productID}, Status: ${purchaseDetails.status}");
      
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          if (kDebugMode) print("IAPService: Purchase pending...");
          // Ensure UI knows we are waiting
          break;

        case PurchaseStatus.error:
          if (kDebugMode) print("IAPService: Purchase error: ${purchaseDetails.error?.message} (Code: ${purchaseDetails.error?.code})");
          
          // --- Handle "Already Owned" Error (Android Code '7') ---
          bool isAlreadyOwned = purchaseDetails.error?.code == '7' || 
                                (purchaseDetails.error?.message ?? '').toLowerCase().contains('already owned');

          if (isAlreadyOwned) {
             if (kDebugMode) print("IAPService: Error indicates 'Already Owned'. Treating as success/restore.");
             
             bool valid = await _verifyPurchase(purchaseDetails);
             if (valid) {
               await _deliverPurchase(purchaseDetails);
               await _completePurchase(purchaseDetails);
             }
          } else {
             // Genuine Error
             _setError("Purchase failed: ${purchaseDetails.error?.message}");
             // Complete erroneous transaction to clear queue
             await _completePurchase(purchaseDetails);
          }
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (kDebugMode) print("IAPService: Success/Restored. Verifying...");
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _deliverPurchase(purchaseDetails);
            await _completePurchase(purchaseDetails);
          } else {
            if (kDebugMode) print("IAPService: Verification failed.");
            _setError("Purchase verification failed.");
            await _completePurchase(purchaseDetails);
          }
          break;
          
        case PurchaseStatus.canceled:
          if (kDebugMode) print("IAPService: Purchase canceled by user.");
          await _completePurchase(purchaseDetails);
          break;
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(purchaseDetails);
        if (kDebugMode) print("IAPService: Purchase completed with store.");
      } catch (e) {
        if (kDebugMode) print("IAPService: Error completing purchase: $e");
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In production, validate serverVerificationData on backend.
    if (kDebugMode) print("IAPService: Trusting client-side purchase (Placeholder verification).");
    return true; 
  }

  Future<void> _deliverPurchase(PurchaseDetails purchaseDetails) async {
    if (kDebugMode) print("IAPService: Delivering purchase for ${purchaseDetails.productID}");
    
    // Check against the constant from iap_constants.dart
    if (purchaseDetails.productID == kProductIdPremiumUnlock) {
      if (kDebugMode) print("IAPService: Granting premium access.");
      
      if (_authService != null) {
          await _authService!.updateUserPremiumStatus(true); 
          _onPremiumStatusUpdated?.call(true); 
          if (kDebugMode) print("IAPService: Premium granted via AuthService.");
      } else {
          print("IAPService: CRITICAL - AuthService is null. Cannot grant premium.");
          _setError("Internal Error: Could not apply premium status.");
      }
    }
  }

  void _setError(String? message, {bool notify = true}) {
    if (_error != message) {
      _error = message;
      if (notify) notifyListeners();
    }
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
    return true; 
  }

  @override
  bool shouldShowPriceConsent() {
    return false; 
  }
}