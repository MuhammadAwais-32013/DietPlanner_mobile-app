import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.initialize();
  runApp(DiaBPApp(authProvider: authProvider));
}

class DiaBPApp extends StatelessWidget {
  final AuthProvider authProvider;
  const DiaBPApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authProvider,
      child: Builder(
        builder: (context) {
          final router = createRouter(authProvider);
          return MaterialApp.router(
            title: 'DiaBP Diet Consultant',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
