// lib/features/cart/data/models.dart
//
// Lean + Safe DTOs for Guest Cart APIs:
// GET    guestcart/v1/cart?guest_id={guestId}
// POST   guestcart/v1/cart
// DELETE guestcart/v1/cart
//
// This version is aligned with the real GET cart response shape you pasted:
// - cart_items[]
// - total_price, VAT, total_price_with_tax, total_items, total_points
// And supports addons being nested: addons: [ [] ] or [ [ {...}, {...} ] ].

class CartDto {
  final String guestId;

  final List<CartItemDto> items;

  /// From API: total_price (before tax)
  final double subtotal;

  /// From API: VAT
  final double vat;

  /// From API: total_price_with_tax
  final double totalWithTax;

  /// From API: total_items
  final int totalItems;

  /// From API: total_points
  final int totalPoints;

  const CartDto({
    required this.guestId,
    required this.items,
    required this.subtotal,
    required this.vat,
    required this.totalWithTax,
    required this.totalItems,
    required this.totalPoints,
  });

  factory CartDto.empty([String guestId = '']) => CartDto(
    guestId: guestId,
    items: const [],
    subtotal: 0.0,
    vat: 0.0,
    totalWithTax: 0.0,
    totalItems: 0,
    totalPoints: 0,
  );

  factory CartDto.fromJson(dynamic json, {String fallbackGuestId = ''}) {
    final root = _asMap(json);

    // Real API uses cart_items (but keep fallbacks)
    final itemsJson = _asList(
      root['cart_items'] ??
          root['items'] ??
          root['cartItems'] ??
          root['products'],
    );

    final items = itemsJson
        .whereType<Map>()
        .map((e) => CartItemDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final subtotal = _asDouble(root['total_price'] ?? root['subtotal']);
    final vat = _asDouble(root['VAT'] ?? root['vat'] ?? root['tax']);
    final totalWithTax = _asDouble(
      root['total_price_with_tax'] ?? root['total_with_tax'] ?? root['total'],
    );

    final totalItems = _asInt(root['total_items'] ?? root['items_count']);
    final totalPoints = _asInt(root['total_points'] ?? root['points_total']);

    final guestId = _asString(root['guest_id']);
    return CartDto(
      guestId: guestId.isNotEmpty ? guestId : fallbackGuestId,
      items: items,
      subtotal: subtotal,
      vat: vat,
      totalWithTax: totalWithTax,
      totalItems: totalItems,
      totalPoints: totalPoints,
    );
  }
}

class CartItemDto {
  final int productId;
  final int? variationId;

  final int quantity;

  final String nameEn;
  final String nameAr;
  final String image;

  /// From API: price (unit price)
  final double unitPrice;

  /// From API: addon_price
  final double addonPrice;

  /// From API: total (line total)
  final double lineTotal;

  /// From API: points
  final int points;

  /// Addons can be: [ [] ] or [ [ {...}, {...} ] ] or sometimes just []
  final List<CartAddonDto> addons;

  const CartItemDto({
    required this.productId,
    required this.variationId,
    required this.quantity,
    required this.nameEn,
    required this.nameAr,
    required this.image,
    required this.unitPrice,
    required this.addonPrice,
    required this.lineTotal,
    required this.points,
    required this.addons,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) {
    final rawAddons = json['addons'] ?? json['extras'] ?? json['options'];
    final flattenedAddonList = _flattenToList(rawAddons);

    final addons = flattenedAddonList
        .whereType<Map>()
        .map((e) => CartAddonDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return CartItemDto(
      productId: _asInt(json['product_id'] ?? json['id']),
      variationId: _asNullableInt(json['variation_id']),
      quantity: _asInt(json['quantity'] ?? json['qty'] ?? 1),

      // Real API keys:
      nameEn: _asString(
        json['product_name_en'] ??
            json['product_name'] ??
            json['name_en'] ??
            json['name'],
      ),
      nameAr: _asString(json['product_name_ar'] ?? json['name_ar']),

      image: _asString(json['image'] ?? json['thumbnail']),

      unitPrice: _asDouble(json['price'] ?? json['unit_price']),
      addonPrice: _asDouble(json['addon_price']),
      lineTotal: _asDouble(
        json['total'] ?? json['line_total'] ?? json['item_total'],
      ),

      points: _asInt(json['points']),
      addons: addons,
    );
  }
}

class CartAddonDto {
  // We still don't know the exact addon shape returned when addons exist in cart,
  // so this is defensive.
  final int id;
  final String nameEn;
  final String nameAr;
  final double price;

  const CartAddonDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.price,
  });

  factory CartAddonDto.fromJson(Map<String, dynamic> json) {
    return CartAddonDto(
      id: _asInt(json['id'] ?? json['addon_id'] ?? json['option_id']),
      nameEn: _asString(json['name'] ?? json['label'] ?? json['title']),
      nameAr: _asString(
        json['name_ar'] ?? json['label_ar'] ?? json['title_ar'],
      ),
      price: _asDouble(json['price']),
    );
  }
}

/// ----------------------
/// Helpers
/// ----------------------

/// Flattens weird nested lists coming from API:
/// - [ [] ] -> []
/// - [ [ {...}, {...} ] ] -> [ {...}, {...} ]
/// - [ {...} ] -> [ {...} ]

List<dynamic> _flattenToList(dynamic v) {
  if (v is! List) return const [];

  final out = <dynamic>[];

  for (final el in v) {
    if (el is List) {
      out.addAll(el);
    } else {
      out.add(el);
    }
  }

  return out;
}

String _asString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString();
}

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? 0;
  return 0;
}

int? _asNullableInt(dynamic v) {
  final x = _asInt(v);
  return x == 0 ? null : x;
}

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return 0.0; // important for "" prices
    return double.tryParse(s) ?? 0.0;
  }
  return 0.0;
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return const {};
}

List<dynamic> _asList(dynamic v) {
  if (v is List) return v;
  return const [];
}
