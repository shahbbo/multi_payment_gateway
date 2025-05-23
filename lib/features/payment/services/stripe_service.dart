import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:payment/core/pretty_json_printer.dart';

class StripeService {
  static String secretKey = dotenv.env['STRIPE_SECRET_KEY']!;

  // Create payment intent on Stripe server
  Future<Map<String, dynamic>?> createPaymentIntent({
    required String amount,
    required String currency,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'amount':
            ((double.parse(amount) * 100).toInt())
                .toString(), // Stripe uses smallest currency unit
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response body
        debugPrint('Response body in createPaymentIntent');
        prettyPrintJson(jsonDecode(response.body));
        return jsonDecode(response.body);
      }
      throw Exception('Failed to create payment intent: ${response.body}');
    } catch (err) {
      rethrow;
    }
  }

  // Create payment method from card details
  Future<PaymentMethod> createPaymentMethod() async {
    try {
      final result = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      return result;
    } catch (e) {
      debugPrint('Error in createPaymentMethod: $e');
      rethrow;
    }
  }

  // Confirm payment with paymentIntent and paymentMethod
  Future<PaymentIntent> confirmPayment({
    required String paymentIntentClientSecret,
    required String paymentMethodId,
  }) async {
    debugPrint("Confirming payment - Method ID: $paymentMethodId");
    debugPrint(
      "Client Secret: ${paymentIntentClientSecret.substring(0, 10)}...",
    );

    try {
      final result = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethodId,
          ),
        ),
      );
      debugPrint("Payment confirmed - Status: ${result.status}");
      return result;
    } catch (e) {
      debugPrint("First method failed, trying alternative method: $e");
      rethrow;
    }
  }

  // Initialize payment sheet
  Future<void> initPaymentSheet({
    required String clientSecret,
    required String merchantName,
    String currency = 'USD',
    String countryCode = 'US',
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantName,
        googlePay: PaymentSheetGooglePay(
          testEnv: true,
          currencyCode: currency,
          merchantCountryCode: countryCode,
        ),
      ),
    );
  }

  // Present payment sheet to user
  Future<void> presentPaymentSheet() async {
    await Stripe.instance.presentPaymentSheet();
  }

  // Method to retrieve payment intent (useful for checking status)
  Future<PaymentIntent> retrievePaymentIntent(String clientSecret) async {
    return await Stripe.instance.retrievePaymentIntent(clientSecret);
  }
}
