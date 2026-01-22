// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'دوشكا برجر';

  @override
  String get menuTitle => 'المنيو';

  @override
  String get productDetailsTitle => 'تفاصيل المنتج';

  @override
  String get cartTitle => 'السلة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get refresh => 'تحديث';

  @override
  String get remove => 'حذف';

  @override
  String get apply => 'تطبيق';

  @override
  String get addedToCart => 'تمت الإضافة للسلة';

  @override
  String get noCategories => 'لا توجد أقسام';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get productNotFound => 'المنتج غير موجود';

  @override
  String get quantity => 'الكمية';

  @override
  String get size => 'الحجم';

  @override
  String get extras => 'الإضافات';

  @override
  String get multiple => 'متعدد';

  @override
  String get single => 'اختيار واحد';

  @override
  String get couldNotLoadExtrasOptional => 'تعذر تحميل الإضافات (اختياري).';

  @override
  String get noExtrasAvailable => 'لا توجد إضافات.';

  @override
  String get total => 'الإجمالي';

  @override
  String get addToCart => 'أضف للسلة';

  @override
  String get qtyLimitedExtrasSnack => 'الكمية محددة بـ 1 عند اختيار الإضافات.';

  @override
  String get qtyLimitedExtrasNote =>
      'ملاحظة: تم تعطيل الكمية أكبر من 1 مع الإضافات مؤقتًا (مشكلة تسعير في السيرفر).';

  @override
  String get cannotIncreaseQtyExtrasSnack =>
      'لا يمكن زيادة الكمية لمنتجات بها إضافات (مشكلة تسعير في السيرفر).';

  @override
  String get cannotChangeQtyExtrasSnack =>
      'لا يمكن تغيير الكمية لمنتجات بها إضافات (مشكلة تسعير في السيرفر).';

  @override
  String get cartEmpty => 'سلتك فارغة';

  @override
  String get coupon => 'كوبون';

  @override
  String get enterCouponCode => 'ادخل كود الكوبون';

  @override
  String get couponUiOnly => 'واجهة فقط: لم يتم تنفيذ API الكوبون.';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get vat => 'الضريبة';

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String get checkoutUiOnly => 'الدفع واجهة فقط في هذا التاسك.';

  @override
  String get noVariations => 'لا توجد أحجام';

  @override
  String get option => 'اختيار';
}
