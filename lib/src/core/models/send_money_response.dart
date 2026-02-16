class SendMoneyResponse {
  final String message;
  final bool success;
  final String? transactionId;

  SendMoneyResponse({
    required this.message,
    required this.success,
    this.transactionId,
  });

  factory SendMoneyResponse.fromJson(Map<String, dynamic> json) {
    return SendMoneyResponse(
      message: json['message'] as String? ?? '',
      success: json['success'] as bool? ?? false,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'transactionId': transactionId,
    };
  }
}
