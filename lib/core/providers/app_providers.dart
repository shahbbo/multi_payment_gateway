import '../../features/payment/viewmodels/paypal_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../features/payment/viewmodels/paymob_viewmodel.dart';
import '../../features/payment/viewmodels/stripe_viewmodel.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider(create: (_) => PaypalViewModel()),
    ChangeNotifierProvider(create: (_) => PaymobViewModel()),
    ChangeNotifierProvider(create: (_) => StripeViewModel()),
  ];
}
