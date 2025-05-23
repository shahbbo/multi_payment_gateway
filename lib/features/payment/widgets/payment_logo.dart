import 'package:flutter/material.dart';

class PaymentLogo extends StatelessWidget {
  const PaymentLogo({super.key, required this.logoUrl});

  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Container(
        height: 100,
        alignment: Alignment.center,
        child: Image.network(logoUrl, height: 80),
      ),
    );
  }
}
