import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storekit2/product.dart';
import 'package:storekit2_example/list_cell_view.dart';
import 'package:storekit2_example/store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    final store = context.read<Store>();
    store.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StoreKit2 Demo'),
      ),
      body: Consumer(builder: (context, Store store, child) {
        if (store.purchasedCars.isEmpty &&
            store.purchasedNonRenewableSubscriptions.isEmpty &&
            store.purchasedSubscription.isEmpty) {
          return _buildNoPurchases();
        } else {
          return _buildPurchasedProducts(store);
        }
      }),
    );
  }

  Widget _buildNoPurchases() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Head to the store to purchase some products!', style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/store'),
            child: const Text('Go to Store'),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasedProducts(Store store) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('My Cars', style: Theme.of(context).textTheme.titleLarge),
          ),
          _buildMyCars(store.purchasedCars),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Navigation Service', style: Theme.of(context).textTheme.titleLarge),
          ),
          _buildNavigationService(store),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/store'),
            child: const Text('Go to Store'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCars(List<Product> cars) {
    if (cars.isEmpty) {
      return Text("You don't own any car products. \nHead over to the shop to get started!",
          style: Theme.of(context).textTheme.bodyMedium);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...cars.map(
            (product) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListCellView(product: product, purchaseEnabled: false),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildNavigationService(Store store) {
    if (store.purchasedNonRenewableSubscriptions.isNotEmpty || store.purchasedSubscription.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...store.purchasedNonRenewableSubscriptions
              .map((product) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListCellView(product: product, purchaseEnabled: false),
              )),
          ...store.purchasedSubscription.map((product) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListCellView(product: product, purchaseEnabled: false),
          )),
        ],
      );
    } else {
      return Text("You don't own any subscriptions. \nHead over to the shop to get started!",
          style: Theme.of(context).textTheme.bodyMedium);
    }
  }
}
