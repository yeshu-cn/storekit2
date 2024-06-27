import 'package:flutter/cupertino.dart';
import 'package:storekit2/product.dart';
import 'package:storekit2/storekit2.dart';

class Store extends ChangeNotifier {
  List<Product> cars = [];
  List<Product> fuel = [];
  List<Product> subscriptions = [];
  List<Product> nonRenewables = [];

  List<Product> purchasedCars = [];
  List<Product> purchasedNonRenewableSubscriptions = [];
  List<Product> purchasedSubscription = [];

  Product? currentSubscription;
  Status? currentSubscriptionStatus;

  final _storekit2Plugin = Storekit2();
  final _productIds = [
    'subscription.standard',
    'subscription.premium',
    'subscription.pro',
    'nonRenewing.standard',
    'consumable.fuel.octane87',
    'consumable.fuel.octane89',
    'consumable.fuel.octane91',
    'nonconsumable.car',
    'nonconsumable.utilityvehicle',
    'nonconsumable.racecar',
  ];

  void init() async {
    //Start a transaction listener as close to app launch as possible so you don't miss any transactions.
    listenForTransactions();

    // get product list
    await requestProducts();

    // get customer purchased product list and subscription status
    await updateCustomerProductStatus();
  }

  requestProducts() async {
    var products = await _storekit2Plugin.getProducts(_productIds);

    fuel = products.where((element) => element.type == Product.consumable).toList();
    cars = products.where((element) => element.type == Product.nonConsumable).toList();
    subscriptions = products.where((element) => element.type == Product.autoRenewable).toList();
    nonRenewables = products.where((element) => element.type == Product.nonRenewable).toList();

    cars.sort((a, b) => a.price.compareTo(b.price));
    fuel.sort((a, b) => a.price.compareTo(b.price));
    subscriptions.sort((a, b) => a.price.compareTo(b.price));
    nonRenewables.sort((a, b) => a.price.compareTo(b.price));

    notifyListeners();
  }

  Future<bool> purchaseProduct(String productId) async {
    var transaction = await _storekit2Plugin.purchase(productId);
    if (null == transaction) {
      debugPrint('Failed to purchase product: $productId');
      return false;
    }

    // update customer product status
    await updateCustomerProductStatus();

    return true;
  }


  // //Iterate through any transactions that don't come from a direct call to `purchase()`.
  void listenForTransactions() {
    _storekit2Plugin.transactionUpdates.listen((transaction) {
      debugPrint('Transaction update received: $transaction');
      // update customer product status
      updateCustomerProductStatus();
    });
  }

  updateCustomerProductStatus() async {
    var transactions = await _storekit2Plugin.getCurrentEntitlements();
    var purchasedCars = <Product>[];
    var purchasedNonRenewableSubscriptions = <Product>[];
    var purchasedSubscription = <Product>[];

    for (var transaction in transactions) {
      switch (transaction.productId) {
        case 'nonconsumable.car':
        case 'nonconsumable.utilityvehicle':
        case 'nonconsumable.racecar':
          if (!purchasedCars.any((element) => element.id == transaction.productId)) {
            purchasedCars.add(cars.firstWhere((element) => element.id == transaction.productId));
          }
          break;
        case 'nonRenewing.standard':
        // noRenewing的产品，需要客户端自己实现具体的业务逻辑
        // 判断是否过期才加入已购买列表
        // 购买日期+1年
          var expiredDate = DateTime.fromMillisecondsSinceEpoch(transaction.purchaseDate.toInt()).add(const Duration(days: 365));
          if (DateTime.now().isBefore(expiredDate)) {
            if (!purchasedNonRenewableSubscriptions.any((element) => element.id == transaction.productId)) {
              purchasedNonRenewableSubscriptions
                  .add(nonRenewables.firstWhere((element) => element.id == transaction.productId));
            }
          }
          break;
        case 'subscription.standard':
        case 'subscription.premium':
        case 'subscription.pro':
          if (!purchasedSubscription.any((element) => element.id == transaction.productId)) {
            purchasedSubscription.add(subscriptions.firstWhere((element) => element.id == transaction.productId));
          }
          break;
        default:
          debugPrint('Unknown product: ${transaction.productId}');
      }
    }

    this.purchasedCars = purchasedCars;
    this.purchasedNonRenewableSubscriptions = purchasedNonRenewableSubscriptions;
    this.purchasedSubscription = purchasedSubscription;

    notifyListeners();
    await getSubscriptionStatus();
  }

  getSubscriptionStatus() async {
    // 会返回这个订阅组下所有Product订阅的状态， 但是所有Product的订阅状态Status中的state都是一样的,都表示这个订阅组的状态:new (never subscribed), active, expired, revoked, or in billing retry
    var statusList = await _storekit2Plugin.getSubscriptionStatus('3F19ED53');
    Product? highestSubscription;
    Status? highestSubscriptionStatus;

    for (var status in statusList) {
      if (status.state == Status.expired && status.state == Status.revoked) {
        break;
      }

      if (null == highestSubscription) {
        highestSubscriptionStatus = status;
        highestSubscription = subscriptions.firstWhere((element) => element.id == status.renewalInfo!.currentProductID);
      }

      // 可能有多个订阅， 找出优先级最高的订阅
      if (tier(status.renewalInfo!.currentProductID) > tier(highestSubscription!.id)) {
        highestSubscriptionStatus = status;
        highestSubscription = subscriptions.firstWhere((element) => element.id == status.renewalInfo!.currentProductID);
      }
    }

    currentSubscription = highestSubscription;
    currentSubscriptionStatus = highestSubscriptionStatus;
    notifyListeners();
  }

  int tier(String productId) {
    switch (productId) {
      case 'subscription.standard':
        return 1;
      case 'subscription.premium':
        return 2;
      case 'subscription.pro':
        return 3;
      default:
        return 0;
    }
  }

  Future<bool> restore() async {
    return await _storekit2Plugin.restore();
  }

  void unListenForTransactions() {
    _storekit2Plugin.dispose();
  }

  bool isPurchased(Product product) {
    switch (product.type) {
      case Product.nonConsumable:
        return purchasedCars.any((element) => element.id == product.id);
      case Product.autoRenewable:
        return purchasedSubscription.any((element) => element.id == product.id);
      case Product.nonRenewable:
        return purchasedNonRenewableSubscriptions.any((element) => element.id == product.id);
      default:
        return false;
    }
  }
}
