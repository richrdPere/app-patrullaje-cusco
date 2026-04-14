import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sis_patrullaje_cusco/blocProviders.dart';
import 'package:sis_patrullaje_cusco/injection.dart';

// Routes
import 'package:sis_patrullaje_cusco/src/config/router/app_router.dart';
import 'package:sis_patrullaje_cusco/src/config/theme/app_theme.dart';

void main() async {
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider( 
      providers: blocProviders,
      child: MaterialApp.router(
        builder: FToastBuilder(),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        title: 'Sistema Patrullaje',
        theme: AppTheme(selectedColor: 0).getTheme(),
      ),
    );
  }
}
