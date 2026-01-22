import 'package:dio/dio.dart';
import 'package:dushka_burger/features/cart/data/cart_remote_ds.dart';
import 'package:dushka_burger/features/cart/data/cart_repo_impl.dart';
import 'package:dushka_burger/features/cart/domain/cart_repo.dart';
import 'package:dushka_burger/features/cart/domain/usecases.dart';
import 'package:dushka_burger/features/cart/presentation/cart_cubit.dart';
import 'package:dushka_burger/features/guest/data/guest_remote_ds.dart';
import 'package:dushka_burger/features/guest/data/guest_repo_impl.dart';
import 'package:dushka_burger/features/guest/domain/get_guest_id.dart';
import 'package:dushka_burger/features/guest/domain/guest_repo.dart';
import 'package:dushka_burger/features/guest/presentation/guest_cubit.dart';
import 'package:dushka_burger/features/menu/data/menu_remote_ds.dart';
import 'package:dushka_burger/features/menu/data/menu_repo_impl.dart';
import 'package:dushka_burger/features/menu/domain/menu_repo.dart';
import 'package:dushka_burger/features/menu/domain/usecases.dart';
import 'package:dushka_burger/features/menu/presentation/categories_cubit.dart';
import 'package:dushka_burger/features/menu/presentation/product_details_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dushka_burger/core/network/api_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Core Network
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<Dio>(() => sl<ApiClient>().dio);

  // ✅ Stop here for Phase 1
  // Add Guest/Menu/Cart registrations later when their files exist.

  // Guest
  sl.registerLazySingleton<GuestRemoteDataSource>(
    () => GuestRemoteDataSourceImpl(sl()), // sl<Dio>()
  );

  sl.registerLazySingleton<GuestRepository>(
    () => GuestRepositoryImpl(remote: sl(), prefs: sl()),
  );

  sl.registerLazySingleton(() => GetGuestId(sl()));

  sl.registerFactory(() => GuestCubit(sl())); // sl<GetGuestId>()

  //Menu

  sl.registerLazySingleton<MenuRemoteDataSource>(
    () => MenuRemoteDataSourceImpl(sl()), // sl<Dio>()
  );

  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(sl()), // sl<Dio>()
  );

  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => GetProductDetails(sl()));
  sl.registerLazySingleton(() => GetProductAddons(sl()));
  sl.registerFactory(() => CategoriesCubit(sl())); // sl<GetCategories>()

  sl.registerFactory(
    () => ProductDetailsCubit(getProductDetails: sl(), getProductAddons: sl()),
  );

  //Cart
  sl.registerLazySingleton<CartRemoteDataSource>(() => CartRemoteDataSourceImpl(sl())); // sl<Dio>()  
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()));
  
  sl.registerLazySingleton(() => GetCart(sl()));
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(() => DeleteFromCart(sl()));

  
  sl.registerFactory(() => CartCubit(
        getCart: sl(),
        addToCart: sl(),
        deleteFromCart: sl(),
  ));


}
