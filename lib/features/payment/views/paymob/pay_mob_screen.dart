import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_paymob/flutter_paymob.dart';
import 'package:pay_with_paymob/pay_with_paymob.dart';
import '../../widgets/payment_logo.dart';
import '../../widgets/product_details.dart';

class PayMobScreen extends StatefulWidget {
  const PayMobScreen({super.key});

  @override
  State<PayMobScreen> createState() => _PayMobScreenState();
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class _PayMobScreenState extends State<PayMobScreen> {
  String selectedPaymentMethod = 'card';

  bool isLoading = false;

  String errorMessage = '';

  @override
  void initState() {
    PaymentData.initialize(
      apiKey: dotenv.env['PAYMOB_API_KEY']!,
      iframeId: dotenv.env['PAYMOB_IFRAME_ID']!,
      integrationCardId: dotenv.env['PAYMOB_CARD_ID']!,
      integrationMobileWalletId: dotenv.env['PAYMOB_WALLET_ID']!,

      // Optional Style Customizations
      style: Style(
        primaryColor: Colors.blue,
        // Default: Colors.blue
        scaffoldColor: Colors.white,
        // Default: Colors.white
        appBarBackgroundColor: Colors.blue,
        // Default: Colors.blue
        appBarForegroundColor: Colors.white,
        // Default: Colors.white
        textStyle: TextStyle(),
        // Default: TextStyle()
        buttonStyle: ElevatedButton.styleFrom(),
        // Default: ElevatedButton.styleFrom()
        circleProgressColor: Colors.blue,
        // Default: Colors.blue
        unselectedColor: Colors.grey, // Default: Colors.grey
      ),
    );
    FlutterPaymob.instance.initialize(
      apiKey: dotenv.env['PAYMOB_API_KEY']!,
      integrationID: int.parse(dotenv.env['PAYMOB_CARD_ID']!),
      walletIntegrationId: int.parse(dotenv.env['PAYMOB_WALLET_ID']!),
      iFrameID: int.parse(dotenv.env['PAYMOB_IFRAME_ID']!),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paymob Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaymentLogo(
                logoUrl:
                    'https://cdn.wamda.com/feature-images/2d48051bc1fd9f5.png',
              ),
              // Payment options
              const Text(
                'Payment Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Payment method choices
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Credit Card'),
                      value: 'card',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPaymentMethod = value;
                          });
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Mobile Wallet'),
                      value: 'wallet',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPaymentMethod = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Product details card
              ProductDetails(selectedCurrency: 'EGP', amount: '16000'),
              const Spacer(),

              // Checkout button with animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () {
                            if (selectedPaymentMethod == 'card') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PaymentView(
                                        onPaymentSuccess: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Payment Successful',
                                              ),
                                            ),
                                          );
                                        },
                                        onPaymentError: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Payment Failed'),
                                            ),
                                          );
                                        },
                                        price: 16000,
                                      ),
                                ),
                              );
                              setState(() {
                                isLoading = true;
                              });
                            }
                            /*if (_formKey.currentState!.validate()) {
                              if (selectedPaymentMethod == 'card') {
                                FlutterPaymob.instance.payWithCard(
                                  context: context,
                                  currency: "EGP",
                                  amount: 16000,
                                  onPayment: (response) {
                                    if (response.success == true) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response.message ?? "Success",
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response.message ?? "Error",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              } else {
                                FlutterPaymob.instance.payWithWallet(
                                  number: '01555173391',
                                  context: context,
                                  currency: "EGP",
                                  amount: 16000,
                                  onPayment: (response) {
                                    if (response.success == true) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response.message ?? "Success",
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response.message ?? "Error",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              }
                              setState(() {
                                isLoading = true;
                              });
                            }*/
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Pay with Paymob',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),

              if (errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
