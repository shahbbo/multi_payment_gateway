import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../viewmodels/paypal_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/payment_logo.dart';
import '../../widgets/product_details.dart';

class LowLevelPaypalScreen extends StatefulWidget {
  final Function(String?)? onFinish;

  const LowLevelPaypalScreen({super.key, this.onFinish});

  @override
  _LowLevelPaypalScreenState createState() => _LowLevelPaypalScreenState();
}

class _LowLevelPaypalScreenState extends State<LowLevelPaypalScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<PaypalViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.checkoutUrl != null) {
          return _buildPaypalCheckout(viewModel);
        } else {
          return _buildPaypalForm(viewModel);
        }
      },
    );
  }

  Widget _buildPaypalForm(PaypalViewModel viewModel) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Low Level PayPal Payment')),
      body:
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PaymentLogo(
                          logoUrl:
                              'https://upload.wikimedia.org/wikipedia/commons/a/a4/Paypal_2014_logo.png?20150315064712',
                        ),
                        const SizedBox(height: 40),
                        const ProductDetails(
                          selectedCurrency: 'USD',
                          amount: '100.00',
                        ),
                        const SizedBox(height: 40),
                        // Checkout button with animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                viewModel.isLoading
                                    ? null
                                    : () => _processPayment(viewModel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child:
                                viewModel.isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          'https://www.paypalobjects.com/webstatic/en_US/i/buttons/PP_logo_h_100x26.png',
                                          height: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Pay with PayPal',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildPaypalCheckout(PaypalViewModel viewModel) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Low Level PayPal Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            viewModel.checkoutUrl = null;
            viewModel.executeUrl = null;
            viewModel.notifyListeners();
          },
        ),
      ),
      body: WebViewWidget(
        controller:
            WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(viewModel.checkoutUrl!))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (NavigationRequest request) {
                    if (request.url.contains(viewModel.returnURL)) {
                      final uri = Uri.parse(request.url);
                      final payerID = uri.queryParameters['PayerID'];
                      if (payerID != null) {
                        _handlePaymentSuccess(viewModel, payerID);
                      } else {
                        Navigator.of(context).pop();
                      }
                      return NavigationDecision.prevent;
                    }
                    if (request.url.contains(viewModel.cancelURL)) {
                      // Reset the checkout URL to go back to the form
                      viewModel.checkoutUrl = null;
                      viewModel.executeUrl = null;
                      viewModel.notifyListeners();
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              ),
      ),
    );
  }

  void _processPayment(PaypalViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    viewModel.setCredentials(
      dotenv.env['PAYPAL_CLIENT_ID']!,
      dotenv.env['PAYPAL_CLIENT_SECRET']!,
    );
    final success = await viewModel.initPaypalPayment();
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to initialize PayPal payment. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaypalViewModel viewModel, String payerId) async {
    debugPrint(
      '///////////////////////////////////////////////////\n ////////////////////////////////////////////////',
    );
    debugPrint(
      'Payer ID in low level paypal screen in handlePaymentSuccess: $payerId',
    );
    final paymentId = await viewModel.executePaypalPayment(payerId);
    if (paymentId != null) {
      if (widget.onFinish != null) {
        widget.onFinish!(paymentId);
      }
      viewModel.checkoutUrl = null;
      viewModel.executeUrl = null;
      viewModel.notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful! Payment ID: $paymentId'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      viewModel.checkoutUrl = null;
      viewModel.executeUrl = null;
      viewModel.notifyListeners();
    }
  }
}
