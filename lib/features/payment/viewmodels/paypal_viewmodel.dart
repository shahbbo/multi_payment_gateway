import 'package:flutter/foundation.dart';
import '../services/paypal_service.dart';

class PaypalViewModel extends ChangeNotifier {
  final PaypalService _paypalService = PaypalService();

  bool isLoading = false;
  String? accessToken;
  String? checkoutUrl;
  String? executeUrl;

  String returnURL = 'https://example.com/return';
  String cancelURL = 'https://example.com/cancel';

  Map<String, dynamic> defaultCurrency = {
    "symbol": "USD ",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "USD",
  };

  // Methods
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setCredentials(String clientId, String secret) {
    _paypalService.setCredentials(clientId, secret);
    notifyListeners();
  }

  Map<String, dynamic> getOrderParams() {
    List items = [
      {
        "name": "Apple Watch",
        "quantity": "1",
        "price": "100.00",
        "currency": defaultCurrency["currency"],
      },
    ];
    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": "100.00",
            "currency": defaultCurrency["currency"],
            "details": {
              "subtotal": "100.00",
              "shipping": '0',
              "shipping_discount": ((-1.0) * 0).toString(),
            },
          },
          "description": "Payment for Apple Watch",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE",
          },
          "item_list": {
            "items": items,
            "shipping_address": {
              "recipient_name": "Mahmoud Shahbo",
              "line1": "Giza",
              "line2": "El-Mohandseen",
              "city": "Cairo",
              "country_code": "EG",
              "postal_code": "94107",
              "phone": "01111111111",
            },
          },
        },
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {
        "return_url": "https://example.com/return",
        "cancel_url": "https://example.com/cancel",
      },
    };
    return temp;
  }

  Future<bool> initPaypalPayment() async {
    setLoading(true);

    try {
      accessToken = await _paypalService.getAccessToken();
      if (accessToken == null) {
        setLoading(false);
        return false;
      }

      final transactions = getOrderParams();
      final result = await _paypalService.createPaypalPayment(
        transactions,
        accessToken,
      );

      if (result != null) {
        checkoutUrl = result["approvalUrl"];
        executeUrl = result["executeUrl"];
        setLoading(false);
        return true;
      } else {
        setLoading(false);
        return false;
      }
    } catch (e) {
      setLoading(false);

      debugPrint(
        'Error during PayPal initializing in low level paypal viewmodel: $e',
      );
      return false;
    }
  }

  Future<String?> executePaypalPayment(String payerId) async {
    setLoading(true);

    try {
      if (executeUrl == null || accessToken == null) {
        setLoading(false);
        return null;
      }

      final result = await _paypalService.executePayment(
        executeUrl!,
        payerId,
        accessToken,
      );

      setLoading(false);
      debugPrint(
        'PayPal result in low level paypal viewmodel in executePaypalPayment: $result',
      );
      return result;
    } catch (e) {
      setLoading(false);

      debugPrint(
        'Error during PayPal executing in low level paypal viewmodel in executePaypalPayment: $e',
      );
      return null;
    }
  }
}
