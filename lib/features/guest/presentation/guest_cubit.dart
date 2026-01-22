
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dushka_burger/constants/enums.dart';
import 'package:dushka_burger/features/guest/domain/get_guest_id.dart';
import 'guest_state.dart';

class GuestCubit extends Cubit<GuestState> {
  final GetGuestId getGuestId;

  GuestCubit(this.getGuestId) : super(GuestState.initial());

  Future<void> init() async {
    emit(state.copyWith(status: Status.loading, errorMessage: ''));

    try {
      final id = await getGuestId();
      emit(state.copyWith(status: Status.success, guestId: id));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }
}
