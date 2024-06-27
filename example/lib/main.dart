import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storekit2/product.dart';
import 'dart:async';

import 'package:storekit2/storekit2.dart';
import 'package:storekit2_example/home_page.dart';
import 'package:storekit2_example/store.dart';
import 'package:storekit2_example/store_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Store(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoreKit2 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/store': (context) => const StoreView(),
      },
    );
  }
}

