# storekit2

iOS StoreKit 2 Flutter Plugin

参考官方demo，实现商店功能

## Features
1. 获取产品列表
2. 获取用户购买的产品列表
3. 获取某个订阅组的状态
4. restore购买
5. 监听购买状态的变化


## 说明
1. Transaction, RenewalInfo等等这些类并没有返回iOS平台完整的字段，有些字段暂时没用到，或者有些字段高于iOS 15以后才有，就没有添加。
2. Flutter层不做Transaction的验证，在iOS层做验证，验证成功后再返回给Flutter层数据，失败根据情况返回null或者错误信息。
3. iOS原生的StoreKit接口调用throw exception时会直接传递给Flutter Plugin Platform Exception, 但是Flutter插件层，没有解析和处理这个Exception, 所以如果调用插件接口的时候不try catch可能会导致程序崩溃

## StoreKit2 资料

### subscriptionGroupStatus
`subscriptionGroupStatus` 是一个用来表示订阅组状态的变量。在 StoreKit 2 中，`Product.SubscriptionInfo.Status.State` 枚举用来描述这个状态。它可以有以下几种可能的值：

1. `.subscribed`: 用户当前有一个活跃的订阅。
2. `.expired`: 用户之前订阅过，但现在订阅已过期。
3. `.revoked`: 用户的订阅被撤销（例如，由于退款）。
4. `.inGracePeriod`: 用户的订阅处于宽限期，通常是因为付款问题。
5. `.inBillingRetryPeriod`: 系统正在尝试再次收费。

举些例子来说明：

1. 新用户首次订阅：
    - 订阅前：`subscriptionGroupStatus` 可能是 `nil`
    - 订阅后：`subscriptionGroupStatus` 变为 `.subscribed`

2. 用户的订阅到期：
    - 到期前：`subscriptionGroupStatus` 是 `.subscribed`
    - 到期后：`subscriptionGroupStatus` 变为 `.expired`

3. 用户的付款方式失效，进入宽限期：
    - 正常订阅时：`subscriptionGroupStatus` 是 `.subscribed`
    - 进入宽限期：`subscriptionGroupStatus` 变为 `.inGracePeriod`

4. 用户在应用内请求退款，苹果批准了退款：
    - 退款前：`subscriptionGroupStatus` 是 `.subscribed`
    - 退款后：`subscriptionGroupStatus` 变为 `.revoked`

5. 用户的订阅即将到期，但由于某些原因（如信用卡过期）无法续费：
    - 正常订阅时：`subscriptionGroupStatus` 是 `.subscribed`
    - 系统尝试续费：`subscriptionGroupStatus` 可能变为 `.inBillingRetryPeriod`

在您的代码中，`subscriptionGroupStatus` 被用来确定用户的订阅状态。这对于管理用户访问权限、显示适当的UI、或者决定是否提供某些功能非常有用。

例如，您可以根据 `subscriptionGroupStatus` 的值来决定是显示"订阅"按钮还是"续订"按钮，或者是否允许用户访问某些仅限订阅者的内容。