import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhatro_management/core/constants/supabase_constants.dart';
// import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/core/theme/app_theme.dart';
// import 'package:nhatro_management/features/dashboard/presentation/views/main_dashboard_view.dart';

// --- CHUẨN HÓA SANG PACKAGE IMPORT ---
import 'package:nhatro_management/features/room/data/repositories/room_repository.dart';
import 'package:nhatro_management/features/tenant/data/repositories/tenant_repository.dart';
import 'package:nhatro_management/features/invoice/data/repositories/invoice_repository.dart';

import 'package:nhatro_management/features/room/presentation/bloc/room_bloc.dart';
import 'package:nhatro_management/features/tenant/presentation/bloc/tenant_bloc.dart';
import 'package:nhatro_management/features/invoice/presentation/bloc/invoice_bloc.dart';

import 'package:nhatro_management/features/onboarding/presentation/views/welcome_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RoomRepository>(create: (_) => RoomRepository(supabase)),
        RepositoryProvider<TenantRepository>(create: (_) => TenantRepository(supabase)),
        RepositoryProvider<InvoiceRepository>(create: (_) => InvoiceRepository(supabase)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<RoomBloc>(create: (context) => RoomBloc(context.read<RoomRepository>())),
          BlocProvider<TenantBloc>(create: (context) => TenantBloc(context.read<TenantRepository>())),
          BlocProvider<InvoiceBloc>(create: (context) => InvoiceBloc(context.read<InvoiceRepository>())),
        ],
        child: MaterialApp(
          title: 'LOZIDO',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const WelcomeView(),
        ),
      ),
    );
  }
}
