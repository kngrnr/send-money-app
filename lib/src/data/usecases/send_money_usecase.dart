import 'package:send_money_app/src/core/models/send_money_response.dart';
import 'package:send_money_app/src/data/repositories/send_money_repository.dart';

class SendMoneyUseCase {
  final SendMoneyRepository repository;

  SendMoneyUseCase(this.repository);

  /// Send money to a recipient
  Future<SendMoneyResponse> execute({
    required String recipientUsername,
    required double amount,
  }) {
    return repository.sendMoney(
      recipientUsername: recipientUsername,
      amount: amount,
    );
  }
}
