import 'package:dushka_burger/constants/enums.dart';
import 'package:dushka_burger/core/l10n/gen_l10n/app_localizations.dart';
import 'package:dushka_burger/core/widgets/app_image.dart';
import 'package:dushka_burger/core/widgets/app_state_views.dart';
import 'package:dushka_burger/features/cart/data/cart_remote_ds.dart';
import 'package:dushka_burger/features/cart/presentation/cart_cubit.dart';
import 'package:dushka_burger/features/cart/presentation/cart_page.dart';
import 'package:dushka_burger/features/menu/domain/entities.dart';
import 'package:dushka_burger/features/menu/presentation/product_details_cubit.dart';
import 'package:dushka_burger/features/menu/presentation/product_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ---------- Page tokens (kept local) ----------
const pageBg = Color(0xFFF6F6F6);
const accent = Color(0xFFD65A2F);

class ProductDetailsPage extends StatelessWidget {
  final String guestId;
  final int productId;

  const ProductDetailsPage({
    super.key,
    required this.guestId,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            title: Text(l10n.productDetailsTitle),
            centerTitle: true,
            elevation: 0,
            backgroundColor: pageBg,
            surfaceTintColor: Colors.transparent,
          ),
          body: _Body(productId: productId, state: state),
          bottomNavigationBar: _BottomAddToCartBar(
            guestId: guestId,
            state: state,
          ),
        );
      },
    );
  }
}

/// ---------- Body ----------
class _Body extends StatelessWidget {
  final int productId;
  final ProductDetailsState state;

  const _Body({required this.productId, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state.status == Status.initial || state.status == Status.loading) {
      return _LoadingBody();
    }

    if (state.status == Status.error) {
      return AppErrorView(
        message: state.errorMessage,
        onRetry: () => context.read<ProductDetailsCubit>().load(productId),
      );
    }

    final product = state.product;
    if (product == null) {
      return AppErrorView(
        message: l10n.productNotFound,
        onRetry: () => context.read<ProductDetailsCubit>().load(productId),
      );
    }

    return _ContentBody(product: product, state: state, productId: productId);
  }
}

class _LoadingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppLoadingSkeleton(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Loading product name'),
            const SizedBox(height: 6),
            const Text('EGP 000.00'),
            const SizedBox(height: 18),
            const Text('Loading section'),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.remove),
                SizedBox(width: 12),
                Text('1'),
                SizedBox(width: 12),
                Icon(Icons.add),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Loading extras'),
            const SizedBox(height: 10),
            ...List.generate(
              3,
              (_) => const Card(
                child: ListTile(
                  title: Text('Loading option'),
                  subtitle: Text('Loading details'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentBody extends StatelessWidget {
  final Product product;
  final ProductDetailsState state;
  final int productId;

  const _ContentBody({
    required this.product,
    required this.state,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final title = _localize(context, en: product.nameEn, ar: product.nameAr);
    final desc = _localize(context, en: product.descEn, ar: product.descAr);

    final hasAddons = state.selectedAddonOptions.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProductImageCard(imageUrl: product.image),

          const SizedBox(height: 16),

          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 6),

          Text(
            _priceText(context, state),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),

          const SizedBox(height: 10),

          if (desc.trim().isNotEmpty) ...[
            Text(
              desc,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[800]),
            ),
            const SizedBox(height: 14),
          ],

          _SectionTitle(text: l10n.quantity),
          const SizedBox(height: 8),

          _QtyRow(
            quantity: hasAddons ? 1 : state.quantity,
            onMinus: hasAddons
                ? () => _showQtyLimitedSnack(context, l10n)
                : () => context.read<ProductDetailsCubit>().decQty(),
            onPlus: hasAddons
                ? () => _showQtyLimitedSnack(context, l10n)
                : () => context.read<ProductDetailsCubit>().incQty(),
          ),

          const SizedBox(height: 18),

          if (hasAddons)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.qtyLimitedExtrasNote,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),

          const SizedBox(height: 18),

          if (product is VariableProduct) ...[
            _SectionTitle(text: l10n.size),
            const SizedBox(height: 10),
            Center(
              child: _VariationChips(
                product: product as VariableProduct,
                selectedVariationId: state.selectedVariationId,
                onSelect: (id) =>
                    context.read<ProductDetailsCubit>().selectVariation(id),
              ),
            ),
            const SizedBox(height: 18),
          ],

          _SectionTitle(text: l10n.extras),
          const SizedBox(height: 8),

          _AddonsSection(state: state, productId: productId),
        ],
      ),
    );
  }

  void _showQtyLimitedSnack(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.qtyLimitedExtrasSnack)));
  }

  String _priceText(BuildContext context, ProductDetailsState state) {
    final l10n = AppLocalizations.of(context);

    final unit = state.totalUnitPrice;
    final total = state.totalPrice;

    if (unit == 0) return '';
    if (state.quantity <= 1) return 'EGP ${unit.toStringAsFixed(2)}';

    // UI format unchanged, only "Total" localized
    return 'EGP ${unit.toStringAsFixed(2)}  •  ${l10n.total}: ${total.toStringAsFixed(2)}';
  }
}

class _ProductImageCard extends StatelessWidget {
  final String imageUrl;

  const _ProductImageCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1.15,
        child: AppImage(
          url: imageUrl,
          width: double.infinity,
          height: double.infinity,
          borderRadius: 0,
          fit: BoxFit.contain,
          backgroundColor: Colors.transparent,
          placeholderIcon: Icons.fastfood,
        ),
      ),
    );
  }
}

/// ---------- Addons Section ----------
class _AddonsSection extends StatelessWidget {
  final ProductDetailsState state;
  final int productId;

  const _AddonsSection({required this.state, required this.productId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state.addonsStatus == Status.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.addonsStatus == Status.error) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          l10n.couldNotLoadExtrasOptional,
          style: TextStyle(color: Colors.grey[700]),
        ),
      );
    }

    if (state.addonGroups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          l10n.noExtrasAvailable,
          style: TextStyle(color: Colors.grey[700]),
        ),
      );
    }

    return _AddonsGroupsList(state: state);
  }
}

class _AddonsGroupsList extends StatelessWidget {
  final ProductDetailsState state;

  const _AddonsGroupsList({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: List.generate(state.addonGroups.length, (groupIndex) {
        final group = state.addonGroups[groupIndex];
        final title = _localize(context, en: group.titleEn, ar: group.titleAr);

        final selectedSet = state.selectedAddonsByGroup[groupIndex] ?? <int>{};
        final selectedSingle = selectedSet.isNotEmpty
            ? selectedSet.first
            : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    group.multiChoice ? l10n.multiple : l10n.single,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._buildAddonRows(
                context: context,
                group: group,
                groupIndex: groupIndex,
                selectedSet: selectedSet,
                selectedSingle: selectedSingle,
              ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildAddonRows({
    required BuildContext context,
    required AddonGroup group,
    required int groupIndex,
    required Set<int> selectedSet,
    required int? selectedSingle,
  }) {
    const divider = Divider(height: 18, thickness: 1, color: Color(0xFFEAEAEA));
    final items = <Widget>[];

    final enabledOptions = group.options.where((o) => o.enabled).toList();

    for (int i = 0; i < enabledOptions.length; i++) {
      final opt = enabledOptions[i];

      final optName = _localize(context, en: opt.nameEn, ar: opt.nameAr);
      final priceText = opt.price == 0 ? '0.00' : opt.price.toStringAsFixed(2);

      final row = group.multiChoice
          ? _AddonCheckRow(
              title: optName,
              priceText: priceText,
              checked: selectedSet.contains(opt.id),
              onTap: () => context.read<ProductDetailsCubit>().toggleAddon(
                groupIndex: groupIndex,
                optionId: opt.id,
              ),
            )
          : _AddonRadioRow(
              title: optName,
              priceText: priceText,
              selected: selectedSingle == opt.id,
              onTap: () => context.read<ProductDetailsCubit>().toggleAddon(
                groupIndex: groupIndex,
                optionId: opt.id,
              ),
            );

      items.add(row);
      if (i != enabledOptions.length - 1) items.add(divider);
    }

    return items;
  }
}

class _AddonCheckRow extends StatelessWidget {
  final String title;
  final String priceText;
  final bool checked;
  final VoidCallback onTap;

  const _AddonCheckRow({
    required this.title,
    required this.priceText,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: checked ? accent : const Color(0xFFCCCCCC),
                  width: 1.6,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'EGP $priceText',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddonRadioRow extends StatelessWidget {
  final String title;
  final String priceText;
  final bool selected;
  final VoidCallback onTap;

  const _AddonRadioRow({
    required this.title,
    required this.priceText,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? accent : const Color(0xFFCCCCCC),
                  width: 1.6,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'EGP $priceText',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- Variations ----------
class _VariationChips extends StatelessWidget {
  final VariableProduct product;
  final int? selectedVariationId;
  final ValueChanged<int> onSelect;

  const _VariationChips({
    required this.product,
    required this.selectedVariationId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const unselectedBg = Color(0xFF4A4A4A);
    const unselectedText = Colors.white;

    if (product.variations.isEmpty) {
      return Text(AppLocalizations.of(context).noVariations);
    }

    final selected = selectedVariationId ?? product.variations.first.id;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: product.variations.map((v) {
        final sizeLabel =
            (v.size.isEmpty ? AppLocalizations.of(context).option : v.size)
                .trim();

        final isSelected = v.id == selected;

        return _PillChoice(
          text: sizeLabel,
          selected: isSelected,
          selectedColor: accent,
          unselectedColor: unselectedBg,
          textColor: unselectedText,
          onTap: () => onSelect(v.id),
        );
      }).toList(),
    );
  }
}

class _PillChoice extends StatelessWidget {
  final String text;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color textColor;
  final VoidCallback onTap;

  const _PillChoice({
    required this.text,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    blurRadius: 14,
                    color: Colors.black.withOpacity(0.10),
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 14.5,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// ---------- Quantity ----------
class _QtyRow extends StatelessWidget {
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyRow({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    const softGrey = Color(0xFFF0F0F0);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircleQtyButton(
              bg: softGrey,
              icon: Icons.remove,
              iconColor: Colors.grey[800]!,
              onTap: onMinus,
            ),
            const SizedBox(width: 22),
            Text(
              '$quantity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 22),
            _CircleQtyButton(
              bg: accent,
              icon: Icons.add,
              iconColor: Colors.white,
              onTap: onPlus,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleQtyButton extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleQtyButton({
    required this.bg,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

/// ---------- Bottom bar ----------
class _BottomAddToCartBar extends StatelessWidget {
  final String guestId;
  final ProductDetailsState state;

  const _BottomAddToCartBar({required this.guestId, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final disabled = state.status != Status.success || state.product == null;
    final hasAddons = state.selectedAddonOptions.isNotEmpty;
    final qtyToSend = hasAddons ? 1 : state.quantity;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: pageBg,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.totalPrice != 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '${l10n.total}: EGP ${state.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: disabled
                    ? null
                    : () {
                        final cubit = context.read<CartCubit>();
                        final p = state.product!;
                        final variationId = state.selectedVariationId;

                        final addonsReq = state.selectedAddonOptions.map((a) {
                          return AddCartAddonRequest(
                            id: null,
                            name: a.nameEn,
                            price: a.price.toStringAsFixed(2),
                          );
                        }).toList();

                        final hasAddons = addonsReq.isNotEmpty;

                        final items = hasAddons
                            ? List.generate(
                                state.quantity,
                                (_) => AddCartItemRequest(
                                  productId: p.id,
                                  quantity: 1,
                                  variationId: variationId,
                                  addons: addonsReq,
                                ),
                              )
                            : [
                                AddCartItemRequest(
                                  productId: p.id,
                                  quantity: qtyToSend,
                                  variationId: variationId,
                                ),
                              ];

                        context.read<CartCubit>().addToCartDirect(
                          guestId: guestId,
                          items: items,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: cubit,
                              child: CartPage(guestId: guestId),
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: Text(l10n.addToCart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// For API dynamic strings only
String _localize(
  BuildContext context, {
  required String en,
  required String ar,
}) {
  final code = Localizations.localeOf(context).languageCode.toLowerCase();
  return (code == 'ar' && ar.trim().isNotEmpty) ? ar : en;
}
