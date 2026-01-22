
import 'package:dushka_burger/features/menu/domain/entities.dart';
import 'package:dushka_burger/features/menu/domain/menu_repo.dart';

class GetCategories {
  final MenuRepository repo;
  GetCategories(this.repo);

  Future<List<Category>> call() {
    return repo.getCategories();
  }
}

class GetProductDetails {
  final MenuRepository repo;
  GetProductDetails(this.repo);

  Future<Product> call(int productId) {
    return repo.getProductDetails(productId);
  }
}

class GetProductAddons {
  final MenuRepository repo;
  GetProductAddons(this.repo);

  Future<ProductAddons> call(int productId) {
    return repo.getProductAddons(productId);
  }
}
