
import 'package:dushka_burger/constants/enums.dart';
import 'package:dushka_burger/core/di/di.dart';
import 'package:dushka_burger/core/l10n/gen_l10n/app_localizations.dart';
import 'package:dushka_burger/core/widgets/app_image.dart';
import 'package:dushka_burger/core/widgets/app_state_views.dart';
import 'package:dushka_burger/features/cart/presentation/cart_cubit.dart';
import 'package:dushka_burger/features/cart/presentation/cart_page.dart';
import 'package:dushka_burger/features/cart/presentation/cart_state.dart';
import 'package:dushka_burger/features/menu/domain/entities.dart';
import 'package:dushka_burger/features/menu/presentation/categories_cubit.dart';
import 'package:dushka_burger/features/menu/presentation/categories_state.dart';
import 'package:dushka_burger/features/menu/presentation/product_details_cubit.dart';
import 'package:dushka_burger/features/menu/presentation/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ---------- Page tokens (kept local as you requested) ----------
const pageBg = Color(0xFFF6F6F6); // lighter background
const cardBg = Color(0xFFEFEFEF); // darker than background (clear separation)
const accent = Color(0xFFD65A2F); // orange for selected / + button
const chipOff = Color(0xFFE8E8E8); // unselected chips
const textGrey = Color(0xFF7A7A7A);
const priceColor = Color(0xFFB4533C);
const imageBorder = Color(0xFFDDDDDD);

class CategoriesPage extends StatefulWidget {
  final String guestId; // passed from GuestGate/main startup flow
  const CategoriesPage({super.key, required this.guestId});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  title: l10n.menuTitle,
                  guestId: widget.guestId,
                  onCartPressed: () => _openCart(context),
                ),
                Expanded(
                  child: _buildBodyByState(
                    context: context,
                    state: state,
                    l10n: l10n,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ---------- Navigation / Actions (extracted to avoid duplication) ----------

  void _openCart(BuildContext context) {
    context.read<CartCubit>().fetchCart(widget.guestId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CartCubit>(),
          child: CartPage(guestId: widget.guestId),
        ),
      ),
    );
  }

  void _openProductDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CartCubit>()),
            BlocProvider(
              create: (_) => sl<ProductDetailsCubit>()..load(product.id),
            ),
          ],
          child: ProductDetailsPage(
            guestId: widget.guestId,
            productId: product.id,
          ),
        ),
      ),
    );
  }

  void _handleAdd(BuildContext context, Product product, AppLocalizations l10n) {
    // unchanged add logic
    if (product.isVariable) {
      _openProductDetails(context, product);
      return;
    }

    context.read<CartCubit>().addItem(
      guestId: widget.guestId,
      productId: product.id,
      quantity: 1,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.addedToCart)),
    );
  }

  /// ---------- Body by state (header always stable) ----------
  Widget _buildBodyByState({
    required BuildContext context,
    required CategoriesState state,
    required AppLocalizations l10n,
  }) {
    if (state.status == Status.loading || state.status == Status.initial) {
      return AppLoadingSkeleton(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, __) => const _ProductRowSkeleton(),
        ),
      );
    }

    if (state.status == Status.error) {
      return AppErrorView(
        message: state.errorMessage,
        onRetry: () => context.read<CategoriesCubit>().fetchCategories(),
      );
    }

    if (state.categories.isEmpty) {
      return AppEmptyView(
        icon: Icons.category_outlined,
        title: l10n.noCategories,
      );
    }

    // Keep selected index in range (same behavior)
    if (_selectedCategoryIndex >= state.categories.length) {
      _selectedCategoryIndex = 0;
    }

    final selectedCategory = state.categories[_selectedCategoryIndex];
    final products = selectedCategory.products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CategoryChips(
          categories: state.categories,
          selectedIndex: _selectedCategoryIndex,
          onSelect: (i) => setState(() => _selectedCategoryIndex = i),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            _localize(
              context,
              en: selectedCategory.nameEn,
              ar: selectedCategory.nameAr,
            ),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductRow(
                product: product,
                onTap: () => _openProductDetails(context, product),
                onAdd: () => _handleAdd(context, product, l10n),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// ---------- Header (extracted for clarity, no behavior change) ----------
class _Header extends StatelessWidget {
  final String title;
  final String guestId;
  final VoidCallback onCartPressed;

  const _Header({
    required this.title,
    required this.guestId,
    required this.onCartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ) ??
                  const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final count = cartState.cart?.totalItems ?? 0;
              return _CartButtonWithBadge(
                badgeCount: count,
                onPressed: onCartPressed,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ---------- Widgets ----------
class _CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _CategoryChips({
    required this.categories,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = categories[i];
          final label = _localize(context, en: c.nameEn, ar: c.nameAr);
          final selected = i == selectedIndex;

          return ChoiceChip(
            selected: selected,
            showCheckmark: false,
            label: Text(label, overflow: TextOverflow.ellipsis),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : textGrey,
            ),
            selectedColor: accent,
            backgroundColor: chipOff,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pressElevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: const BorderSide(color: Colors.transparent),
            ),
            onSelected: (_) => onSelect(i),
          );
        },
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _ProductRow({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final name = _name(context, product);
    final price = _displayPrice(product); // UI format only

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              // --- Image (LEFT) ---
              Container(
                width: 74,
                height: 74,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: imageBorder, width: 1),
                ),
                child: AppImage(
                  url: product.image,
                  width: 58,
                  height: 58,
                  fit: BoxFit.contain,
                  borderRadius: 12,
                  backgroundColor: Colors.transparent,
                ),
              ),
              const SizedBox(width: 12),

              // --- Text (MIDDLE) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                              ) ??
                          const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.5,
                            height: 1.12,
                          ),
                    ),
                    const SizedBox(height: 6),
                    if (price.isNotEmpty)
                      Text(
                        price,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: priceColor,
                                    ) ??
                                const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: priceColor,
                                ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // --- Add button (RIGHT) ---
              InkResponse(
                onTap: onAdd,
                radius: 24,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// UI-only formatting to match screenshot: "120 EGP" (no decimals, currency after)
  String _displayPrice(Product p) {
    double value = p.price;

    if (p.isVariable &&
        value == 0 &&
        p is VariableProduct &&
        p.variations.isNotEmpty) {
      value = p.variations.first.price;
    }

    if (value == 0) return '';

    final int intValue = value.round();
    return '$intValue EGP';
  }
}

class _CartButtonWithBadge extends StatelessWidget {
  final int badgeCount;
  final VoidCallback onPressed;

  const _CartButtonWithBadge({
    required this.badgeCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: onPressed,
        ),
        if (badgeCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: chipOff,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProductRowSkeleton extends StatelessWidget {
  const _ProductRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // image box
          Container(
            width: 78,
            height: 78,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: imageBorder, width: 1),
            ),
          ),
          const SizedBox(width: 12),

          // text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: double.infinity, color: Colors.white),
                const SizedBox(height: 10),
                Container(height: 12, width: 120, color: Colors.white),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // add button placeholder
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- Localization helpers (for API dynamic names only) ----------
String _localize(
  BuildContext context, {
  required String en,
  required String ar,
}) {
  final code = Localizations.localeOf(context).languageCode.toLowerCase();
  return (code == 'ar' && ar.trim().isNotEmpty) ? ar : en;
}

String _name(BuildContext context, Product p) =>
    _localize(context, en: p.nameEn, ar: p.nameAr);
