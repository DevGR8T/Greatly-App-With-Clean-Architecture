import 'package:equatable/equatable.dart';

enum PaymentStatus {
  success,
  failed,
  pending,
  cancelled,
}

class PaymentResult extends Equatable {
  final PaymentStatus status;
  final String? paymentId;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const PaymentResult({
    required this.status,
    this.paymentId,
    this.errorMessage,
    this.metadata,
  });

  @override
  List<Object?> get props => [status, paymentId, errorMessage, metadata];
}
