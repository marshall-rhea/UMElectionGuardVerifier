import 'package:errand_share/data/Payment.dart';

//should be on serverside
class PaymentsRepo {
  static String actuallyMakeTheCharge(String nonce) {
    print('about to make the charge');
    return 'charging';
  }
}
