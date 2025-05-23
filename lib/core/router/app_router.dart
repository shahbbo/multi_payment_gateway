import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/payment/views/home_screen.dart';
import '../../features/payment/views/paymob/pay_mob_screen.dart';
import '../../features/payment/views/paypal/lowlevel_paypal_screen.dart';
import '../../features/payment/views/paypal/paypal_screen.dart';
import '../../features/payment/views/paymob/lowlevel_paymob_screen.dart';
import '../../features/payment/views/stripe/stripe_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorPaypalKey = GlobalKey<NavigatorState>(
    debugLabel: 'shellPaypal',
  );
  static final _shellNavigatorPaymobKey = GlobalKey<NavigatorState>(
    debugLabel: 'shellPaymob',
  );
  static final _shellNavigatorStripeKey = GlobalKey<NavigatorState>(
    debugLabel: 'shellStripe',
  );

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeScreen(navigationShell: navigationShell);
        },
        branches: [
          // Paypal Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorPaypalKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: PaypalScreen()),
                routes: [],
              ),
            ],
          ),
          // Paymob Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorPaymobKey,
            routes: [
              GoRoute(
                path: '/paymob',
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: LowLevelPaymobScreen()),
                routes: [],
              ),
            ],
          ),
          // Stripe Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorStripeKey,
            routes: [
              GoRoute(
                path: '/stripe',
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: StripeScreen()),
                routes: [],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
