// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DushkaBurger';

  @override
  String get menuTitle => 'Menu';

  @override
  String get productDetailsTitle => 'Product Details';

  @override
  String get cartTitle => 'Cart';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get remove => 'Remove';

  @override
  String get apply => 'Apply';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get noCategories => 'No categories';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get quantity => 'Quantity';

  @override
  String get size => 'Size';

  @override
  String get extras => 'Extras';

  @override
  String get multiple => 'Multiple';

  @override
  String get single => 'Single';

  @override
  String get couldNotLoadExtrasOptional => 'Could not load extras (optional).';

  @override
  String get noExtrasAvailable => 'No extras available.';

  @override
  String get total => 'Total';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get qtyLimitedExtrasSnack =>
      'Quantity is limited to 1 when extras are selected.';

  @override
  String get qtyLimitedExtrasNote =>
      'Note: Quantity > 1 with extras is temporarily disabled (backend pricing issue).';

  @override
  String get cannotIncreaseQtyExtrasSnack =>
      'Cannot increase quantity for items with extras (backend pricing issue).';

  @override
  String get cannotChangeQtyExtrasSnack =>
      'Cannot change quantity for items with extras (backend pricing issue).';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get coupon => 'Coupon';

  @override
  String get enterCouponCode => 'Enter coupon code';

  @override
  String get couponUiOnly => 'Coupon API not implemented (UI only).';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get vat => 'VAT';

  @override
  String get checkout => 'Checkout';

  @override
  String get checkoutUiOnly => 'Checkout is UI-only for this task.';

  @override
  String get noVariations => 'No variations';

  @override
  String get option => 'Option';
}
