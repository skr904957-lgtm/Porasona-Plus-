import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Wraps Razorpay checkout for buying premium courses.
///
/// IMPORTANT (server-side step you must add): Razorpay order creation and
/// payment signature verification should happen on a trusted backend
/// (a Firebase Cloud Function is the natural fit here since you're already
/// using Firebase). This class only opens the checkout UI and reports the
/// client-side result — always verify payment signatures server-side before
/// unlocking premium content in production.
class PaymentService {
  final Razorpay _razorpay = Razorpay();

  void init({
    required void Function(PaymentSuccessResponse response) onSuccess,
    required void Function(PaymentFailureResponse response) onError,
    required void Function(ExternalWalletResponse response) onExternalWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  /// [orderId] should come from your backend's Razorpay Orders API call —
  /// never create the order amount purely on the client.
  void openCheckout({
    required String razorpayKeyId,
    required String orderId,
    required double amountInRupees,
    required String courseTitle,
    required String studentName,
    required String studentEmail,
    String? studentPhone,
  }) {
    final options = {
      'key': razorpayKeyId,
      'amount': (amountInRupees * 100).toInt(), // paise
      'order_id': orderId,
      'name': 'Porasona Plus',
      'description': courseTitle,
      'prefill': {
        'contact': studentPhone ?? '',
        'email': studentEmail,
        'name': studentName,
      },
      'theme': {'color': '#6A1B9A'},
    };
    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
