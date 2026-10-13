abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final String message;
  CheckoutSuccess(this.message);
}

class CheckoutError extends CheckoutState {
  final String message;
  CheckoutError(this.message);
}

class CheckoutCalculated extends CheckoutState {
  final double deposit;
  final double finalCharges;
  final double damageFees;
  final double refundAmount;

  CheckoutCalculated({
    required this.deposit,
    required this.finalCharges,
    required this.damageFees,
    required this.refundAmount,
  });
}
