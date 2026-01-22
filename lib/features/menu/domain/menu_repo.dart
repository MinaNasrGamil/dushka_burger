
import 'package:dushka_burger/features/menu/domain/entities.dart';

abstract class MenuRepository {
  Future<List<Category>> getCategories();
  Future<Product> getProductDetails(int productId);
  Future<ProductAddons> getProductAddons(int productId);
}
