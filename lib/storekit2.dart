import 'package:storekit2/product.dart';
import 'package:storekit2/transaction.dart';

import 'storekit2_platform_interface.dart';

class Storekit2 {
  Future<String?> getPlatformVersion() {
    return Storekit2Platform.instance.getPlatformVersion();
  }

  Future<List<Product>> getProducts(List<String> productIds) async {
    return await Storekit2Platform.instance.getProducts(productIds);
  }

  Future<Transaction?> purchase(String productId) async {
    return await Storekit2Platform.instance.purchase(productId);
  }

  Future<bool> restore() async {
    return await Storekit2Platform.instance.restore();
  }

  Stream<Map<String, dynamic>> get transactionUpdates {
    return Storekit2Platform.instance.transactionUpdates;
  }

  void dispose() {
    return Storekit2Platform.instance.dispose();
  }

  // 获取当前权益
  Future<List<Transaction>> getCurrentEntitlements() async {
    return await Storekit2Platform.instance.getCurrentEntitlements();
  }

  // 获取订阅组状态
  Future<List<Status>> getSubscriptionStatus(String groupId) async {
    return await Storekit2Platform.instance.getSubscriptionStatus(groupId);
  }
}