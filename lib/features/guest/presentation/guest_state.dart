
import 'package:equatable/equatable.dart';
import 'package:dushka_burger/constants/enums.dart';

class GuestState extends Equatable {
  final Status status;
  final String guestId;
  final String errorMessage;

  const GuestState({
    required this.status,
    required this.guestId,
    required this.errorMessage,
  });

  factory GuestState.initial() => const GuestState(
        status: Status.initial,
        guestId: '',
        errorMessage: '',
      );

  GuestState copyWith({
    Status? status,
    String? guestId,
    String? errorMessage,
  }) {
    return GuestState(
      status: status ?? this.status,
      guestId: guestId ?? this.guestId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, guestId, errorMessage];
}