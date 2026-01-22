import 'package:dushka_burger/features/cart/data/cart_remote_ds.dart';
import 'package:dushka_burger/features/cart/data/models.dart';
import 'package:dushka_burger/features/cart/domain/cart_repo.dart';

class GetCart {
  final CartRepository repo;
  GetCart(this.repo);

  Future<CartDto> call(String guestId) {
    return repo.getCart(guestId);
  }
}

class AddToCart {
  final CartRepository repo;
  AddToCart(this.repo);

  Future<CartDto> call({
    required String guestId,
    required List<AddCartItemRequest> items,
  }) {
    return repo.addToCart(guestId: guestId, items: items);
  }
}

class DeleteFromCart {
  final CartRepository repo;
  DeleteFromCart(this.repo);

  Future<CartDto> call({
    required String guestId,
    required int productId,
    required int quantity,
    int? variationId,
    List<AddCartAddonRequest> addons = const [],
  }) {
    return repo.deleteFromCart(
      guestId: guestId,
      productId: productId,
      quantity: quantity,
      variationId: variationId,
      addons: addons,
    );
  }
}
