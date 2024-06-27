import 'package:storekit2/transaction.dart';

class PaymentMode {
  static const String payAsYouGo = 'payAsYouGo';
  static const String payUpFront = 'payUpFront';
  static const String freeTrial = 'freeTrial';
}

class OfferType {
  static const String introductory = 'introductory';
  static const String promotional = 'promotional';
}

class ExpirationReason {
  static const String autoRenewDisabled = 'autoRenewDisabled';
  static const String billingError = 'billingError';
  static const String didNotConsentToPriceIncrease = 'didNotConsentToPriceIncrease';
  static const String productUnavailable = 'productUnavailable';
  static const String unknown = 'unknown';
}

class PriceIncreaseStatus {
  static const String noIncreasePending = 'noIncreasePending';
  static const String pending = 'pending';
  static const String agreed = 'agreed';
}

class Product {
  static const String consumable = 'consumable';
  static const String nonConsumable = 'nonConsumable';
  static const String autoRenewable = 'autoRenewable';
  static const String nonRenewable = 'nonRenewable';

  final String id;
  final String type;
  final String displayName;
  final String description;
  final double price;
  final String displayPrice;
  /// Properties and functionality specific to auto-renewable subscriptions.
  ///
  /// This is never `nil` if `type` is `.autoRenewable`, and always `nil` for all other product
  /// types.
  final SubscriptionInfo? subscription;

  Product({
    required this.id,
    required this.type,
    required this.displayName,
    required this.description,
    required this.price,
    required this.displayPrice,
    this.subscription,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      type: map['type'],
      displayName: map['displayName'],
      description: map['description'],
      price: map['price'],
      displayPrice: map['displayPrice'],
      subscription: map['subscription'] != null ? SubscriptionInfo.fromMap(map['subscription']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'displayName': displayName,
      'description': description,
      'price': price,
      'displayPrice': displayPrice,
      'subscription': subscription?.toMap(),
    };
  }
}

class SubscriptionInfo {
  /// An optional introductory offer that will automatically be applied if the user is eligible.
  final SubscriptionOffer? introductoryOffer;

  /// An array of all the promotional offers configured for this subscription.
  final List<SubscriptionOffer> promotionalOffers;

  /// The group identifier for this subscription.
  final String subscriptionGroupID;

  /// The duration that this subscription lasts before auto-renewing.
  final SubscriptionPeriod subscriptionPeriod;

  SubscriptionInfo({
    required this.introductoryOffer,
    required this.promotionalOffers,
    required this.subscriptionGroupID,
    required this.subscriptionPeriod,
  });

  factory SubscriptionInfo.fromMap(Map<dynamic, dynamic> map) {
    return SubscriptionInfo(
      introductoryOffer: map['introductoryOffer'] != null ? SubscriptionOffer.fromMap(map['introductoryOffer']) : null,
      promotionalOffers: List<SubscriptionOffer>.from(map['promotionalOffers'].map((e) => SubscriptionOffer.fromMap(e))),
      subscriptionGroupID: map['subscriptionGroupID'],
      subscriptionPeriod: SubscriptionPeriod.fromMap(map['subscriptionPeriod']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'introductoryOffer': introductoryOffer?.toMap(),
      'promotionalOffers': promotionalOffers.map((e) => e.toMap()).toList(),
      'subscriptionGroupID': subscriptionGroupID,
      'subscriptionPeriod': subscriptionPeriod.toMap(),
    };
  }
}

class SubscriptionOffer {
  /// The promotional offer identifier.
  ///
  /// This is always `nil` for introductory offers and never `nil` for promotional offers.
  final String? id;

  /// The type of offer.
  final String type;

  /// The discounted price that the offer provides in local currency.
  ///
  /// This is the price per period in the case of `.payAsYouGo`
  final double price;

  /// A localized string representation of `price`.
  final String displayPrice;

  /// The duration that this offer lasts before auto-renewing or changing to standard subscription
  /// renewals.
  final SubscriptionPeriod period;

  /// The number of periods this offer will renew for.
  ///
  /// Always 1 except for `.payAsYouGo`.
  final int periodCount;

  /// How the user is charged for this offer.
  final String paymentMode;

  SubscriptionOffer({
    required this.id,
    required this.type,
    required this.price,
    required this.displayPrice,
    required this.period,
    required this.periodCount,
    required this.paymentMode,
  });

  factory SubscriptionOffer.fromMap(Map<dynamic, dynamic> map) {
    return SubscriptionOffer(
      id: map['id'],
      type: map['type'],
      price: map['price'],
      displayPrice: map['displayPrice'],
      period: SubscriptionPeriod.fromMap(map['period']),
      periodCount: map['periodCount'],
      paymentMode: map['paymentMode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'price': price,
      'displayPrice': displayPrice,
      'period': period.toMap(),
      'periodCount': periodCount,
      'paymentMode': paymentMode,
    };
  }
}

class SubscriptionPeriod {
  static const String day = "day";
  static const String week = "week";
  static const String month = "month";
  static const String year = "year";

  /// The number of units that the period represents.
  final int value;

  /// The unit of time that this period represents.
  final String unit;

  SubscriptionPeriod({
    required this.value,
    required this.unit,
  });

  factory SubscriptionPeriod.fromMap(Map<dynamic, dynamic> map) {
    return SubscriptionPeriod(
      value: map['value'],
      unit: map['unit'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'unit': unit,
    };
  }
}

class Status {
  static const String subscribed = 'subscribed';
  static const String expired = 'expired';
  static const String revoked = 'revoked';
  static const String inGracePeriod = 'inGracePeriod';
  static const String inBillingRetryPeriod = 'inBillingRetryPeriod';

  // 这里面的状态代表着整个订阅组的状态
  final String state;
  final Transaction? transaction;
  final RenewalInfo? renewalInfo;

  Status({
    required this.state,
    required this.transaction,
    required this.renewalInfo,
  });

  factory Status.fromMap(Map<dynamic, dynamic> map) {
    return Status(
      state: map['state'],
      transaction: map['transaction'] != null ? Transaction.fromMap(map['transaction']) : null,
      renewalInfo: map['renewalInfo'] != null ? RenewalInfo.fromMap(map['renewalInfo']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': state,
      'transaction': transaction?.toMap(),
      'renewalInfo': renewalInfo?.toMap(),
    };
  }
}

class RenewalInfo {
  /// The original transaction identifier for the subscription group.
  final int originalTransactionID;

  /// The currently active product identifier, or the most recently active product identifier if the
  /// subscription is expired.
  final String currentProductID;

  /// Whether the subscription will auto renew at the end of the current billing period.
  final bool willAutoRenew;

  /// The product identifier the subscription will auto renew to at the end of the current billing period.
  ///
  /// If the user disabled auto renewing, this property will be `nil`.
  final String? autoRenewPreference;

  /// The reason the subscription expired.
  final String? expirationReason;

  /// Whether the subscription is in a billing retry period.
  final bool isInBillingRetry;

  /// The date the billing grace period will expire.
  final int? gracePeriodExpirationDate;

  /// Identifies the offer that will be applied to the next billing period.
  ///
  /// If `offerType` is `promotional`, this will be the offer identifier. If `offerType` is
  /// `code`, this will be the offer code reference name. This will be `nil` for `introductory`
  /// offers and if there will be no offer applied for the next billing period.
  final String? offerID;

  /// The type of the offer that will be applied to the next billing period.
  final String? offerType;

  final int recentSubscriptionStartDate;

  final int? renewalDate;

  RenewalInfo({
    required this.originalTransactionID,
    required this.currentProductID,
    required this.willAutoRenew,
    required this.autoRenewPreference,
    required this.expirationReason,
    required this.isInBillingRetry,
    required this.gracePeriodExpirationDate,
    required this.offerID,
    required this.offerType,
    required this.recentSubscriptionStartDate,
    required this.renewalDate,
  });

  factory RenewalInfo.fromMap(Map<dynamic, dynamic> map) {
    return RenewalInfo(
      originalTransactionID: map['originalTransactionID'],
      currentProductID: map['currentProductID'],
      willAutoRenew: map['willAutoRenew'],
      autoRenewPreference: map['autoRenewPreference'],
      expirationReason: map['expirationReason'],
      isInBillingRetry: map['isInBillingRetry'],
      gracePeriodExpirationDate: map['gracePeriodExpirationDate'],
      offerID: map['offerID'],
      offerType: map['offerType'],
      recentSubscriptionStartDate: map['recentSubscriptionStartDate'],
      renewalDate: map['renewalDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'originalTransactionID': originalTransactionID,
      'currentProductID': currentProductID,
      'willAutoRenew': willAutoRenew,
      'autoRenewPreference': autoRenewPreference,
      'expirationReason': expirationReason,
      'isInBillingRetry': isInBillingRetry,
      'gracePeriodExpirationDate': gracePeriodExpirationDate,
      'offerID': offerID,
      'offerType': offerType,
      'recentSubscriptionStartDate': recentSubscriptionStartDate,
      'renewalDate': renewalDate,
    };
  }
}
