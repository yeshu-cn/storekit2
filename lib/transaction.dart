class Offer {
  final String? id;
  final int type;
  final String? paymentMode;

  Offer({this.id, required this.type, this.paymentMode});

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'],
      type: map['type'],
      paymentMode: map['paymentMode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'paymentMode': paymentMode,
    };
  }
}

class Transaction {
  /// Unique ID for the transaction.
  final int id;

  /// The ID of the original transaction for `productID` or`subscriptionGroupID` if this is a
  /// subscription.
  final int originalID;

  /// Uniquely identifies a subscription purchase.
  /// - Note: Only for subscriptions.
  final String? webOrderLineItemID;

  /// Identifies the product the transaction is for.
  final String productId;

  /// Identifies the subscription group the transaction is for.
  /// - Note: Only for subscriptions.
  final String? subscriptionGroupID;

  /// Identifies the application the transaction is for.
  final String appBundleID;

  /// The date this transaction occurred on.
  final int purchaseDate;

  /// The date the original transaction for `productID` or`subscriptionGroupID` occurred on.
  final int originalPurchaseDate;

  /// The date the users access to `productID` expires
  /// - Note: Only for subscriptions.
  final int? expirationDate;

  /// Quantity of `productID` purchased in the transaction.
  /// - Note: Always 1 for non-consumables and auto-renewable suscriptions.
  final int purchaseQuantity;

  /// If this transaction was upgraded to a subscription with a higher level of service.
  /// - Important: If this property is `true`, look for a new transaction for a subscription with a
  ///              higher level of service.
  /// - Note: Only for subscriptions.
  final bool? isUpgraded;

  /// The date the transaction was revoked, or `nil` if it was not revoked.
  final int? revocationDate;

  /// The reason the transaction was revoked, or `nil` if it was not revoked.
  final int? revocationReason;

  /// The type of `productID`.
  final String productType;

  /// If an app account token was added as a purchase option when purchasing, this property will
  /// be the token provided. If no token was provided, this will be `nil`.
  final String? appAccountToken;

  /// JWS representation of the transaction for server-side verification
  final String? jwsRepresentation;

  Transaction({
    required this.id,
    required this.originalID,
    this.webOrderLineItemID,
    required this.productId,
    this.subscriptionGroupID,
    required this.appBundleID,
    required this.purchaseDate,
    required this.originalPurchaseDate,
    this.expirationDate,
    required this.purchaseQuantity,
    this.isUpgraded,
    this.revocationDate,
    this.revocationReason,
    required this.productType,
    this.appAccountToken,
    this.jwsRepresentation,
  });

  factory Transaction.fromMap(Map<dynamic, dynamic> map) {
    return Transaction(
      id: map['id'],
      originalID: map['originalID'],
      webOrderLineItemID: map['webOrderLineItemID'],
      productId: map['productId'],
      subscriptionGroupID: map['subscriptionGroupID'],
      appBundleID: map['appBundleID'],
      purchaseDate: map['purchaseDate'],
      originalPurchaseDate: map['originalPurchaseDate'],
      expirationDate: map['expirationDate'],
      purchaseQuantity: map['purchaseQuantity'],
      isUpgraded: map['isUpgraded'],
      revocationDate: map['revocationDate'],
      revocationReason: map['revocationReason'],
      productType: map['productType'],
      appAccountToken: map['appAccountToken'],
      jwsRepresentation: map['jwsRepresentation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalID': originalID,
      'webOrderLineItemID': webOrderLineItemID,
      'productId': productId,
      'subscriptionGroupID': subscriptionGroupID,
      'appBundleID': appBundleID,
      'purchaseDate': purchaseDate,
      'originalPurchaseDate': originalPurchaseDate,
      'expirationDate': expirationDate,
      'purchaseQuantity': purchaseQuantity,
      'isUpgraded': isUpgraded,
      'revocationDate': revocationDate,
      'revocationReason': revocationReason,
      'productType': productType,
      'appAccountToken': appAccountToken,
      'jwsRepresentation': jwsRepresentation,
    };
  }
}
