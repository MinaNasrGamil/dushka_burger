import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dushka_burger/constants/enums.dart';
import 'package:dushka_burger/features/cart/data/cart_remote_ds.dart'; // for AddCartItemRequest, AddCartAddonRequest
import 'package:dushka_burger/features/cart/domain/usecases.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCart getCart;
  final AddToCart addToCart;
  final DeleteFromCart deleteFromCart;

  CartCubit({
    required this.getCart,
    required this.addToCart,
    required this.deleteFromCart,
  }) : super(CartState.initial());

  Future<void> fetchCart(String guestId) async {
    emit(state.copyWith(status: Status.loading, errorMessage: ''));

    try {
      final cart = await getCart(guestId);
      emit(
        state.copyWith(
          status: Status.success,
          cart: cart,
          subtotal: cart.subtotal,
          vat: cart.vat,
          total: cart.totalWithTax,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  /// Adds item then refreshes cart (always reflects server state). [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)
  Future<void> addItem({
    required String guestId,
    required int productId,
    required int quantity,
    int? variationId,
    List<AddCartAddonRequest> addons = const [],
  }) async {
    emit(state.copyWith(status: Status.loading, errorMessage: ''));

    try {
      final updated = await addToCart(
        guestId: guestId,
        items: [
          AddCartItemRequest(
            productId: productId,
            quantity: quantity,
            variationId: variationId,
            addons: addons,
          ),
        ],
      );

      // If API returns updated cart, use it immediately.
      emit(
        state.copyWith(
          status: Status.success,
          cart: updated,
          subtotal: updated.subtotal,
          vat: updated.vat,
          total: updated.totalWithTax,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  /// Deletes quantity from an item then refreshes cart. [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)
  Future<void> removeItem({
    required String guestId,
    required int productId,
    required int quantity,
    int? variationId,
    List<AddCartAddonRequest> addons = const [],
  }) async {
    emit(state.copyWith(status: Status.loading, errorMessage: ''));

    try {
      final updated = await deleteFromCart(
        guestId: guestId,
        productId: productId,
        quantity: quantity,
        variationId: variationId,
        addons: addons,
      );

      emit(
        state.copyWith(
          status: Status.success,
          cart: updated,
          subtotal: updated.subtotal,
          vat: updated.vat,
          total: updated.totalWithTax,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> addToCartDirect({
    required String guestId,
    required List<AddCartItemRequest> items,
  }) async {
    emit(state.copyWith(status: Status.loading, errorMessage: ''));
    try {
      await addToCart(guestId: guestId, items: items);
      final refreshed = await getCart(guestId);
      emit(
        state.copyWith(
          status: Status.success,
          cart: refreshed,
          subtotal: refreshed.subtotal,
          vat: refreshed.vat,
          total: refreshed.totalWithTax,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }
  
}
