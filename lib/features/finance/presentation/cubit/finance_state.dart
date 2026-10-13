import 'package:equatable/equatable.dart';
import '../../data/models/fund_record_model.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceActionSuccess extends FinanceState {
  final String message;
  final FundRecordModel? fundRecord;

  const FinanceActionSuccess({
    required this.message,
    this.fundRecord,
  });

  @override
  List<Object?> get props => [message, fundRecord];
}

class FinanceError extends FinanceState {
  final String message;

  const FinanceError(this.message);

  @override
  List<Object?> get props => [message];
}
