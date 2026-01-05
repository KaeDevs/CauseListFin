import 'dart:async';

import 'package:fincauselist/Constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdConstants().interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print("Interstitial failed to load: $error");
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
    } else {
      print("Interstitial ad not ready.");
    }
  }
}




class RefreshableBannerAdWidget extends StatefulWidget {
  @override
  _RefreshableBannerAdWidgetState createState() =>
      _RefreshableBannerAdWidgetState();
}

class _RefreshableBannerAdWidgetState extends State<RefreshableBannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  Timer? _adRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _startAdRefreshTimer();
  }

  void _startAdRefreshTimer() {
    _adRefreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      // Fluttertoast.showToast(msg: "Ad Refreshing");
      _loadBannerAd();
    });
  }

  void _loadBannerAd() {
    // _bannerAd.dispose();
    _bannerAd = BannerAd(
      adUnitId: AdConstants().bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _adRefreshTimer?.cancel();
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? Container(
            alignment: Alignment.center,
            width: _bannerAd.size.width.toDouble(),
            height: _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
          )
        : SizedBox(); // Optionally show a placeholder or loading widget here
  }
}
