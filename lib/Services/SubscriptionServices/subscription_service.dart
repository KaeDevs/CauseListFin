import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SubscriptionService extends ChangeNotifier {
  // For testing, use Google Play's reserved test product IDs
  // For production, replace with your actual product ID from Google Play Console
  // static const String productId = "android.test.purchased"; // Test ID that always succeeds
  static const String productId = "cause_list_premium_monthly"; // Your actual product ID

  bool _isPremium = false;
  int _remainingSearches = 15;

  bool get isPremium => _isPremium;
  int get remainingSearches => _remainingSearches;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool("isPremium") ?? false;
    _remainingSearches = prefs.getInt("remainingSearches") ?? 15;
    await _resetIfNeeded();
    _listenToPurchases();
    notifyListeners();
  }

  void _listenToPurchases() {
    InAppPurchase.instance.purchaseStream.listen((purchases) async {
      for (var p in purchases) {
        if (p.productID == productId && p.status == PurchaseStatus.purchased) {
          await _unlockPremium();
        }
      }
    });
  }

  Future<void> _unlockPremium() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = true;
    await prefs.setBool("isPremium", true);
    notifyListeners();
  }

  Future<void> cancelSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = false;
    await prefs.setBool("isPremium", false);
    // Reset to default free tier
    _remainingSearches = 15;
    await prefs.setInt("remainingSearches", 15);
    notifyListeners();
  }

  Future<bool> canSearch() async {
    if (_isPremium) return true;
    return _remainingSearches > 0;
  }

  Future<void> useSearch() async {
    if (_isPremium) return;
    final prefs = await SharedPreferences.getInstance();
    _remainingSearches--;
    await prefs.setInt("remainingSearches", _remainingSearches);
    notifyListeners();
  }

  Future<void> grantExtraSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _remainingSearches += 5;
    await prefs.setInt("remainingSearches", _remainingSearches);
    notifyListeners();
  }

  Future<void> _resetIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(" ")[0];
    final last = prefs.getString("lastReset");

    if (today != last) {
      _remainingSearches = 15;
      await prefs.setInt("remainingSearches", 15);
      await prefs.setString("lastReset", today);
    }
  }
}
