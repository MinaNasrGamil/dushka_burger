import 'package:dushka_burger/core/error/exception.dart';
import 'package:dushka_burger/core/error/failure.dart';
import 'package:dushka_burger/features/cart/data/cart_remote_ds.dart';
import 'package:dushka_burger/features/cart/data/models.dart';
import 'package:dushka_burger/features/cart/domain/cart_repo.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remote;

  CartRepositoryImpl(this.remote);

  @override
  Future<CartDto> getCart(String guestId) async {
    try {
      return await remote.getCart(guestId);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message ?? 'UnKnown');
    } on ServerException catch (e) {
      throw ServerFailure(message:  e.message ?? 'UnKnown');
    } on ParsingException catch (e) {
      throw ParsingFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<CartDto> addToCart({
    required String guestId,
    required List<AddCartItemRequest> items,
  }) async {
    try {
      return await remote.addToCart(guestId: guestId, items: items);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message ??'UnKnown');
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message ?? 'UnKnown');
    } on ParsingException catch (e) {
      throw ParsingFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<CartDto> deleteFromCart({
    required String guestId,
    required int productId,
    required int quantity,
    int? variationId,
    List<AddCartAddonRequest> addons = const [],
  }) async {
    try {
      return await remote.deleteFromCart(
        guestId: guestId,
        productId: productId,
        quantity: quantity,
        variationId: variationId,
        addons: addons,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message ?? 'UnKnown');
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message ?? 'UnKnown');
    } on ParsingException catch (e) {
      throw ParsingFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
