import 'package:dio/dio.dart';
import 'package:dushka_burger/core/error/exception.dart';
import 'package:dushka_burger/features/cart/data/models.dart';

abstract class CartRemoteDataSource {
  Future<CartDto> getCart(String guestId);

  Future<CartDto> addToCart({
    required String guestId,
    required List<AddCartItemRequest> items,
  });

  Future<CartDto> deleteFromCart({
    required String guestId,
    required int productId,
    required int quantity,
    int? variationId,
    List<AddCartAddonRequest> addons = const [],
  });
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSourceImpl(this.dio);

  @override
  Future<CartDto> getCart(String guestId) async {
    try {
      final res = await dio.get(
        'guestcart/v1/cart',
        queryParameters: {'guest_id': guestId},
      ); // GET guestcart/v1/cart?guest_id=... [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)

      return CartDto.fromJson(res.data, fallbackGuestId: guestId);
    } on DioException catch (e) {
      throw _mapDioToException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<CartDto> addToCart({
    required String guestId,
    required List<AddCartItemRequest> items,
  }) async {
    try {
      final body = {
        'guest_id': guestId,
        'items': items.map((e) => e.toJson()).toList(),
      };

      await dio.post(
        'guestcart/v1/cart',
        data: body,
      ); // POST [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)

      // ✅ Always refresh from GET to ensure totals are correct
      return await getCart(guestId);
    } on DioException catch (e) {
      throw _mapDioToException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<CartDto> deleteFromCart({
    required String guestId,
    required int productId,
    required int quantity,
    int? variationId,
    List<AddCartAddonRequest> addons = const [],
  }) async {
    try {
      final body = {
        'guest_id': guestId,
        'product_id': productId,
        'quantity': quantity,
        if (variationId != null) 'variation_id': variationId,
        if (addons.isNotEmpty) 'addons': addons.map((a) => a.toJson()).toList(),
      };

      await dio.delete(
        'guestcart/v1/cart',
        data: body,
      ); // DELETE [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)

      // ✅ Always refresh from GET to ensure totals are correct
      return await getCart(guestId);
    } on DioException catch (e) {
      throw _mapDioToException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Exception _mapDioToException(DioException e) {
    final code = e.response?.statusCode;

    if (code == 401 || code == 403) {
      return UnauthorizedException('Unauthorized (check Basic Auth)');
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException('Network/timeout error');
    }

    return ServerException(message: 'Server error: ${code ?? 'unknown'}');
  }
}

/// ------------------------------
/// Request DTOs (for POST body)
/// ------------------------------
/// Matches the documented POST shape: guest_id + items[] { product_id, quantity, addons?, variation_id? } [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)

class AddCartItemRequest {
  final int productId;
  final int quantity;
  final int? variationId;
  final List<AddCartAddonRequest> addons;

  const AddCartItemRequest({
    required this.productId,
    required this.quantity,
    this.variationId,
    this.addons = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      if (variationId != null) 'variation_id': variationId,
      if (addons.isNotEmpty) 'addons': addons.map((a) => a.toJson()).toList(),
    };
  }
}

/// Matches addons item in POST example: { id, name, price } [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)

class AddCartAddonRequest {
  final int? id;
  final String name;
  final String price;

  const AddCartAddonRequest({this.id, required this.name, required this.price});

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'price': price,
  };
}
