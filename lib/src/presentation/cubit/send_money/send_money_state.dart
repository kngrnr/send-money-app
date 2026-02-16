abstract class SendMoneyState {}

class SendMoneyInitial extends SendMoneyState {}

class SendMoneyLoading extends SendMoneyState {}

class SendMoneySuccess extends SendMoneyState {
  final String message;
  final String? transactionId;

  SendMoneySuccess({
    required this.message,
    this.transactionId,
  });
}

class SendMoneyError extends SendMoneyState {
  final String message;

  SendMoneyError({required this.message});
}
