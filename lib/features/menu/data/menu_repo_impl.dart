import 'package:dushka_burger/core/error/exception.dart';
import 'package:dushka_burger/core/error/failure.dart';
import 'package:dushka_burger/features/menu/data/menu_remote_ds.dart';
import 'package:dushka_burger/features/menu/data/mappers.dart';
import 'package:dushka_burger/features/menu/domain/entities.dart';
import 'package:dushka_burger/features/menu/domain/menu_repo.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remote;

  MenuRepositoryImpl(this.remote);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final dtos = await remote.getCategories();
      return dtos.map((c) => c.toEntity()).toList();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(
        e.message ?? 'error : UnauthorizedFailure-getCategories : null message',
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: 'Server Failure: ${e.message}');
    } on ParsingException catch (e) {
      throw ParsingFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<Product> getProductDetails(int productId) async {
    try {
      final dto = await remote.getProductDetails(productId);
      return dto.toEntity();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(
        e.message ??
            'error : UnauthorizedFailure-getProductDetails : null message',
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: 'Server Failure: ${e.message}');
    } on ParsingException catch (e) {
      throw ParsingFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<ProductAddons> getProductAddons(int productId) async {
    try {
      final dto = await remote.getProductAddons(productId);
      return dto.toEntity();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(
        e.message ??
            'error : UnauthorizedFailure-getProductAddons : null message',
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: 'Server Failure: ${e.message}');
    } on ParsingException catch (e) {
      throw ParsingFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
