import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storekit2/product.dart';
import 'package:storekit2_example/list_cell_view.dart';
import 'package:storekit2_example/store.dart';

class SubscriptionsView extends StatefulWidget {
  const SubscriptionsView({super.key});

  @override
  State<SubscriptionsView> createState() => _SubscriptionsViewState();
}

class _SubscriptionsViewState extends State<SubscriptionsView> {
  @override
  Widget build(BuildContext context) {
    var currentSubscription = context.select((Store store) => store.currentSubscription);
    var availableProducts = (context.select((Store store) => store.subscriptions))
        .where((element) => element.id != currentSubscription?.id)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (null != currentSubscription) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('My Subscriptions', style: Theme.of(context).textTheme.labelLarge),
          ),
          ListCellView(product: currentSubscription, purchaseEnabled: false),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildStatusInfo(),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Navigation: Auto-Renewable Subscription', style: Theme.of(context).textTheme.labelLarge),
        ),
        ...availableProducts.map((product) => ListCellView(product: product)),
      ],
    );
  }

  Widget _buildStatusInfo() {
    var store = context.read<Store>();
    var state = store.currentSubscriptionStatus!.state;
    switch (state) {
      case Status.subscribed:
        return Text('You are currently subscribed to ${store.currentSubscription!.displayName}');
      case Status.expired:
        return Text(_expirationDescription());
      case Status.revoked:
        var revokedDate = DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(DateTime.fromMillisecondsSinceEpoch(store.currentSubscriptionStatus!.transaction!.revocationDate!));
        return Text(
            'The App Store refunded your subscription to ${store.currentSubscription!.displayName} on $revokedDate');
      case Status.inGracePeriod:
        return Text(_gracePeriodDescription());
      case Status.inBillingRetryPeriod:
        return Text(_billingRetryDescription());
      default:
        return const Text('Unknown');
    }
  }

  String _expirationDescription() {
    var store = context.read<Store>();
    var expirationDate = store.currentSubscriptionStatus?.transaction?.expirationDate;
    var expirationReason = store.currentSubscriptionStatus?.renewalInfo?.expirationReason;
    if (null == expirationDate || null == expirationReason) {
      return 'Your subscription to ${store.currentSubscription!.displayName} was not renewed.';
    }
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(expirationDate));
    switch (expirationReason) {
      case ExpirationReason.autoRenewDisabled:
        return 'Your subscription to ${store.currentSubscription!.displayName} will expire on $formattedDate.';
      case ExpirationReason.billingError:
        return 'Your subscription to ${store.currentSubscription!.displayName} was not renewed due to a billing error.';
      case ExpirationReason.didNotConsentToPriceIncrease:
        return 'Your subscription to ${store.currentSubscription!.displayName} was not renewed due to a price increase that you disapproved';
      case ExpirationReason.productUnavailable:
        return 'Your subscription to ${store.currentSubscription!.displayName} was not renewed due to the product becoming unavailable.';
      default:
        return 'Your subscription to ${store.currentSubscription!.displayName} was not renewed.';
    }
  }

  String _gracePeriodDescription() {
    var description =
        'The App Store could not confirm your billing information for ${context.read<Store>().currentSubscription!.displayName}.';
    var gracePeriodDeadline = context.read<Store>().currentSubscriptionStatus!.renewalInfo!.gracePeriodExpirationDate;
    if (null != gracePeriodDeadline) {
      var formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(gracePeriodDeadline));
      description += ' You have until $formattedDate to update your billing information.';
    }
    return description;
  }

  String _billingRetryDescription() {
    var description =
        'The App Store could not confirm your billing information for ${context.read<Store>().currentSubscription!.displayName}.';
    description += "Please verify your billing information to resume service.";
    return description;
  }
}
