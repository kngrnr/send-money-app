import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:send_money_app/src/core/network/app_exception.dart';
import 'package:send_money_app/src/data/usecases/send_money_usecase.dart';
import 'package:send_money_app/src/presentation/cubit/send_money/send_money_state.dart';

class SendMoneyCubit extends Cubit<SendMoneyState> {
  final SendMoneyUseCase sendMoneyUseCase;

  SendMoneyCubit({required this.sendMoneyUseCase}) : super(SendMoneyInitial());

  Future<void> sendMoney({
    required String recipientUsername,
    required double amount,
  }) async {
    emit(SendMoneyLoading());
    try {
      final response = await sendMoneyUseCase.execute(
        recipientUsername: recipientUsername,
        amount: amount,
      );
      emit(SendMoneySuccess(
        message: response.message,
        transactionId: response.transactionId,
      ));
    } on AppException catch (e) {
      emit(SendMoneyError(message: e.message));
    } catch (e) {
      emit(SendMoneyError(message: e.toString()));
    }
  }
}
