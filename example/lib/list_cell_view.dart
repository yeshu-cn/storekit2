import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storekit2/product.dart';
import 'package:storekit2_example/store.dart';

class ListCellView extends StatefulWidget {
  final Product product;
  final bool purchaseEnabled;

  const ListCellView({super.key, required this.product, this.purchaseEnabled = true});

  @override
  State<ListCellView> createState() => _ListCellViewState();
}

class _ListCellViewState extends State<ListCellView> {

  @override
  Widget build(BuildContext context) {
    if (widget.purchaseEnabled) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProductDetail(),
            const Spacer(),
            _buildBuyButton(),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildProductDetail(),
      );
    }
  }

  Widget _buildProductDetail() {
    if (widget.product.type == Product.autoRenewable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.product.displayName, style: Theme.of(context).textTheme.bodyMedium),
          Text(widget.product.displayPrice, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    } else {
      return Text(widget.product.description, style: Theme.of(context).textTheme.bodyMedium);
    }
  }

  Widget _buildBuyButton() {
    var isPurchased = context.read<Store>().isPurchased(widget.product);
    if (isPurchased) {
      return const Icon(Icons.check);
    } else {
      if (widget.product.type == Product.autoRenewable) {
        return _buildSubscribeButton(widget.product.subscription!);
      } else {
        return ElevatedButton(
          onPressed: () {
            var store = context.read<Store>();
            store.purchaseProduct(widget.product.id);
          },
          child: const Text('Buy'),
        );
      }
    }
  }

  Widget _buildSubscribeButton(SubscriptionInfo subscriptionInfo) {
    String unit = '';
    bool plural = 1 < subscriptionInfo.subscriptionPeriod.value;
    switch (subscriptionInfo.subscriptionPeriod.unit) {
      case SubscriptionPeriod.day:
        unit = plural ? 'days' : 'day';
        break;
      case SubscriptionPeriod.week:
        unit = plural ? 'weeks' : 'week';
        break;
      case SubscriptionPeriod.month:
        unit = plural ? 'months' : 'month';
        break;
      case SubscriptionPeriod.year:
        unit = plural ? 'years' : 'year';
        break;
      default:
        unit = 'period';
    }

    unit = '${subscriptionInfo.subscriptionPeriod.value} $unit';
    return ElevatedButton(
      onPressed: () {
        var store = context.read<Store>();
        store.purchaseProduct(widget.product.id);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.product.displayPrice, style: Theme.of(context).textTheme.bodyMedium),
          Text(unit, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
