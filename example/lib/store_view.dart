import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storekit2_example/list_cell_view.dart';
import 'package:storekit2_example/store.dart';
import 'package:storekit2_example/subscriptions_view.dart';

class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  bool _showLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, Store store, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('StoreKit2 Demo'),
          actions: [
            if (_showLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                  ),
                ),
              ),
            if (!_showLoading)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  setState(() {
                    _showLoading = true;
                  });
                  await store.restore();
                  setState(() {
                    _showLoading = false;
                  });
                },
              ),
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Cars', style: Theme.of(context).textTheme.labelLarge),
            ),
            ...store.cars.map((product) => ListCellView(product: product)),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(),
            ),
            const SubscriptionsView(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Navigation: Non-Renewing Subscription', style: Theme.of(context).textTheme.labelLarge),
            ),
            ...store.nonRenewables
                .map((product) => ListCellView(product: product, purchaseEnabled: store.purchasedSubscription.isEmpty)),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    // var store = context.read<Store>();
    // store.unListenForTransactions();
    super.dispose();
  }
}
