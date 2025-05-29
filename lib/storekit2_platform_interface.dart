import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:storekit2/product.dart';
import 'package:storekit2/transaction.dart';

import 'storekit2_method_channel.dart';

abstract class Storekit2Platform extends PlatformInterface {
  /// Constructs a Storekit2Platform.
  Storekit2Platform() : super(token: _token);

  static final Object _token = Object();

  static Storekit2Platform _instance = MethodChannelStorekit2();

  /// The default instance of [Storekit2Platform] to use.
  ///
  /// Defaults to [MethodChannelStorekit2].
  static Storekit2Platform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [Storekit2Platform] when
  /// they register themselves.
  static set instance(Storekit2Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<Product>> getProducts(List<String> productIds) {
    throw UnimplementedError('getProducts() has not been implemented.');
  }

  Future<Transaction?> purchase(String appAccountToken, String productId) {
    throw UnimplementedError('purchase() has not been implemented.');
  }

  Future<bool> restore() {
    throw UnimplementedError('restore() has not been implemented.');
  }

  Stream<Map<String, dynamic>> get transactionUpdates {
    throw UnimplementedError('transactionUpdates has not been implemented.');
  }

  void dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  Future<List<Transaction>> getCurrentEntitlements() {
    throw UnimplementedError('getCurrentEntitlements() has not been implemented.');
  }

  Future<List<Status>> getSubscriptionStatus(String groupId) {
    throw UnimplementedError('getSubscriptionGroupStatus() has not been implemented.');
  }

}
