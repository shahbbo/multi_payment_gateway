/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PayMobService {
  // API URLs
  final String _baseUrl = 'https://accept.paymob.com/api';
  final String _authTokenUrl = '/auth/tokens';
  final String _orderRegistrationUrl = '/ecommerce/orders';
  final String _paymentKeyUrl = '/acceptance/payment_keys';
  final String _payUrl = '/acceptance/payments/pay';

  // تخزين البيانات المهمة
  String? _authToken;
  int? _orderId;
  String? _paymentKey;

  // API المفاتيح - يتم تعديلها حسب حسابك
  final String apiKey;
  final int cardIntegrationId;
  final int walletIntegrationId;
  final int kioskIntegrationId;

  // يتم تحديد المعرفات من لوحة تحكم باي موب
  PayMobService({
    required this.apiKey,
    required this.cardIntegrationId,
    required this.walletIntegrationId,
    required this.kioskIntegrationId,
  });

  Future<String?> getAuthToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_authTokenUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'api_key': apiKey}),
      );

      debugPrint('response in getAuthToken: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data.containsKey('token')) {
          _authToken = data['token'];
          debugPrint('PayMob Auth Token in getAuthToken: $_authToken');
          return data['token'];
        }
      } else {
        throw Exception('response exception in getAuthToken: ${response.body}');
      }
    } catch (e) {
      debugPrint('error in getAuthToken: $e');
    }
    return null;
  }

  // 2. تسجيل الطلب للحصول على Order ID
  Future<int?> registerOrder({
    required int amountCents,
    required String currency,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? shippingData,
    String? merchantOrderId,
    bool deliveryNeeded = false,
  }) async {
    if (_authToken == null) {
      await getAuthToken();
      if (_authToken == null) return null;
    }

    try {
      final Map<String, dynamic> orderData = {
        'auth_token': _authToken,
        'delivery_needed': deliveryNeeded.toString(),
        'amount_cents': amountCents.toString(),
        'currency': currency,
        'items': items,
      };

      if (merchantOrderId != null) {
        orderData['merchant_order_id'] = merchantOrderId;
      }

      if (shippingData != null) {
        orderData['shipping_data'] = shippingData;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl$_orderRegistrationUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      debugPrint('response in registerOrder: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _orderId = data['id'];
        debugPrint('PayMob Order ID in registerOrder: $_orderId');
        return _orderId;
      } else {
        throw Exception(
          'failed to register order in registerOrder: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('failed to register order in registerOrder: $e');
      return null;
    }
  }

  // 3. الحصول على مفتاح الدفع (Payment Key)
  Future<String?> getPaymentKey({
    required int amountCents,
    required String currency,
    required Map<String, dynamic> billingData,
    required int integrationId,
    int expirationSeconds = 3600,
    bool lockOrderWhenPaid = false,
  }) async {
    if (_authToken == null) {
      await getAuthToken();
      if (_authToken == null) return null;
    }

    if (_orderId == null) {
      debugPrint('you need to register an order first');
      return null;
    }

    try {
      final Map<String, dynamic> paymentKeyData = {
        'auth_token': _authToken,
        'amount_cents': amountCents.toString(),
        'expiration': expirationSeconds,
        'currency': currency,
        'order_id': _orderId,
        'integration_id': integrationId,
        'billing_data': billingData,
        'lock_order_when_paid': lockOrderWhenPaid.toString(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_paymentKeyUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(paymentKeyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _paymentKey = data['token'];
        debugPrint('PayMob Payment Key: $_paymentKey');
        return _paymentKey;
      } else {
        throw Exception(
          'failed to get payment key in getPaymentKey: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('failed to get payment key in getPaymentKey: $e');
      return null;
    }
  }

  // 4. الدفع باستخدام الكيوسك (KIOSK)
  Future<Map<String, dynamic>?> payWithKiosk() async {
    if (_paymentKey == null) {
      debugPrint('you need to get a payment key first');
      return null;
    }

    try {
      final Map<String, dynamic> payData = {
        'source': {'identifier': 'AGGREGATOR', 'subtype': 'AGGREGATOR'},
        'payment_token': _paymentKey,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_payUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final billReference = data['data']['bill_reference'];
        debugPrint('PayMob Kiosk Bill Reference: $billReference');
        return data;
      } else {
        throw Exception('فشل في إنشاء دفعة الكيوسك: ${response.body}');
      }
    } catch (e) {
      debugPrint('خطأ أثناء إنشاء دفعة الكيوسك: $e');
      return null;
    }
  }

  // 5. الدفع باستخدام المحفظة (WALLET)
  Future<Map<String, dynamic>?> payWithWallet({
    required String mobileNumber,
  }) async {
    if (_paymentKey == null) {
      debugPrint('you need to get a payment key firstً');
      return null;
    }

    try {
      final Map<String, dynamic> payData = {
        'source': {'identifier': mobileNumber, 'subtype': 'WALLET'},
        'payment_token': _paymentKey,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_payUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final redirectUrl = data['redirect_url'];
        debugPrint('PayMob Wallet Redirect URL: $redirectUrl');
        return data;
      } else {
        throw Exception(
          'failed to create wallet payment in payWithWallet: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('failed to create wallet payment in payWithWallet: $e');
      return null;
    }
  }

  // 6. إنشاء رابط الدفع ببطاقة الائتمان
  String getCardPaymentUrl({required String iframeId}) {
    if (_paymentKey == null) {
      throw Exception('يرجى الحصول على مفتاح الدفع أولاً');
    }

    return 'https://accept.paymobsolutions.com/api/acceptance/iframes/$iframeId?payment_token=$_paymentKey';
  }

  // 7. مساعدة: إنشاء بيانات الفواتير القياسية
  static Map<String, dynamic> createBillingData({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    String street = 'NA',
    String building = 'NA',
    String floor = 'NA',
    String apartment = 'NA',
    String city = 'NA',
    String state = 'NA',
    String country = 'NA',
    String postalCode = 'NA',
  }) {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'street': street,
      'building': building,
      'floor': floor,
      'apartment': apartment,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'shipping_method': 'NA',
    };
  }

  // 8. إعادة تعيين حالة الخدمة
  void reset() {
    _authToken = null;
    _orderId = null;
    _paymentKey = null;
  }
}*/

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:payment/core/pretty_json_printer.dart';

class PaymobService {
  // API URLs
  final String _baseUrl = 'https://accept.paymob.com/api';
  final String _authTokenUrl = '/auth/tokens';
  final String _orderRegistrationUrl = '/ecommerce/orders';
  final String _paymentKeyUrl = '/acceptance/payment_keys';
  final String _payUrl = '/acceptance/payments/pay';

  // تخزين البيانات المهمة
  String? _authToken;
  int? _orderId;
  String? _paymentKey;

  static String apiKey = dotenv.env['PAYMOB_API_KEY']!;
  static int cardIntegrationId = int.parse(dotenv.env['PAYMOB_CARD_ID']!);
  static int walletIntegrationId = int.parse(dotenv.env['PAYMOB_WALLET_ID']!);
  static int kioskIntegrationId = int.parse(dotenv.env['PAYMOB_KIOSK_ID']!);
  static final String _iframeId = dotenv.env['PAYMOB_IFRAME_ID']!;

  Future<String?> getAuthToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_authTokenUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'api_key': apiKey}),
      );

      debugPrint('response in getAuthToken: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data.containsKey('token')) {
          _authToken = data['token'];
          debugPrint('PayMob Auth Token in getAuthToken: $_authToken');
          return data['token'];
        }
      } else {
        throw Exception('response exception in getAuthToken: ${response.body}');
      }
    } catch (e) {
      debugPrint('error in getAuthToken: $e');
    }
    return null;
  }

  Future<int?> registerOrder({
    required int amountCents,
    required String currency,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? shippingData,
    String? merchantOrderId,
    bool deliveryNeeded = false,
  }) async {
    if (_authToken == null) {
      await getAuthToken();
      if (_authToken == null) return null;
    }

    try {
      final Map<String, dynamic> orderData = {
        'auth_token': _authToken,
        'delivery_needed': deliveryNeeded.toString(),
        'amount_cents': amountCents.toString(),
        'currency': currency,
        'items': items,
      };

      if (merchantOrderId != null) {
        orderData['merchant_order_id'] = merchantOrderId;
      }

      if (shippingData != null) {
        orderData['shipping_data'] = shippingData;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl$_orderRegistrationUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      debugPrint('response in registerOrder: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _orderId = data['id'];
        debugPrint('PayMob Order ID in registerOrder: $_orderId');
        return _orderId;
      } else {
        throw Exception(
          'failed to register order in registerOrder: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('failed to register order in registerOrder: $e');
      return null;
    }
  }

  Future<String?> getPaymentKey({
    required int amountCents,
    required String currency,
    required Map<String, dynamic> billingData,
    required int integrationId,
    int expirationSeconds = 3600,
    bool lockOrderWhenPaid = false,
  }) async {
    if (_authToken == null) {
      await getAuthToken();
      if (_authToken == null) return null;
    }

    if (_orderId == null) {
      debugPrint('you need to register an order first');
      return null;
    }

    try {
      final Map<String, dynamic> paymentKeyData = {
        'auth_token': _authToken,
        'amount_cents': amountCents.toString(),
        'expiration': expirationSeconds,
        'currency': currency,
        'order_id': _orderId,
        'integration_id': integrationId,
        'billing_data': billingData,
        'lock_order_when_paid': lockOrderWhenPaid.toString(),
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_paymentKeyUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(paymentKeyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _paymentKey = data['token'];
        debugPrint('PayMob Payment Key: $_paymentKey');
        return _paymentKey;
      } else {
        throw Exception(
          'failed to get payment key in getPaymentKey: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('failed to get payment key in getPaymentKey: $e');
      return null;
    }
  }

  // 4. الحصول على رابط الدفع ببطاقة الائتمان
  String? getCardPaymentUrl() {
    return 'https://accept.paymobsolutions.com/api/acceptance/iframes/$_iframeId?payment_token=$_paymentKey';
  }

  // 5. الدفع باستخدام المحفظة
  Future<Map<String, dynamic>?> payWithWallet({
    required String paymentKey,
    required String phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> payData = {
        'source': {'identifier': phoneNumber, 'subtype': 'WALLET'},
        'payment_token': paymentKey,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_payUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        prettyPrintJson(responseData);

        // Check if redirect_url exists and print it specifically
        if (responseData.containsKey('redirect_url')) {
          debugPrint('REDIRECT URL FOUND: ${responseData['redirect_url']}');
        } else {
          debugPrint('NO REDIRECT URL FOUND IN RESPONSE');
        }

        return responseData;
      } else {
        debugPrint(
          'failed to create wallet payment in payWithWallet in paymob service: ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint(
        'failed to create wallet payment in payWithWallet in paymob service: $e',
      );
      return null;
    }
  }

  // 6. الدفع باستخدام الكيوسك
  Future<Map<String, dynamic>?> payWithKiosk({
    required String paymentKey,
  }) async {
    try {
      final Map<String, dynamic> payData = {
        'source': {'identifier': 'AGGREGATOR', 'subtype': 'AGGREGATOR'},
        'payment_token': paymentKey,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl$_payUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('فشل في إنشاء دفعة الكيوسك: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('خطأ أثناء إنشاء دفعة الكيوسك: $e');
      return null;
    }
  }
}
