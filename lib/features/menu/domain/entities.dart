
import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String nameEn;
  final String nameAr;
  final String image;
  final List<Product> products;

  const Category({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.image,
    required this.products,
  });

  @override
  List<Object?> get props => [id, nameEn, nameAr, image, products];
}

/// ----------------------
/// Products (Simple / Variable)
/// ----------------------

enum ProductType { simple, variable }

abstract class Product extends Equatable {
  final int id;
  final ProductType type;

  final String nameEn;
  final String nameAr;

  final String descEn;
  final String descAr;

  final String image;

  /// For variable product: this can be 0 and you use selected variation price instead.
  final double price;
  final double priceTax;

  final int points;
  final List<int> relatedIds;

  const Product({
    required this.id,
    required this.type,
    required this.nameEn,
    required this.nameAr,
    required this.descEn,
    required this.descAr,
    required this.image,
    required this.price,
    required this.priceTax,
    required this.points,
    required this.relatedIds,
  });

  bool get isVariable => type == ProductType.variable;

  @override
  List<Object?> get props => [
        id,
        type,
        nameEn,
        nameAr,
        descEn,
        descAr,
        image,
        price,
        priceTax,
        points,
        relatedIds,
      ];
}

class SimpleProduct extends Product {
  const SimpleProduct({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    required super.descEn,
    required super.descAr,
    required super.image,
    required super.price,
    required super.priceTax,
    required super.points,
    required super.relatedIds,
  }) : super(type: ProductType.simple);
}

class VariableProduct extends Product {
  final String defaultSize; // usually "single" or "double"
  final List<Variation> variations;

  const VariableProduct({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    required super.descEn,
    required super.descAr,
    required super.image,
    required super.price,
    required super.priceTax,
    required super.points,
    required super.relatedIds,
    required this.defaultSize,
    required this.variations,
  }) : super(type: ProductType.variable);

  @override
  List<Object?> get props => super.props + [defaultSize, variations];
}

class Variation extends Equatable {
  final int id;

  /// API uses pa_size per blueprint (“single” / “double”).
  final String size;

  final String nameEn;
  final String nameAr;

  final String descEn;
  final String descAr;

  final double price;
  final double priceTax;

  final int points;

  const Variation({
    required this.id,
    required this.size,
    required this.nameEn,
    required this.nameAr,
    required this.descEn,
    required this.descAr,
    required this.price,
    required this.priceTax,
    required this.points,
  });

  @override
  List<Object?> get props =>
      [id, size, nameEn, nameAr, descEn, descAr, price, priceTax, points];
}

/// ----------------------
/// Addons / Extras (from proaddon endpoint)
/// ----------------------

class AddonGroup extends Equatable {
  final String titleEn;
  final String titleAr;

  /// If true => checkbox-style multi select, else radio-style single select.
  final bool multiChoice;

  final List<AddonOption> options;

  const AddonGroup({
    required this.titleEn,
    required this.titleAr,
    required this.multiChoice,
    required this.options,
  });

  @override
  List<Object?> get props => [titleEn, titleAr, multiChoice, options];
}

class AddonOption extends Equatable {
  final int id;
  final String nameEn;
  final String nameAr;
  final double price;
  final bool enabled;

  const AddonOption({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.enabled,
  });

  @override
  List<Object?> get props => [id, nameEn, nameAr, price, enabled];
}


class ProductAddons extends Equatable {
  final Product? product;
  final List<AddonGroup> groups;

  const ProductAddons({
    required this.product,
    required this.groups,
  });

  @override
  List<Object?> get props => [product, groups];
}

