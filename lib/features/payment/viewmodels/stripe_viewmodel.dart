import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/stripe_service.dart';

enum PaymentMethod { card, paymentSheet }

class StripeViewModel extends ChangeNotifier {
  final StripeService _stripeService = StripeService();

  bool isLoading = false;
  String? error;
  String? successMsg;
  CardFieldInputDetails? cardFieldInputDetails;
  Map<String, dynamic>? paymentIntent;

  PaymentMethod selectedPaymentMethod = PaymentMethod.paymentSheet;

  void setPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  void updateCardDetails(CardFieldInputDetails details) {
    cardFieldInputDetails = details;
    notifyListeners();
  }

  bool get isCardValid {
    if (selectedPaymentMethod == PaymentMethod.paymentSheet) {
      return true;
    }
    return cardFieldInputDetails != null && cardFieldInputDetails!.complete;
  }

  Future<void> makePayment({
    required BuildContext context,
    String amount = '100',
    String currency = 'USD',
    String merchantName = 'Your Merchant',
    String countryCode = 'US',
  }) async {
    try {
      if (selectedPaymentMethod == PaymentMethod.card &&
          (cardFieldInputDetails == null || !cardFieldInputDetails!.complete)) {
        error = 'Please complete card details';
        notifyListeners();
        return;
      }

      isLoading = true;
      error = null;
      successMsg = null;
      notifyListeners();

      paymentIntent = await _stripeService.createPaymentIntent(
        amount: amount,
        currency: currency,
      );

      if (paymentIntent == null || paymentIntent!['client_secret'] == null) {
        error = 'Failed to create payment intent';
        isLoading = false;
        notifyListeners();
        return;
      }

      if (selectedPaymentMethod == PaymentMethod.card) {
        // استخدام CardField
        final paymentMethod = await _stripeService.createPaymentMethod();

        final paymentResult = await _stripeService.confirmPayment(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          paymentMethodId: paymentMethod.id,
        );

        // تحقق من حالة الدفع
        if (paymentResult.status == PaymentIntentsStatus.Succeeded) {
          successMsg = "Payment successful";
        } else if (paymentResult.status ==
            PaymentIntentsStatus.RequiresAction) {
          // التعامل مع مصادقة 3D Secure
          final handledIntent = await Stripe.instance.handleNextAction(
            paymentIntent!['client_secret'],
          );
          if (handledIntent.status == PaymentIntentsStatus.Succeeded) {
            successMsg = "Payment successful after authentication";
          } else {
            error = "Payment requires further action: ${handledIntent.status}";
          }
        } else {
          error = "Payment failed: ${paymentResult.status}";
        }
      } else {
        // استخدام PaymentSheet
        await _stripeService.initPaymentSheet(
          clientSecret: paymentIntent!['client_secret'],
          merchantName: merchantName,
          currency: currency,
          countryCode: countryCode,
        );

        // انتظر قليلاً قبل عرض PaymentSheet
        await Future.delayed(Duration(milliseconds: 200));
        await _stripeService.presentPaymentSheet();

        successMsg = "Paid successfully";
      }

      isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    cardFieldInputDetails = null;
    paymentIntent = null;
    error = null;
    successMsg = null;
    isLoading = false;
    notifyListeners();
  }
}
