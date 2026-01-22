
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dushka_burger/constants/enums.dart';
import 'package:dushka_burger/features/menu/domain/usecases.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategories getCategories;

  CategoriesCubit(this.getCategories) : super(CategoriesState.initial());

  Future<void> fetchCategories() async {
    emit(state.copyWith(status: Status.loading, errorMessage: ''));

    try {
      final result = await getCategories();
      emit(state.copyWith(status: Status.success, categories: result));
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }
}
