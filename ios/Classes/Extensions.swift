import Foundation
import StoreKit

extension Transaction {
    func toMap() -> [String: Any?] {
        return [
            "id": self.id,
            "originalID": self.originalID,
            "webOrderLineItemID": self.webOrderLineItemID,
            "productId": self.productID,
            "subscriptionGroupID": self.subscriptionGroupID,
            "appBundleID": self.appBundleID,
            "purchaseDate": Int(self.purchaseDate.timeIntervalSince1970 * 1000),
            "originalPurchaseDate": Int(self.originalPurchaseDate.timeIntervalSince1970 * 1000),
            "expirationDate": self.expirationDate != nil ? Int(self.expirationDate!.timeIntervalSince1970 * 1000) : nil,
            "purchaseQuantity": self.purchasedQuantity,
            "isUpgraded": self.isUpgraded,
            "revocationDate": self.revocationDate != nil ? Int(self.revocationDate!.timeIntervalSince1970 * 1000) : nil,
            "revocationReason": self.revocationReason?.rawValue,
            "productType": self.productType.toString(),
            "appAccountToken": self.appAccountToken?.uuidString
        ]
    }
}

extension Product.ProductType {
    func toString() -> String {
        switch self {
        case .autoRenewable:
            return "autoRenewable"
        case .consumable:
            return "consumable"
        case .nonConsumable:
            return "nonConsumable"
        case .nonRenewable:
            return "nonRenewable"
        default:
            return "unknown"
        }
    }
}

extension Product {
    func toMap() -> [String: Any?] {
        return [
            "id": self.id,
            "type": self.type.toString(),
            "displayName": self.displayName,
            "description": self.description,
            "price": self.price,
            "displayPrice": self.displayPrice,
            "isFamilyShareable": self.isFamilyShareable,
            "subscription": self.subscription?.toMap()
        ]
    }
}

extension Product.SubscriptionInfo {
    func toMap() -> [String: Any?] {
        return [
            "introductoryOffer": self.introductoryOffer?.toMap(),
            "promotionalOffers": self.promotionalOffers.map { $0.toMap() },
            "subscriptionGroupID": self.subscriptionGroupID,
            "subscriptionPeriod": self.subscriptionPeriod.toMap()
        ]
    }
}

extension Product.SubscriptionOffer {
    func toMap() -> [String: Any?] {
        return [
            "id": self.id,
            "type": self.type.toString(),
            "price": self.price,
            "displayPrice": self.displayPrice,
            "period": self.period.toMap(),
            "periodCount": self.periodCount,
            "paymentMode": self.paymentMode.toString(),
        ]
    }
}

extension Product.SubscriptionOffer.PaymentMode {
    func toString() -> String {
        switch self {
        case .freeTrial:
            return "freeTrial"
        case .payUpFront:
            return "payUpFront"
        case .payAsYouGo:
            return "payAsYouGo"
        default:
            return "unknown"
        }
    }
}

extension Product.SubscriptionOffer.OfferType {
    func toString() -> String {
        switch self {
        case .introductory:
            return "introductory"
        case .promotional:
            return "promotional"
        default:
            return "unknown"
        }
    }
}

extension Product.SubscriptionPeriod {
    func toMap() -> [String: Any?] {
        return [
            "unit": self.unit.toString(),
            "value": self.value
        ]
    }
}

extension Product.SubscriptionPeriod.Unit {
    func toString() -> String {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        @unknown default:
            return "unknown"
        }
    }
}

extension Product.SubscriptionInfo.RenewalState {
    func toString() -> String {
        switch self {
        case .subscribed:
            return "subscribed"
        case .expired:
            return "expired"
        case .revoked:
            return "revoked"
        case .inGracePeriod:
            return "inGracePeriod"
        case .inBillingRetryPeriod:
            return "inBillingRetryPeriod"
        default:
            return "unknown"
        }
    }
}

extension Product.SubscriptionInfo.Status {
    func toMap() -> [String: Any?] {
        let transactionValue: Transaction?
        let renewalInfoValue: Product.SubscriptionInfo.RenewalInfo?
        
        switch self.transaction {
        case .verified(let value):
            transactionValue = value
        case .unverified:
            transactionValue = nil
        }
        
        switch self.renewalInfo {
        case .verified(let value):
            renewalInfoValue = value
        case .unverified:
            renewalInfoValue = nil
        }
        return [
            "state": self.state.toString(),
            "transaction": transactionValue?.toMap(),
            "renewalInfo": renewalInfoValue?.toMap(),
        ]
    }
}

extension Product.SubscriptionInfo.RenewalInfo {
    func toMap() -> [String: Any?] {
        return [
            "originalTransactionID": self.originalTransactionID,
            "currentProductID": self.currentProductID,
            "willAutoRenew": self.willAutoRenew,
            "autoRenewPreference": self.autoRenewPreference,
            "expirationReason": self.expirationReason?.toString(),
            "priceIncreaseStatus": self.priceIncreaseStatus.toString(),
            "isInBillingRetry": self.isInBillingRetry,
            "gracePeriodExpirationDate": self.gracePeriodExpirationDate != nil ? Int(self.gracePeriodExpirationDate!.timeIntervalSince1970 * 1000) : nil,
            "offerID": self.offerID,
            "offerType": self.offerType?.rawValue,
            "recentSubscriptionStartDate": Int(self.recentSubscriptionStartDate.timeIntervalSince1970 * 1000),
            "renewalDate": self.renewalDate != nil ? Int(self.renewalDate!.timeIntervalSince1970 * 1000) : nil,
            "signedDate": Int(self.signedDate.timeIntervalSince1970 * 1000),
        ]
    }
}

extension Product.SubscriptionInfo.RenewalInfo.ExpirationReason {
    func toString() -> String {
        switch self {
        case.autoRenewDisabled:
            return "autoRenewDisabled"
        case .billingError:
            return "billingError"
        case .didNotConsentToPriceIncrease:
            return "didNotConsentToPriceIncrease"
        case .productUnavailable:
            return "productUnavailable"
        case .unknown:
            return "unknown"
        default:
            return ""
        }
    }
}

extension Product.SubscriptionInfo.RenewalInfo.PriceIncreaseStatus {
    func toString() -> String {
        switch self {
        case .noIncreasePending:
            return "noIncreasePending"
        case .pending:
            return "pending"
        case . agreed:
            return "agreed"
        default:
            return ""
        }
    }
}
