
import 'package:dushka_burger/features/menu/data/models.dart';
import 'package:dushka_burger/features/menu/domain/entities.dart';

extension CategoryDtoMapper on CategoryDto {
  Category toEntity() {
    return Category(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      image: image,
      products: products.map((p) => p.toEntity()).toList(),
    );
  }
}

extension ProductDtoMapper on ProductDto {
  Product toEntity() {
    if (isVariable) {
      final defaultSize = defaultAttributes['pa_size'] ?? '';
      return VariableProduct(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        descEn: descriptionEn,
        descAr: descriptionAr,
        image: image,
        price: price,
        priceTax: priceTax,
        points: points,
        relatedIds: relatedIds,
        defaultSize: defaultSize,
        variations: variations.map((v) => v.toEntity()).toList(),
      );
    }

    return SimpleProduct(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      descEn: descriptionEn,
      descAr: descriptionAr,
      image: image,
      price: price,
      priceTax: priceTax,
      points: points,
      relatedIds: relatedIds,
    );
  }
}

extension VariationDtoMapper on VariationDto {
  Variation toEntity() {
    return Variation(
      id: id,
      size: size,
      nameEn: nameEn,
      nameAr: nameAr,
      descEn: descriptionEn,
      descAr: descriptionAr,
      price: price,
      priceTax: priceTax,
      points: points,
    );
  }
}

extension AddonsResponseDtoMapper on AddonsResponseDto {
  ProductAddons toEntity() {
    return ProductAddons(
      product: product?.toEntity(),
      groups: groups.map((g) => g.toEntity()).toList(),
    );
  }
}

extension AddonGroupDtoMapper on AddonGroupDto {
  AddonGroup toEntity() {
    return AddonGroup(
      titleEn: titleEn,
      titleAr: titleAr,
      multiChoice: multiChoice,
      options: options.map((o) => o.toEntity()).toList(),
    );
  }
}

extension AddonOptionDtoMapper on AddonOptionDto {
  AddonOption toEntity() {
    return AddonOption(
      id: id,
      nameEn: labelEn,
      nameAr: labelAr,
      price: price,
      enabled: enabled,
    );
  }
}
