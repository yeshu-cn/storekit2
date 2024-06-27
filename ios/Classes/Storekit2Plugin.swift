import Flutter
import UIKit
import StoreKit

public enum StoreError: Error {
    case failedVerification
    case invalidArguments(String)
    case productNotFound
}

public class Storekit2Plugin: NSObject, FlutterPlugin {
    private var transactionListenerTask: Task<Void, Error>?
    private var channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
        startTransactionListener()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "storekit2", binaryMessenger: registrar.messenger())
        let instance = Storekit2Plugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getProducts":
            handleGetProducts(call, result: result)
        case "purchase":
            handlePurchase(call, result: result)
        case "restore":
            handleRestore(result: result)
        case "getCurrentEntitlements":
            handleGetCurrentEntitlements(result: result)
        case "getSubscriptionStatus":
            handleGetSubscriptionStatus(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleError(_ error: Error, result: FlutterResult) {
        if let storeError = error as? StoreError {
            switch storeError {
            case .failedVerification:
                result(FlutterError(code: "VERIFICATION_FAILED", message: "Transaction failed verification", details: nil))
            case .invalidArguments(let message):
                result(FlutterError(code: "INVALID_ARGUMENTS", message: message, details: nil))
            case .productNotFound:
                result(FlutterError(code: "PRODUCT_NOT_FOUND", message: "Product not found", details: nil))
            }
        } else {
            result(FlutterError(code: "UNKNOWN_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func handleGetProducts(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let productIds = args["productIds"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for getProducts", details: nil))
            return
        }
        
        Task {
            do {
                let products = try await Product.products(for: Set(productIds))
                result(products.map { $0.toMap() })
            } catch {
                handleError(error, result: result)
            }
        }
    }
    
    private func handlePurchase(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let productId = args["productId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for purchase", details: nil))
            return
        }
        
        Task {
            do {
                let products = try await Product.products(for: [productId])
                guard let product = products.first else {
                    throw StoreError.productNotFound
                }
                let transaction = try await purchaseProduct(product)
                result(transaction?.toMap())
            } catch {
                handleError(error, result: result)
            }
        }
    }
    
    private func purchaseProduct(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    private func handleRestore(result: @escaping FlutterResult) {
        Task {
            do {
                try await AppStore.sync()
                result(true)
            } catch {
                handleError(error, result: result)
            }
        }
    }
    
    private func handleGetCurrentEntitlements(result: @escaping FlutterResult) {
         Task {
             let entitlements = await getCurrentEntitlements()
             result(entitlements)
         }
     }
    
    func getCurrentEntitlements() async -> [[String: Any?]] {
        var entitlements: [[String: Any?]] = []
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                let item: [String: Any?] = transaction.toMap()
                entitlements.append(item)
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        return entitlements
    }
    
    private func handleGetSubscriptionStatus(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let groupId = args["groupId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for getSubscriptionStatus", details: nil))
            return
        }
        
        Task {
            do {
                let statuses = try await Product.SubscriptionInfo.status(for: groupId)
                result(statuses.map { $0.toMap() })
            } catch {
                handleError(error, result: result)
            }
        }
    }

    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    
                    // 通知 Flutter 端有新的交易
                    self.notifyTransactionUpdate(transaction)
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    private func startTransactionListener() {
        transactionListenerTask = listenForTransactions()
    }
    
    private func notifyTransactionUpdate(_ transaction: Transaction) {
        DispatchQueue.main.async {
            self.channel.invokeMethod("onTransactionUpdate", arguments: transaction.toMap())
        }
    }
    
    deinit {
        // 取消监听任务
        transactionListenerTask?.cancel()
    }
}
