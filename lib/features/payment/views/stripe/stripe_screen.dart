import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card, PaymentMethod;
import 'package:payment/features/payment/widgets/payment_logo.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/stripe_viewmodel.dart';
import '../../widgets/product_details.dart';

class StripeScreen extends StatefulWidget {
  const StripeScreen({super.key});

  @override
  _StripeScreenState createState() => _StripeScreenState();
}

class _StripeScreenState extends State<StripeScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stripe Payment')),
      body: Consumer<StripeViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stripe logo
                    PaymentLogo(
                      logoUrl:
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Stripe_Logo%2C_revised_2016.svg/2560px-Stripe_Logo%2C_revised_2016.svg.png',
                    ),
                    const SizedBox(height: 30),

                    // Payment method selector card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12.0,
                              left: 16.0,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Select Payment Method',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          RadioListTile<PaymentMethod>(
                            title: const Text('Payment Sheet'),
                            subtitle: const Text(
                              'Use Stripe\'s payment sheet interface',
                            ),
                            value: PaymentMethod.paymentSheet,
                            groupValue: viewModel.selectedPaymentMethod,
                            onChanged: (value) {
                              if (value != null) {
                                viewModel.setPaymentMethod(value);
                              }
                            },
                          ),
                          RadioListTile<PaymentMethod>(
                            title: const Text('Card Field'),
                            subtitle: const Text(
                              'Enter your card details directly',
                            ),
                            value: PaymentMethod.card,
                            groupValue: viewModel.selectedPaymentMethod,
                            onChanged: (value) {
                              if (value != null) {
                                viewModel.setPaymentMethod(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card input field
                    if (viewModel.selectedPaymentMethod == PaymentMethod.card)
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Card Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Card input field - uses the native Stripe CardField
                            CardField(
                              onCardChanged: (details) {
                                if (details != null) {
                                  viewModel.updateCardDetails(details);
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: 'Card Details',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (viewModel.cardFieldInputDetails != null)
                              Text(
                                viewModel.isCardValid
                                    ? 'Card is valid'
                                    : 'Complete the card details',
                                style: TextStyle(
                                  color:
                                      viewModel.isCardValid
                                          ? Colors.green
                                          : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Product details summary
                    ProductDetails(selectedCurrency: 'USD', amount: '100.00'),
                    const SizedBox(height: 24),

                    // Pay button with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            viewModel.isCardValid && !viewModel.isLoading
                                ? () async {
                                  if (_formKey.currentState!.validate()) {
                                    await viewModel.makePayment(
                                      context: context,
                                    );

                                    if (viewModel.successMsg != null) {
                                      debugPrint(
                                        'Success: ${viewModel.successMsg}',
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${viewModel.successMsg!}',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      viewModel.reset();
                                    } else if (viewModel.error != null) {
                                      debugPrint('Error: ${viewModel.error}');
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error: ${viewModel.error}',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledForegroundColor: Colors.white.withOpacity(
                            0.5,
                          ),
                          disabledBackgroundColor: Colors.deepPurpleAccent
                              .withOpacity(0.5),
                        ),
                        child:
                            viewModel.isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  'Pay with Stripe',
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ),

                    if (viewModel.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          '${viewModel.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
