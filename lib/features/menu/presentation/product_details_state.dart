import 'package:equatable/equatable.dart';
import 'package:dushka_burger/constants/enums.dart';
import 'package:dushka_burger/features/menu/domain/entities.dart';

class ProductDetailsState extends Equatable {
  // Main loading status (product)
  final Status status;

  // Addons loading status (independent so product can show even if addons fail)
  final Status addonsStatus;

  final String errorMessage;

  final Product? product;
  final List<AddonGroup> addonGroups;

  final int quantity;

  // Variable product selection
  final int? selectedVariationId;

  // Addon selections:
  // key = addon group index in addonGroups
  // value = set of selected option IDs (single choice => size 1, multi => many)
  final Map<int, Set<int>> selectedAddonsByGroup;

  const ProductDetailsState({
    required this.status,
    required this.addonsStatus,
    required this.errorMessage,
    required this.product,
    required this.addonGroups,
    required this.quantity,
    required this.selectedVariationId,
    required this.selectedAddonsByGroup,
  });

  factory ProductDetailsState.initial() => const ProductDetailsState(
    status: Status.initial,
    addonsStatus: Status.initial,
    errorMessage: '',
    product: null,
    addonGroups: [],
    quantity: 1,
    selectedVariationId: null,
    selectedAddonsByGroup: {},
  );

  ProductDetailsState copyWith({
    Status? status,
    Status? addonsStatus,
    String? errorMessage,
    Product? product,
    List<AddonGroup>? addonGroups,
    int? quantity,
    int? selectedVariationId,
    Map<int, Set<int>>? selectedAddonsByGroup,
  }) {
    return ProductDetailsState(
      status: status ?? this.status,
      addonsStatus: addonsStatus ?? this.addonsStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      product: product ?? this.product,
      addonGroups: addonGroups ?? this.addonGroups,
      quantity: quantity ?? this.quantity,
      selectedVariationId: selectedVariationId ?? this.selectedVariationId,
      selectedAddonsByGroup:
          selectedAddonsByGroup ?? this.selectedAddonsByGroup,
    );
  }

  // ---------- Helpers (UI convenience) ----------

  bool get hasProduct => product != null;

  Variation? get selectedVariation {
    final p = product;
    if (p is! VariableProduct) return null;
    if (p.variations.isEmpty) return null;

    final id = selectedVariationId;
    if (id == null) return p.variations.first;

    return p.variations.firstWhere(
      (v) => v.id == id,
      orElse: () => p.variations.first,
    );
  }

  double get baseUnitPrice {
    final p = product;
    if (p == null) return 0.0;
    if (p is VariableProduct) return selectedVariation?.price ?? 0.0;
    return p.price;
  }

  List<AddonOption> get selectedAddonOptions {
    final result = <AddonOption>[];
    for (final entry in selectedAddonsByGroup.entries) {
      final groupIndex = entry.key;
      final optionIds = entry.value;
      if (groupIndex < 0 || groupIndex >= addonGroups.length) continue;

      final group = addonGroups[groupIndex];
      for (final opt in group.options) {
        if (optionIds.contains(opt.id)) result.add(opt);
      }
    }
    return result;
  }

  double get addonsTotal {
    return selectedAddonOptions.fold(0.0, (sum, o) => sum + o.price);
  }

  double get totalUnitPrice => baseUnitPrice + addonsTotal;

  double get totalPrice => totalUnitPrice * quantity;

  @override
  List<Object?> get props => [
    status,
    addonsStatus,
    errorMessage,
    product,
    addonGroups,
    quantity,
    selectedVariationId,
    // Map equality: convert to stable representation
    selectedAddonsByGroup.entries
        .map((e) => '${e.key}:${e.value.toList()..sort()}')
        .toList(),
  ];
}
