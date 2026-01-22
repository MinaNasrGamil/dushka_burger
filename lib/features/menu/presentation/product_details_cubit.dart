import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dushka_burger/constants/enums.dart';
import 'package:dushka_burger/features/menu/domain/entities.dart';
import 'package:dushka_burger/features/menu/domain/usecases.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductDetails getProductDetails;
  final GetProductAddons getProductAddons;

  ProductDetailsCubit({
    required this.getProductDetails,
    required this.getProductAddons,
  }) : super(ProductDetailsState.initial());

  /// Convenience: load product then addons (addons can fail without blocking product view)
  Future<void> load(int productId) async {
    await fetchProduct(productId);
    await fetchAddons(productId);
  }

  Future<void> fetchProduct(int productId) async {
    emit(state.copyWith(status: Status.loading, errorMessage: ''));

    try {
      final product = await getProductDetails(productId);

      // If variable: auto-select a variation (best effort)
      int? initialVariationId;
      if (product is VariableProduct && product.variations.isNotEmpty) {
        // Try to select by defaultSize if provided, else first variation.
        final ds = product.defaultSize.trim().toLowerCase();
        final match = product.variations.where(
          (v) => v.size.toLowerCase() == ds,
        );
        initialVariationId = match.isNotEmpty
            ? match.first.id
            : product.variations.first.id;
      }

      emit(
        state.copyWith(
          status: Status.success,
          product: product,
          quantity: 1,
          selectedVariationId: initialVariationId,
          selectedAddonsByGroup: {}, // reset selections on new product
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: Status.error, errorMessage: e.toString()));
    }
  }

  Future<void> fetchAddons(int productId) async {
    emit(state.copyWith(addonsStatus: Status.loading));

    try {
      final addons = await getProductAddons(productId);

      // addons.product may exist, but we rely mainly on groups here.
      emit(
        state.copyWith(
          addonsStatus: Status.success,
          addonGroups: addons.groups,
        ),
      );
    } catch (e) {
      // Don’t block product view; mark addons as error.
      emit(state.copyWith(addonsStatus: Status.error));
    }
  }

  // ---------- Quantity ----------
  void incQty() {
    if (state.selectedAddonOptions.isNotEmpty) return; // addons => force qty=1
    emit(state.copyWith(quantity: state.quantity + 1));
  }

  void decQty() {
    if (state.selectedAddonOptions.isNotEmpty) return; // addons => force qty=1
    if (state.quantity <= 1) return;
    emit(state.copyWith(quantity: state.quantity - 1));
  }

  // ---------- Variation ----------
  void selectVariation(int variationId) {
    emit(state.copyWith(selectedVariationId: variationId));
  }

  // ---------- Addons ----------
  void toggleAddon({required int groupIndex, required int optionId}) {
    if (groupIndex < 0 || groupIndex >= state.addonGroups.length) return;

    final group = state.addonGroups[groupIndex];

    // Clone map safely (immutable update)
    final newMap = Map<int, Set<int>>.fromEntries(
      state.selectedAddonsByGroup.entries.map(
        (e) => MapEntry(e.key, Set<int>.from(e.value)),
      ),
    );

    final current = newMap[groupIndex] ?? <int>{};

    if (group.multiChoice) {
      // Checkbox behavior
      if (current.contains(optionId)) {
        current.remove(optionId);
      } else {
        current.add(optionId);
      }
      newMap[groupIndex] = current;
    } else {
      // Radio behavior (single choice)
      if (current.contains(optionId)) {
        // Allow unselect (optional UX). If you want strict radio, remove this branch.
        newMap[groupIndex] = <int>{};
      } else {
        newMap[groupIndex] = <int>{optionId};
      }
    }

    _enforceQtyForAddons();
    emit(state.copyWith(selectedAddonsByGroup: newMap));
  }

  void _enforceQtyForAddons() {
    if (state.selectedAddonOptions.isNotEmpty && state.quantity != 1) {
      emit(state.copyWith(quantity: 1));
    }
  }

  void clearAddons() {
    emit(state.copyWith(selectedAddonsByGroup: {}));
    // user can change qty again normally after clearing addons
  }
}
