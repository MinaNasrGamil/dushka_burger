import 'package:dushka_burger/core/di/di.dart';
import 'package:dushka_burger/features/cart/presentation/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

import 'constants/enums.dart';

// ✅ Phase 5: AppLocalizations import (update path if your output-dir differs)
import 'package:dushka_burger/core/l10n/gen_l10n/app_localizations.dart';

// ===== Guest =====
import 'features/guest/presentation/guest_cubit.dart';
import 'features/guest/presentation/guest_state.dart';

// ===== Menu =====
import 'features/menu/presentation/categories_cubit.dart';
import 'features/menu/presentation/categories_page.dart';

final sl = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ Phase 5: generated l10n delegates + locales
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: BlocProvider(
        create: (_) => sl<GuestCubit>()..init(),
        child: const GuestGate(),
      ),
    );
  }
}

/// Ensures guest_id exists then opens Categories screen.
class GuestGate extends StatelessWidget {
  const GuestGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestCubit, GuestState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);

        if (state.status == Status.initial || state.status == Status.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == Status.error) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<GuestCubit>().init(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => sl<CategoriesCubit>()..fetchCategories(),
            ),
            BlocProvider(
              create: (_) => sl<CartCubit>()..fetchCart(state.guestId),
            ),
          ],
          child: CategoriesPage(guestId: state.guestId),
        );
      },
    );
  }
}
