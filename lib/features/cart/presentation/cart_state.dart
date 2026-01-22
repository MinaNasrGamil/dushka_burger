import 'package:equatable/equatable.dart';
import 'package:dushka_burger/constants/enums.dart';
import 'package:dushka_burger/features/cart/data/models.dart';

class CartState extends Equatable {
  final Status status;
  final String errorMessage;

  final CartDto? cart;

  // Totals exposed directly for UI convenience (as per blueprint). [1](https://m365.cloud.microsoft/chat/pages/eyJ1IjoiaHR0cHM6Ly9saXZlYnVlZWR1LnNoYXJlcG9pbnQuY29tL2NvbnRlbnRzdG9yYWdlL3g4Rk5PLXh0c2t1Q1JYMl9mTVRITGFiQ3pJa3pMVUJJdVI3bzNwTUt5WE0%5FbmF2PWN6MGxNa1pqYjI1MFpXNTBjM1J2Y21GblpTVXlSbmc0Ums1UEpUSkVlSFJ6YTNWRFVsZ3lKVFZHWmsxVVNFeGhZa042U1d0NlRGVkNTWFZTTjI4emNFMUxlVmhOSm1ROVlpVXlNVTAyVkcwbE1rUmpUWFpvTUZNeVNERlJkME52VXpFd1RtNVFUV2sxWjNSMk9VZHNTSGhxTUZWM04yVTBlSFZ4VTJkR1RGcHpSVk54YlhoT1YxRndiVUpsUWlabVBUQXhRa2hQVFVSS1RrUkpRVXBQVGpSSE16UTFSRXBaUWxJMlZVaE5OazFHVTBvbVl6MGxNa1kifQ?auth=2)
  final double subtotal;
  final double vat;
  final double total;

  const CartState({
    required this.status,
    required this.errorMessage,
    required this.cart,
    required this.subtotal,
    required this.vat,
    required this.total,
  });

  factory CartState.initial() => const CartState(
    status: Status.initial,
    errorMessage: '',
    cart: null,
    subtotal: 0.0,
    vat: 0.0,
    total: 0.0,
  );

  CartState copyWith({
    Status? status,
    String? errorMessage,
    CartDto? cart,
    double? subtotal,
    double? vat,
    double? total,
  }) {
    return CartState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      cart: cart ?? this.cart,
      subtotal: subtotal ?? this.subtotal,
      vat: vat ?? this.vat,
      total: total ?? this.total,
    );
  }

  bool get hasItems => (cart?.items ?? const []).isNotEmpty;

  @override
  List<Object?> get props => [status, errorMessage, cart, subtotal, vat, total];
}
