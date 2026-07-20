/// App-wide configuration constants.
///
/// IMPORTANT: This app requires NO AI API keys of any kind (no OpenAI key,
/// no AI service key). The only external key needed is your Razorpay Key ID
/// below, and even that is only needed for the "Buy Now" payment flow —
/// the rest of the app builds and runs without it.
class AppConfig {
  static const String appName = 'Porasona Plus';

  /// Get this from Razorpay Dashboard → Settings → API Keys.
  /// Use the **Key ID** here (never the Key Secret — that stays server-side
  /// only, e.g. inside a Firebase Cloud Function).
  static const String razorpayKeyId = 'REPLACE_WITH_YOUR_RAZORPAY_KEY_ID';
}
