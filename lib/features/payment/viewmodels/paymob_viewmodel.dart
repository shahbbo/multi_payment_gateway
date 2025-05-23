import 'package:flutter/foundation.dart';
import '../services/paymob_service.dart';

enum PaymentMethod { card, wallet, kiosk }

class PaymobViewModel extends ChangeNotifier {
  final PaymobService _paymobService = PaymobService();

  bool isLoading = false;

  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  int _orderId = 0;
  String? _paymentKey;
  int? _billReference;
  String? _redirectUrl;
  String? _iframeUrl;
  String? _errorMessage;

  PaymentMethod get selectedPaymentMethod => _selectedPaymentMethod;
  int get orderId => _orderId;
  String? get paymentKey => _paymentKey;
  int? get billReference => _billReference;
  String? get redirectUrl => _redirectUrl;
  String? get iframeUrl => _iframeUrl;
  String? get errorMessage => _errorMessage;

  void setPaymentMethod(PaymentMethod method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  int getIntegrationId() {
    switch (_selectedPaymentMethod) {
      case PaymentMethod.card:
        return PaymobService.cardIntegrationId;
      case PaymentMethod.wallet:
        return PaymobService.walletIntegrationId;
      case PaymentMethod.kiosk:
        return PaymobService.kioskIntegrationId;
    }
  }

  Future<bool> initiatePayment() async {
    _errorMessage = null;
    _setLoading(true);

    try {
      final authToken = await _paymobService.getAuthToken();
      if (authToken == null) {
        _errorMessage = "failed to get auth token in viewmodel";
        _setLoading(false);
        return false;
      }

      final amountCents = (7000 * 100).toInt();
      final items = [
        {
          'name': "Apple Watch",
          'amount_cents': 7000,
          'description': "Apple Watch Series 7 - GPS + Cellular",
          'quantity': '1',
        },
      ];

      final orderId = await _paymobService.registerOrder(
        amountCents: amountCents,
        currency: "EGP",
        items: items,
      );

      if (orderId == null) {
        _errorMessage = "failed to register order in viewmodel";
        _setLoading(false);
        return false;
      }

      _orderId = orderId;

      final billingData = {
        'first_name': 'mahmoud',
        'last_name': 'shahbo',
        'email': 'shahbo@example.com',
        'phone_number': '01204963547',
        'street': 'NA',
        'building': 'NA',
        'floor': 'NA',
        'apartment': 'NA',
        'city': 'NA',
        'state': 'NA',
        'country': 'EG',
        'postal_code': 'NA',
        'shipping_method': 'NA',
      };

      final paymentKey = await _paymobService.getPaymentKey(
        amountCents: amountCents,
        currency: "EGP",
        integrationId: getIntegrationId(),
        billingData: billingData,
      );

      if (paymentKey == null) {
        _errorMessage = "failed to get payment key in viewmodel";
        _setLoading(false);
        return false;
      }

      _paymentKey = paymentKey;

      bool success = false;

      switch (_selectedPaymentMethod) {
        case PaymentMethod.card:
          _iframeUrl = _paymobService.getCardPaymentUrl();
          success = _iframeUrl != null;
          break;

        case PaymentMethod.wallet:
          final walletResponse = await _paymobService.payWithWallet(
            paymentKey: paymentKey,
            phoneNumber: "01555173391",
          );

          if (walletResponse != null &&
              walletResponse.containsKey('iframe_redirection_url')) {
            _redirectUrl = walletResponse['iframe_redirection_url'];
            debugPrint("redirect url in viewmodel: $_redirectUrl");
            success = true;
          } else {
            _errorMessage =
                "failed to get redirect url for wallet in pawymob viewmodel";
          }
          break;

        case PaymentMethod.kiosk:
          final kioskResponse = await _paymobService.payWithKiosk(
            paymentKey: paymentKey,
          );

          if (kioskResponse != null &&
              kioskResponse.containsKey('data') &&
              kioskResponse['data'].containsKey('bill_reference')) {
            _billReference = kioskResponse['data']['bill_reference'];
            success = true;
          } else {
            _errorMessage = "فشل إنشاء رقم مرجع الكيوسك";
          }
          break;
      }

      _setLoading(false);
      return success;
    } catch (e) {
      debugPrint("Error in initiatePayment: $e");
      _errorMessage = "Error in initiatePayment: $e";
      _setLoading(false);
      return false;
    }
  }

  void reset() {
    isLoading = false;
    _orderId = 0;
    _paymentKey = null;
    _billReference = null;
    _redirectUrl = null;
    _iframeUrl = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}
