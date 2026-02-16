import 'package:injectable/injectable.dart';
import 'package:send_money_app/src/core/models/send_money_response.dart';
import 'package:send_money_app/src/core/network/api_service.dart';

abstract class SendMoneyRepository {
  /// Send money to a recipient
  Future<SendMoneyResponse> sendMoney({
    required String recipientUsername,
    required double amount,
  });
}

@LazySingleton(as: SendMoneyRepository)
class SendMoneyRepositoryImpl implements SendMoneyRepository {
  final ApiService apiService;

  SendMoneyRepositoryImpl(this.apiService);

  @override
  Future<SendMoneyResponse> sendMoney({
    required String recipientUsername,
    required double amount,
  }) async {
    final data = await apiService.post(
      '/api/send',
      data: {
        'recipientUsername': recipientUsername,
        'amount': amount,
      },
    );

    return SendMoneyResponse.fromJson(data as Map<String, dynamic>);
  }
}
