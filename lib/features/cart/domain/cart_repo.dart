import 'package:dushka_burger/features/cart/data/models.dart';
import 'package:dushka_burger/features/cart/data/cart_remote_ds.dart';

abstract class CartRepository {
  Future<CartDto> getCart(String guestId);

  Future<CartDto> addToCart({
    required String guestId,
    required List<AddCartItemRequest> items,
  });

  Future<CartDto> deleteFromCart({
    required String guestId,
    required int productId,
    required int quantity,
    int? variationId,
    List<AddCartAddonRequest> addons = const [],
  });
}
