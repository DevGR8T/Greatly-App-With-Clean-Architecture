import '../../domain/entities/payment_result.dart';

class PaymentResultModel extends PaymentResult {
  const PaymentResultModel({
    required super.status,
    super.paymentId,
    super.errorMessage,
    super.metadata,
  });

  factory PaymentResultModel.fromJson(Map<String, dynamic> json) {
    return PaymentResultModel(
      status: _mapStringToPaymentStatus(json['status']),
      paymentId: json['paymentId'],
      errorMessage: json['errorMessage'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': _mapPaymentStatusToString(status),
      'paymentId': paymentId,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  static PaymentStatus _mapStringToPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'pending':
        return PaymentStatus.pending;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        return PaymentStatus.pending;
    }
  }

  static String _mapPaymentStatusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.success:
        return 'success';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.cancelled:
        return 'cancelled';
    }
  }
}