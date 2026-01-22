
import 'package:equatable/equatable.dart';
import 'package:dushka_burger/constants/enums.dart';
import 'package:dushka_burger/features/menu/domain/entities.dart';

class CategoriesState extends Equatable {
  final Status status;
  final String errorMessage;
  final List<Category> categories;

  const CategoriesState({
    required this.status,
    required this.errorMessage,
    required this.categories,
  });

  factory CategoriesState.initial() => const CategoriesState(
        status: Status.initial,
        errorMessage: '',
        categories: [],
      );

  CategoriesState copyWith({
    Status? status,
    String? errorMessage,
    List<Category>? categories,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, categories];
}
