/// App Store / Google Play identifiers — keep in sync with store consoles.
abstract final class StoreConfig {
  /// iOS bundle ID and Android applicationId.
  static const String bundleId = 'com.app.dermatology';

  static const String monthlyProductId = '$bundleId.premium.monthly';
  static const String yearlyProductId = '$bundleId.premium.yearly';
  static const String lifetimeProductId = '$bundleId.premium.lifetime';

  static const Set<String> premiumProductIds = {
    monthlyProductId,
    yearlyProductId,
    lifetimeProductId,
  };
}
