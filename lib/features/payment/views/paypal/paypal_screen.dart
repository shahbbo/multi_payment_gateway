import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:payment/features/payment/widgets/payment_logo.dart';
import 'package:payment/features/payment/widgets/product_details.dart';

class PaypalScreen extends StatefulWidget {
  const PaypalScreen({super.key});

  @override
  _PaypalScreenState createState() => _PaypalScreenState();
}

class _PaypalScreenState extends State<PaypalScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Package PayPal Payment')),
      body: SingleChildScrollView(
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

                ProductDetails(selectedCurrency: "USD", amount: "100.00"),

                const SizedBox(height: 40),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isLoading ? null : () => _processPayment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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

                // Information text
                const Text(
                  'Complete your payment securely with PayPal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    isLoading = true;

    try {
      // Launch in-app PayPal flow
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (BuildContext context) => /*PaypalCheckoutView(
                sandboxMode: viewModel.isSandbox,
                onSuccess: (Map params) {
                  print(
                    '////////////////////////////////////////////////\n ////////////////////////////////////////////////',
                  );
                  print(
                    '////////////////////////////////////////////////\n ////////////////////////////////////////////////',
                  );
                  print(
                    '///////////////////////////////////////////////\n ////////////////////////////////////////////////',
                  );
                  print(
                    '///////////////////////////////////////////////\n ////////////////////////////////////////////////',
                  );
                  print("onSuccess: $params");
                  viewModel.setLoading(false);
                  _showPaymentStatus(context, true, params);
                },
                onError: (error) {
                  print(
                    '////////////////////////////////////////////////\n ////////////////////////////////////////////////',
                  );
                  print(
                    '////////////////////////////////////////////////\n ////////////////////////////////////////////////',
                  );
                  print("onError: $error");
                  print("onError: ${error.toString()}");
                  viewModel.setLoading(false);
                  _showPaymentStatus(context, false, null);
                },
                onCancel: (params) {
                  print(
                    '////////////////////////////////////////////////\n ////////////////////////////////////////////////',
                  );
                  print('cancelled: $params');
                  viewModel.setLoading(false);
                  // Handle cancellation if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment was cancelled'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                transactions: [
                  {
                    "amount": {
                      "total": viewModel.amount.toStringAsFixed(2),
                      "currency": viewModel.currency,
                      "details": {
                        "subtotal": viewModel.amount.toStringAsFixed(2),
                        "shipping": '0',
                        "shipping_discount": 0,
                      },
                    },
                    "description": "Payment for ${viewModel.productName}",
                    "item_list": {
                      "items": [
                        {
                          "name": viewModel.productName,
                          "quantity": 1,
                          "price": viewModel.amount.toStringAsFixed(2),
                          "currency": viewModel.currency,
                        },
                      ],
                    },
                  },
                ],
                clientId: viewModel.clientId,
                secretKey: viewModel.secretKey,
                note: "Contact us for any questions on your order.",
              ),*/ UsePaypal(
                sandboxMode: true,
                clientId: dotenv.env['PAYPAL_CLIENT_ID']!,
                secretKey: dotenv.env['PAYPAL_CLIENT_SECRET']!,
                returnURL: "https://example.com/return",
                cancelURL: "https://example.com/cancel",
                transactions: [
                  {
                    "intent": "sale",
                    "payer": {"payment_method": "paypal"},
                    "transactions": [
                      {
                        "amount": {
                          "total": "100.00",
                          "currency":
                              {
                                "symbol": "USD ",
                                "decimalDigits": 2,
                                "symbolBeforeTheNumber": true,
                                "currency": "USD",
                              }["currency"],
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
                          "items": {
                            "name": "Apple Watch",
                            "quantity": "1",
                            "price": "100.00",
                            "currency":
                                {
                                  "symbol": "USD ",
                                  "decimalDigits": 2,
                                  "symbolBeforeTheNumber": true,
                                  "currency": "USD",
                                }["currency"],
                          },
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
                    "note_to_payer":
                        "Contact us for any questions on your order.",
                    "redirect_urls": {
                      "return_url": "https://example.com/return",
                      "cancel_url": "https://example.com/cancel",
                    },
                  },
                ],
                note: "Contact us for any questions on your order.",
                onSuccess: (Map params) {
                  print('////////////////////////\n ///////////////////////');
                  print('////////////////////////\n ///////////////////////');
                  print('success');
                  print('////////////////////////\n ///////////////////////');
                  print('////////////////////////\n ///////////////////////');
                  print("onSuccess: $params");
                  isLoading = false;
                  _showPaymentStatus(context, true, params);
                },
                onError: (error) {
                  print('////////////////////////\n ///////////////////////');
                  print('////////////////////////\n ///////////////////////');
                  print("onError: ${error.toString()}");
                  isLoading = false;
                  _showPaymentStatus(context, false, error);
                },
                onCancel: (params) {
                  print('////////////////////////\n ///////////////////////');
                  print('////////////////////////\n ///////////////////////');
                  print('////////////////////////\n ///////////////////////');
                  print('cancelled: $params');
                  isLoading = false;
                  // Handle cancellation if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment was cancelled'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
        ),
      );
    } catch (e) {
      isLoading = false;
      print('Error during PayPal checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showPaymentStatus(BuildContext context, bool success, Map? params) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(success ? 'Payment Successful' : 'Payment Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                success
                    ? 'Your payment has been processed successfully!'
                    : 'There was an error processing your payment. Please try again.',
              ),
              if (success && params != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Transaction Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Transaction ID: ${params['paymentId'] ?? 'N/A'}'),
                Text('Payer ID: ${params['payerId'] ?? 'N/A'}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
