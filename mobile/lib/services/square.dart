import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:errand_share/data/database.dart';
import 'package:errand_share/data/Payment.dart';
import 'package:http/http.dart' as http;
//import 'dart:html';
import 'dart:convert';

class Square {
  static final Square _instance = Square._internal();
  factory Square() => _instance;
  Square._internal() {
    _init();
  }

  int amount;

  Future<void> _init() async {
    await InAppPayments.
      setSquareApplicationId('sandbox-sq0idb-QDF61H5hSki0NHwpqtP8gQ');
  }

  // Let's us explicitly ignore the result from an async function
  void unawaited(Future<void> future) {}



  void createPayment(int amount) async {
    amount = amount;
    await _onStartCardEntryFlow();
  }

  // Event listener to start card entry flow for payment
  Future<void> _onStartCardEntryFlow() async {
    await InAppPayments.startCardEntryFlow(
      onCardNonceRequestSuccess: _onCardEntryCardNonceRequestSuccess,
      onCardEntryCancel: _onCancelCardEntryFlow);
  }

  // Callback when entry is cancelled and UI closes
  void _onCancelCardEntryFlow() {
    //Handle a cancellation
  }

  // Callback when card nonce details are received.
  // Still waiting for processing details.
  void _onCardEntryCardNonceRequestSuccess(CardDetails result) async {
    try {
      // Record payment in database.
      final payment = await Database().createNewPayment(
        Payment(fromID: 'sandbox1', toID: 'sandbox2', amount: '${amount}'));

      print(result.nonce);

      _createPaymentRequest(result, payment.paymentId);

      // Payment finished. Closes card entry.
      unawaited(InAppPayments.completeCardEntry(
        onCardEntryComplete: _onCardEntryComplete));

    } on Exception catch (ex) {
      //Payment failed to complete
      unawaited(InAppPayments.showCardNonceProcessingError('${ex}'));
    }
  }

  //Callback when the ccard entry is closed after entry completed
  void _onCardEntryComplete() {
    //Update UI to finish flow.
  }

  void _createPaymentRequest(CardDetails card, String paymentid){
    // Create encodable version of request body.
    var data = {
      'idempotency_key': paymentid,
      'amount_money': {
        'amount': amount,
        'currency': 'USD',
      },
      'source_id': card.nonce,
    };

    http.post(
        'https://connect.squareup.com/v2/payments',
        headers: {
          'Square-Version': '2020-07-22',
          'Authorization': 'Bearer QDF61H5hSki0NHwpqtP8gQ',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      ).then((result) => print('${result.statusCode}: ${result.body}'));
  }
}
