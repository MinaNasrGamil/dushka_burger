// lib/features/menu/data/models.dart
//
// Lean + Safe DTOs for:
// - Categories endpoint: GET custom-api/v1/categories
// - Product details:     GET custom-api/v1/products?product_id={id}
// - Addons endpoint:     GET proaddon/v1/get2/?product_id2={id}
//
// Goal: parsing NEVER crashes. Defaults are safe for UI.

class CategoryDto {
  final int id;
  final String nameEn;
  final String nameAr;
  final String image;
  final List<ProductDto> products;

  const CategoryDto({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.image,
    required this.products,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    final productsJson = _asList(json['products']);
    return CategoryDto(
      id: _asInt(json['id']),
      nameEn: _asString(json['name_en']),
      nameAr: _asString(json['name_ar']),
      image: _asString(json['image']),
      products: productsJson
          .whereType<Map>()
          .map((e) => ProductDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class ProductDto {
  final int id;
  final String type; // "simple" or "variable"
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String image;
  final double price;
  final double priceTax;
  final int points;
  final List<int> relatedIds;

  // Only for variable products:
  final Map<String, String> defaultAttributes; // e.g. { "pa_size": "single" }
  final List<VariationDto> variations;

  const ProductDto({
    required this.id,
    required this.type,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.image,
    required this.price,
    required this.priceTax,
    required this.points,
    required this.relatedIds,
    required this.defaultAttributes,
    required this.variations,
  });

  bool get isVariable => type.toLowerCase() == 'variable';

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    final variationsJson = _asList(json['variations']);
    final related = _asList(json['related_ids']);

    return ProductDto(
      id: _asInt(json['id']),
      type: _asString(json['type']),
      nameEn: _asString(json['name_en']),
      nameAr: _asString(json['name_ar']),
      descriptionEn: _asString(json['description_en']),
      descriptionAr: _asString(json['description_ar']),
      image: _asString(json['image']),
      price: _asDouble(json['price']),
      priceTax: _asDouble(json['price_tax']),
      points: _asInt(json['points']),
      relatedIds: related.map((e) => _asInt(e)).toList(),
      defaultAttributes: _asStringMap(json['default_attributes']),
      variations: variationsJson
          .whereType<Map>()
          .map((e) => VariationDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  ProductDto copyWith({
    int? id,
    String? type,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    String? image,
    double? price,
    double? priceTax,
    int? points,
    List<int>? relatedIds,
    Map<String, String>? defaultAttributes,
    List<VariationDto>? variations,
  }) {
    return ProductDto(
      id: id ?? this.id,
      type: type ?? this.type,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      image: image ?? this.image,
      price: price ?? this.price,
      priceTax: priceTax ?? this.priceTax,
      points: points ?? this.points,
      relatedIds: relatedIds ?? this.relatedIds,
      defaultAttributes: defaultAttributes ?? this.defaultAttributes,
      variations: variations ?? this.variations,
    );
  }
}

class VariationDto {
  final int id;
  final String size; // pa_size (single/double) if available
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final double price;
  final double priceTax;
  final int points;

  const VariationDto({
    required this.id,
    required this.size,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
    required this.priceTax,
    required this.points,
  });

  factory VariationDto.fromJson(Map<String, dynamic> json) {
    final attrs = _asMap(json['attributes']);
    return VariationDto(
      id: _asInt(json['id']),
      size: _asString(attrs['pa_size']),
      nameEn: _asString(json['name_en']),
      nameAr: _asString(json['name_ar']),
      descriptionEn: _asString(json['description_en']),
      descriptionAr: _asString(json['description_ar']),
      price: _asDouble(json['price']),
      priceTax: _asDouble(json['price_tax']),
      points: _asInt(json['points']),
    );
  }
}

/// ----------------------
/// Addons / Extras DTOs
/// ----------------------
/// The proaddon endpoint returns product + blocks/addons/options.
/// We parse it defensively (structure can vary slightly).

class AddonsResponseDto {
  final ProductDto? product; // may exist in response
  final List<AddonGroupDto> groups;

  const AddonsResponseDto({required this.product, required this.groups});

  factory AddonsResponseDto.fromJson(Map<String, dynamic> json) {
    // product might be under "product" key (common per blueprint)
    final productJson = json['product'];
    ProductDto? product;
    if (productJson is Map) {
      product = ProductDto.fromJson(Map<String, dynamic>.from(productJson));
    }

    final groups = <AddonGroupDto>[];
    final blocks = _asList(json['blocks']);

    // Common pattern: blocks -> addons -> options[]
    for (final block in blocks) {
      if (block is! Map) continue;
      final blockMap = Map<String, dynamic>.from(block);

      // Some APIs nest addon groups under "addons"
      final addonsList = _asList(blockMap['addons']);

      for (final addon in addonsList) {
        if (addon is! Map) continue;
        final addonMap = Map<String, dynamic>.from(addon);
        groups.add(AddonGroupDto.fromJson(addonMap));
      }
    }

    // Fallback: sometimes groups come directly under "addons"
    if (groups.isEmpty) {
      final addonsTop = _asList(json['addons']);
      for (final addon in addonsTop) {
        if (addon is! Map) continue;
        groups.add(AddonGroupDto.fromJson(Map<String, dynamic>.from(addon)));
      }
    }

    return AddonsResponseDto(product: product, groups: groups);
  }
}

class AddonGroupDto {
  final String id;
  final String titleEn;
  final String titleAr;
  final bool multiChoice;
  final List<AddonOptionDto> options;

  const AddonGroupDto({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.multiChoice,
    required this.options,
  });

  factory AddonGroupDto.fromJson(Map<String, dynamic> json) {
    final groupId = _asString(json['id']); // "262"
    final optionsJson = _asList(json['options']);

    return AddonGroupDto(
      id: groupId, // add this field to AddonGroupDto
      titleEn: _asString(json['title']),
      titleAr: _asString(json['title_ar']),
      multiChoice: _asBool(json['IsMultiChoise']), // correct key from API
      options: List.generate(optionsJson.length, (i) {
        final item = optionsJson[i];
        return AddonOptionDto.fromJson(
          Map<String, dynamic>.from(item as Map),
          groupId: groupId,
          index: i,
        );
      }),
    );
  }
}

class AddonOptionDto {
  final int id;
  final String labelEn;
  final String labelAr;
  final double price;
  final bool enabled;
  final bool selectedByDefault;

  AddonOptionDto({
    required this.id,
    required this.labelEn,
    required this.labelAr,
    required this.price,
    required this.enabled,
    required this.selectedByDefault,
  });

  factory AddonOptionDto.fromJson(
    Map<String, dynamic> json, {
    required String groupId,
    required int index,
  }) {
    final label = _asString(json['label']);
    final labelAr = _asString(json['label_ar']);
    final price = _asDouble(json['price']); // "" becomes 0.0 (ok)
    final enabled = _asBool(json['addon_enabled']); // correct key from API

    // ✅ Guaranteed unique per group + index (handles duplicates)
    final generatedId = Object.hash(groupId, index);

    return AddonOptionDto(
      id: generatedId,
      labelEn: label,
      labelAr: labelAr,
      price: price,
      enabled: enabled,
      selectedByDefault: _asBool(json['selected_by_default']),
    );
  }
}

/// ----------------------
/// Safe parsing helpers
/// ----------------------

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

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

bool _asBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) {
    final s = v.toLowerCase().trim();
    return s == 'true' || s == '1' || s == 'yes' || s == 'enabled';
  }
  return false;
}

List<dynamic> _asList(dynamic v) {
  if (v is List) return v;
  return const [];
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return const {};
}

Map<String, String> _asStringMap(dynamic v) {
  final map = _asMap(v);
  return map.map((key, value) => MapEntry(key, _asString(value)));
}
