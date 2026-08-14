/// Phase 1 stubs. Real AdMob / IAP land in the global-launch phase.
abstract class Monetization {
  Future<bool> watchRewardedAd();
  Future<bool> purchaseGems();
  Future<bool> purchaseRemoveAds();
}

class StubMonetization implements Monetization {
  @override
  Future<bool> watchRewardedAd() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return true;
  }

  @override
  Future<bool> purchaseGems() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<bool> purchaseRemoveAds() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
