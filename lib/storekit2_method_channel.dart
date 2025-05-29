import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:storekit2/product.dart';
import 'package:storekit2/transaction.dart';
import 'storekit2_platform_interface.dart';

/// An implementation of [Storekit2Platform] that uses method channels.
class MethodChannelStorekit2 extends Storekit2Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('storekit2');

  MethodChannelStorekit2() {
    methodChannel.setMethodCallHandler(_handleMethod);
  }

  final _transactionController =
      StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<List<Product>> getProducts(List<String> productIds) async {
    var result = await methodChannel
        .invokeMethod('getProducts', {'productIds': productIds});
    return List<dynamic>.from(result)
        .map((e) => Product.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<Transaction?> purchase(String appAccountToken, String productId) async {
    final result =
        await methodChannel.invokeMethod('purchase', {'productId': productId, 'appAccountToken': appAccountToken});
    // debugPrint('result: $result');
    return result != null
        ? Transaction.fromMap(Map<String, dynamic>.from(result))
        : null;
  }

  @override
  Future<bool> restore() async {
    debugPrint('restore');
    final result = await methodChannel.invokeMethod('restore');
    return result ?? false;
  }

  @override
  Stream<Map<String, dynamic>> get transactionUpdates =>
      _transactionController.stream;

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onTransactionUpdate':
        final Map<String, dynamic> transactionInfo =
            Map<String, dynamic>.from(call.arguments);
        _transactionController.add(transactionInfo);
        break;
      default:
        debugPrint('Unknown method ${call.method}');
    }
  }

  @override
  void dispose() {
    _transactionController.close();
  }

  @override
  Future<List<Transaction>> getCurrentEntitlements() async {
    var result = await methodChannel.invokeMethod('getCurrentEntitlements');
    debugPrint('get getCurrentEntitlements result: $result');
    if (result == null) {
      return [];
    }

    return List<dynamic>.from(result)
        .map((e) => Transaction.fromMap(e))
        .toList();
  }

  @override
  Future<List<Status>> getSubscriptionStatus(String groupId) async {
    var result = await methodChannel
        .invokeMethod('getSubscriptionStatus', {'groupId': groupId});
    if (result == null) {
      return [];
    }

    debugPrint('getSubscriptionGroupStatus result: $result');
    // 返回的是String，需要转换为枚举类型
    return List<dynamic>.from(result).map((e) => Status.fromMap(e)).toList();
  }
}
