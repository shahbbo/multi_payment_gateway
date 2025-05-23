// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// import '../../viewmodels/paymob_viewmodel.dart';
// import '../../widgets/payment_logo.dart';
// import '../../widgets/product_details.dart';
//
// class LowLevelPaymobScreen extends StatefulWidget {
//   bool isCheckout;
//   LowLevelPaymobScreen({super.key, this.isCheckout = false});
//
//   @override
//   _LowLevelPaymobScreenState createState() => _LowLevelPaymobScreenState();
// }
//
// class _LowLevelPaymobScreenState extends State<LowLevelPaymobScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<PaymobViewModel>(
//       builder: (context, viewModel, child) {
//         return _buildPayMobForm();
//       },
//     );
//   }
//
//   Widget _buildPayMobForm() {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Paymob Payment')),
//       body: Consumer<PaymobViewModel>(
//         builder: (context, viewModel, child) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   PaymentLogo(
//                     logoUrl:
//                         'https://cdn.wamda.com/feature-images/2d48051bc1fd9f5.png',
//                   ),
//                   // Payment options
//                   const Text(
//                     'Payment Options',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//
//                   // Payment method choices
//                   Card(
//                     child: Column(
//                       children: [
//                         RadioListTile<PaymentMethod>(
//                           title: const Text('Credit Card'),
//                           value: PaymentMethod.card,
//                           groupValue: viewModel.selectedPaymentMethod,
//                           onChanged: (value) {
//                             if (value != null) {
//                               viewModel.setPaymentMethod(value);
//                             }
//                           },
//                         ),
//                         RadioListTile<PaymentMethod>(
//                           title: const Text('Mobile Wallet'),
//                           value: PaymentMethod.wallet,
//                           groupValue: viewModel.selectedPaymentMethod,
//                           onChanged: (value) {
//                             if (value != null) {
//                               viewModel.setPaymentMethod(value);
//                             }
//                           },
//                         ),
//                         RadioListTile<PaymentMethod>(
//                           title: const Text('Kiosk'),
//                           value: PaymentMethod.kiosk,
//                           groupValue: viewModel.selectedPaymentMethod,
//                           onChanged: (value) {
//                             if (value != null) {
//                               viewModel.setPaymentMethod(value);
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Product details card
//                   ProductDetails(selectedCurrency: 'EGP', amount: '16000'),
//                   const Spacer(),
//
//                   // Checkout button with animation
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     height: 50,
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed:
//                           viewModel.isLoading
//                               ? null
//                               : () {
//                                 if (_formKey.currentState!.validate()) {
//                                   context.go('/paymob/paymob-checkout');
//                                 }
//                               },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blueAccent,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child:
//                           viewModel.isLoading
//                               ? const CircularProgressIndicator(
//                                 color: Colors.white,
//                               )
//                               : const Text(
//                                 'Proceed to Checkout',
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                     ),
//                   ),
//
//                   if (viewModel.errorMessage != null) ...[
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade100,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         viewModel.errorMessage!,
//                         style: TextStyle(color: Colors.red.shade900),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   WebViewController? _controller;
//   bool _isLoading = true;
//
//   /*  @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _startPayment();
//     });
//   }*/
//
//   Widget _buildPayMobCheckout(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Paymob Payment'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.pop(),
//         ),
//       ),
//       body: Consumer<PaymobViewModel>(
//         builder: (context, viewModel, child) {
//           if (viewModel.isLoading || _isLoading) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading payment...'),
//                 ],
//               ),
//             );
//           }
//
//           if ((viewModel.selectedPaymentMethod == PaymentMethod.card ||
//                   viewModel.selectedPaymentMethod == PaymentMethod.wallet) &&
//               _controller != null) {
//             return WebViewWidget(controller: _controller!);
//           }
//
//           if (viewModel.selectedPaymentMethod == PaymentMethod.kiosk) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'يرجى الاحتفاظ برقم المرجع التالي وزيارة أقرب منفذ أو مكينة Fawry أو Aman.',
//                       style: TextStyle(fontSize: 20),
//                     ),
//                     SizedBox(height: 30),
//                     Text(
//                       viewModel.billReference!.toString(),
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     IconButton(
//                       onPressed: () {
//                         context.copyToClipboard(
//                           viewModel.billReference.toString(),
//                         );
//                       },
//                       icon: const Icon(Icons.copy),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//           return const Center(child: Text('Failed to load payment method.'));
//         },
//       ),
//     );
//   }
//
//   Future<void> _startPayment() async {
//     final viewModel = Provider.of<PaymobViewModel>(context, listen: false);
//     final success = await viewModel.initiatePayment();
//
//     if (!success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(viewModel.errorMessage ?? 'Failed to initiate payment'),
//         ),
//       );
//       Future.delayed(const Duration(seconds: 2), () {
//         context.pop();
//       });
//       return;
//     }
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     switch (viewModel.selectedPaymentMethod) {
//       case PaymentMethod.card:
//         _setupCardPayment(viewModel.iframeUrl!);
//         break;
//       case PaymentMethod.wallet:
//         _setupWalletPayment(viewModel.redirectUrl!);
//         break;
//       case PaymentMethod.kiosk:
//         break;
//     }
//   }
//
//   void _setupCardPayment(String url) {
//     _controller =
//         WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..setNavigationDelegate(
//             NavigationDelegate(
//               onNavigationRequest: (NavigationRequest request) {
//                 if (request.url.contains('success=true')) {
//                   _showPaymentSuccess();
//                   return NavigationDecision.prevent;
//                 }
//                 if (request.url.contains('success=false')) {
//                   _showPaymentFailure();
//                   return NavigationDecision.prevent;
//                 }
//                 return NavigationDecision.navigate;
//               },
//             ),
//           )
//           ..loadRequest(Uri.parse(url));
//   }
//
//   void _setupWalletPayment(String url) {
//     _controller =
//         WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..setNavigationDelegate(
//             NavigationDelegate(
//               onNavigationRequest: (NavigationRequest request) {
//                 // التعامل مع إعادة التوجيه بعد الدفع
//                 if (request.url.contains('success=true')) {
//                   _showPaymentSuccess();
//                   return NavigationDecision.prevent;
//                 }
//                 if (request.url.contains('success=false')) {
//                   _showPaymentFailure();
//                   return NavigationDecision.prevent;
//                 }
//                 return NavigationDecision.navigate;
//               },
//             ),
//           )
//           ..loadRequest(Uri.parse(url));
//   }
//
//   void _showPaymentSuccess() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Payment successful!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//     Future.delayed(const Duration(seconds: 2), () {
//       context.go('/');
//     });
//   }
//
//   void _showPaymentFailure() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Failed to process payment.'),
//         backgroundColor: Colors.red,
//       ),
//     );
//     Future.delayed(const Duration(seconds: 2), () {
//       context.pop();
//     });
//   }
// }
//
// extension on BuildContext {
//   void copyToClipboard(String string) {
//     final data = ClipboardData(text: string);
//     Clipboard.setData(data);
//     ScaffoldMessenger.of(
//       this,
//     ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../viewmodels/paymob_viewmodel.dart';
import '../../widgets/payment_logo.dart';
import '../../widgets/product_details.dart';

class LowLevelPaymobScreen extends StatefulWidget {
  const LowLevelPaymobScreen({super.key});

  @override
  _LowLevelPaymobScreenState createState() => _LowLevelPaymobScreenState();
}

class _LowLevelPaymobScreenState extends State<LowLevelPaymobScreen> {
  final _formKey = GlobalKey<FormState>();
  WebViewController? _controller;
  bool _isLoading = true;

  bool checkout = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymobViewModel>(
      builder: (context, viewModel, child) {
        if (checkout) {
          return _buildPayMobCheckout();
        } else {
          return _buildPayMobForm();
        }
      },
    );
  }

  Widget _buildPayMobForm() {
    return Scaffold(
      appBar: AppBar(title: const Text('Paymob Payment')),
      body: Consumer<PaymobViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
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
                        RadioListTile<PaymentMethod>(
                          title: const Text('Credit Card'),
                          value: PaymentMethod.card,
                          groupValue: viewModel.selectedPaymentMethod,
                          onChanged: (value) {
                            if (value != null) {
                              viewModel.setPaymentMethod(value);
                            }
                          },
                        ),
                        RadioListTile<PaymentMethod>(
                          title: const Text('Mobile Wallet'),
                          value: PaymentMethod.wallet,
                          groupValue: viewModel.selectedPaymentMethod,
                          onChanged: (value) {
                            if (value != null) {
                              viewModel.setPaymentMethod(value);
                            }
                          },
                        ),
                        RadioListTile<PaymentMethod>(
                          title: const Text('Kiosk'),
                          value: PaymentMethod.kiosk,
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
                  const SizedBox(height: 16),

                  // Product details card
                  ProductDetails(selectedCurrency: 'EGP', amount: '16000'),
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
                              : () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    checkout = true;
                                    _startPayment();
                                  });
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          viewModel.isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Pay with Paymob',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),

                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        viewModel.errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPayMobCheckout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paymob Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => setState(() {
                checkout = false;
              }),
        ),
      ),
      body: Consumer<PaymobViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading || _isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading payment...'),
                ],
              ),
            );
          }

          // Card Or Wallet Payment
          if ((viewModel.selectedPaymentMethod == PaymentMethod.card ||
                  viewModel.selectedPaymentMethod == PaymentMethod.wallet) &&
              _controller != null) {
            return WebViewWidget(controller: _controller!);
          }

          //Kiosk Payment
          if (viewModel.selectedPaymentMethod == PaymentMethod.kiosk) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'يرجى الاحتفاظ برقم المرجع التالي وزيارة أقرب منفذ أو مكينة Fawry أو Aman.',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      viewModel.billReference?.toString() ??
                          'No reference available',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      onPressed: () {
                        if (viewModel.billReference != null) {
                          context.copyToClipboard(
                            viewModel.billReference.toString(),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),
              ),
            );
          }

          //Failed
          return const Center(child: Text('Failed to load payment method.'));
        },
      ),
    );
  }

  Future<void> _startPayment() async {
    final viewModel = Provider.of<PaymobViewModel>(context, listen: false);
    final success = await viewModel.initiatePayment();

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.errorMessage ?? 'Failed to initiate payment',
            ),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.pop();
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    switch (viewModel.selectedPaymentMethod) {
      case PaymentMethod.card:
        if (viewModel.iframeUrl != null) {
          _setupCardPayment(viewModel.iframeUrl!);
        }
        break;
      case PaymentMethod.wallet:
        if (viewModel.redirectUrl != null) {
          _setupWalletPayment(viewModel.redirectUrl!);
        }
        break;
      case PaymentMethod.kiosk:
        // كيوسك لا يحتاج إعداداً إضافياً
        break;
    }
  }

  void _setupCardPayment(String url) {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.contains('success=true')) {
                  _showPaymentSuccess();
                  return NavigationDecision.navigate;
                }
                if (request.url.contains('success=false')) {
                  _showPaymentFailure();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(url));
  }

  void _setupWalletPayment(String url) {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                // التعامل مع إعادة التوجيه بعد الدفع
                if (request.url.contains('success=true')) {
                  _showPaymentSuccess();
                  return NavigationDecision.prevent;
                }
                if (request.url.contains('success=false')) {
                  _showPaymentFailure();
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(url));
  }

  void _showPaymentSuccess() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/');
      });
    }
  }

  void _showPaymentFailure() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to process payment.'),
          backgroundColor: Colors.red,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.pop();
      });
    }
  }
}

extension on BuildContext {
  void copyToClipboard(String string) {
    final data = ClipboardData(text: string);
    Clipboard.setData(data);
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
  }
}
