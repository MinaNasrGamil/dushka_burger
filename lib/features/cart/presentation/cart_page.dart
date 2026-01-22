import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dushka_burger/constants/enums.dart';
import 'package:dushka_burger/core/l10n/gen_l10n/app_localizations.dart';
import 'package:dushka_burger/core/widgets/app_image.dart';
import 'package:dushka_burger/core/widgets/app_state_views.dart';
import 'package:dushka_burger/features/cart/data/cart_remote_ds.dart';
import 'package:dushka_burger/features/cart/presentation/cart_cubit.dart';
import 'package:dushka_burger/features/cart/presentation/cart_state.dart';

const _pageBg = Color(0xFFF6F6F6);
const _cardBg = Colors.white;
const _accent = Color(0xFFD65A2F);

const _shadow = [
  BoxShadow(blurRadius: 18, color: Color(0x14000000), offset: Offset(0, 10)),
];

class CartPage extends StatefulWidget {
  final String guestId;

  const CartPage({super.key, required this.guestId});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().fetchCart(widget.guestId);
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state.status == Status.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _pageBg,
          appBar: AppBar(
            title: Text(l10n.cartTitle),
            centerTitle: true,
            elevation: 0,
            backgroundColor: _pageBg,
            surfaceTintColor: Colors.transparent,
          ),
          body: _buildBody(context, state),
          bottomNavigationBar: _TotalsBar(
            subtotal: state.subtotal,
            vat: state.vat,
            total: state.total,
            enabled: state.status == Status.success,
            onCheckout: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.checkoutUiOnly)));
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    final l10n = AppLocalizations.of(context);

    if (state.status == Status.loading || state.status == Status.initial) {
      return AppLoadingSkeleton(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 140),
          itemCount: 6,
          itemBuilder: (_, __) => const Card(
            child: ListTile(
              leading: CircleAvatar(),
              title: Text('Loading item'),
              subtitle: Text('EGP 000.00'),
              trailing: Icon(Icons.close),
            ),
          ),
        ),
      );
    }

    if (state.status == Status.error) {
      return AppErrorView(
        message: state.errorMessage,
        onRetry: () => context.read<CartCubit>().fetchCart(widget.guestId),
      );
    }

    final items = state.cart?.items ?? const [];

    if (items.isEmpty) {
      return AppEmptyView(
        icon: Icons.shopping_cart_outlined,
        title: l10n.cartEmpty,
        actionText: l10n.refresh,
        onAction: () => context.read<CartCubit>().fetchCart(widget.guestId),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<CartCubit>().fetchCart(widget.guestId),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 140),
        children: [
          ...items.map((item) {
            final hasAddons = item.addons.isNotEmpty;

            return _CartItemCard(
              name: item.nameEn.isNotEmpty ? item.nameEn : 'Item',
              nameAr: item.nameAr,
              imageUrl: item.image,
              qty: item.quantity,
              unitPrice: item.unitPrice,
              lineTotal: item.lineTotal,
              addonsCount: item.addons.length,
              addonNames: item.addons
                  .map(
                    (a) => (a.nameEn.isNotEmpty ? a.nameEn : a.nameAr).trim(),
                  )
                  .where((n) => n.isNotEmpty)
                  .toList(),
              onPlus: () {
                if (hasAddons) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.cannotIncreaseQtyExtrasSnack)),
                  );
                  return;
                }

                context.read<CartCubit>().addItem(
                  guestId: widget.guestId,
                  productId: item.productId,
                  variationId: item.variationId,
                  quantity: 1,
                );
              },
              onMinus: () {
                if (hasAddons) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.cannotChangeQtyExtrasSnack)),
                  );
                  return;
                }

                context.read<CartCubit>().removeItem(
                  guestId: widget.guestId,
                  productId: item.productId,
                  variationId: item.variationId,
                  quantity: 1,
                );
              },
              onDelete: () => context.read<CartCubit>().removeItem(
                guestId: widget.guestId,
                productId: item.productId,
                variationId: item.variationId,
                quantity: item.quantity,
                addons: item.addons
                    .map(
                      (a) => AddCartAddonRequest(
                        id: null,
                        name: a.nameEn.isNotEmpty ? a.nameEn : a.nameAr,
                        price: a.price.toStringAsFixed(2),
                      ),
                    )
                    .toList(),
              ),
            );
          }),
          const SizedBox(height: 12),
          _CouponSection(
            controller: _couponController,
            onApply: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.couponUiOnly)));
            },
          ),
        ],
      ),
    );
  }
}

/// ---------------- Widgets ----------------

class _CartItemCard extends StatelessWidget {
  final String name;
  final String nameAr;
  final String imageUrl;
  final int qty;
  final double unitPrice;
  final double lineTotal;
  final int addonsCount;

  final VoidCallback onPlus;
  final VoidCallback onMinus;
  final VoidCallback onDelete;
  final List<String> addonNames;

  const _CartItemCard({
    required this.name,
    required this.nameAr,
    required this.imageUrl,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
    required this.addonsCount,
    required this.onPlus,
    required this.onMinus,
    required this.onDelete,
    required this.addonNames,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final displayName = name; // UI unchanged
    final displayUnit = unitPrice == 0
        ? ''
        : 'EGP ${unitPrice.toStringAsFixed(2)}';
    final displayTotal = lineTotal == 0
        ? ''
        : 'EGP ${lineTotal.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _shadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image box (like mock)
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
            ),
            child: AppImage(
              url: imageUrl,
              width: 52,
              height: 52,
              borderRadius: 12,
              fit: BoxFit.contain,
              backgroundColor: Colors.transparent,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + delete icon row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.grey[700],
                      tooltip: l10n.remove,
                    ),
                  ],
                ),

                if (displayUnit.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(displayUnit, style: TextStyle(color: Colors.grey[700])),
                ],

                // Addons bullets + warning note
                if (addonsCount > 0) ...[
                  const SizedBox(height: 8),
                  ...addonNames
                      .take(3)
                      .map(
                        (n) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              const Text(
                                "• ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Expanded(
                                child: Text(
                                  n,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 6),
                  Text(
                    // UI-only note (like mock). Keeps your SnackBar logic unchanged.
                    'Quantity unavailable for custom items.\nRemove and re-add to change.',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Qty pill + line total aligned to the right
                Row(
                  children: [
                    _QtyPill(
                      qty: qty,
                      onMinus: qty <= 1 ? onDelete : onMinus,
                      onPlus: onPlus,
                    ),
                    const Spacer(),
                    if (displayTotal.isNotEmpty)
                      Text(
                        displayTotal,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: _accent,
                            ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtyPill({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    const softGrey = Color(0xFFF0F0F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniCircleButton(
            bg: softGrey,
            icon: Icons.remove,
            iconColor: Colors.grey[800]!,
            onTap: onMinus,
          ),
          const SizedBox(width: 14),
          Text(
            '$qty',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 14),
          _MiniCircleButton(
            bg: softGrey,
            icon: Icons.add,
            iconColor: Colors.grey[800]!,
            onTap: onPlus,
          ),
        ],
      ),
    );
  }
}

class _MiniCircleButton extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _MiniCircleButton({
    required this.bg,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

class _CouponSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;

  const _CouponSection({required this.controller, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _shadow,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.coupon,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: l10n.enterCouponCode,
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF4F4F4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n.apply),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalsBar extends StatelessWidget {
  final double subtotal;
  final double vat;
  final double total;
  final bool enabled;
  final VoidCallback onCheckout;

  const _TotalsBar({
    required this.subtotal,
    required this.vat,
    required this.total,
    required this.enabled,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: _pageBg,
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: _shadow,
              ),
              child: Column(
                children: [
                  _totalRow(l10n.subtotal, subtotal),
                  _totalRow(l10n.vat, vat),
                  const Divider(height: 18),
                  _totalRow(l10n.total, total, bold: true),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: enabled ? onCheckout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(l10n.checkout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text('EGP ${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
