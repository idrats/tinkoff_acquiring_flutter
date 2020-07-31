import Flutter
import UIKit
import TinkoffASDKCore
import TinkoffASDKUI

public class SwiftTinkoffAcquiringPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tinkoff_acquiring", binaryMessenger: registrar.messenger())
    let instance = SwiftTinkoffAcquiringPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
  }

    
public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("------------------")
    print(call.arguments ?? "")
    print(call.method)
    print("------------------")
    if (call.method == "openPaymentScreen") {
        let testCredentional = AcquiringSdkCredential(terminalKey: StageTestData.terminalKey, password: StageTestData.terminalPassword, publicKey: StageTestData.testPublicKey)
        // конфигурация для старта sdk
        let acquiringSDKConfiguration = AcquiringSdkConfiguration(credential: testCredentional, server: AcquiringSdkEnvironment.test)
        // включаем логи, результаты работы запросов пишутся в консоль
        acquiringSDKConfiguration.logger = AcquiringLoggerDefault()

        if let sdk = try? AcquiringUISDK.init(configuration: acquiringSDKConfiguration) {
            // SDK проинициализировалось, можно приступать к работе
            sdk.presentPaymentView(on: UIApplication.shared.delegate!.window!!.rootViewController!,
            paymentData: PaymentInitData.init(amount: NSDecimalNumber.init(value: 2000), orderId: Int64(arc4random()), customerKey: StageTestData.customerKey),
            configuration: AcquiringViewConfigration.init()) { (_ response: Result<PaymentStatusResponse, Error>) in
                var message = ""
                switch response {
                    case .success(let result):
                        var message = NSLocalizedString("text.paymentStatusAmount", comment: "Покупка на сумму")
                        message.append(" \(Utils.formatAmount(result.amount)) ")
                        if result.status == .cancelled {
                            message.append(NSLocalizedString("text.paymentStatusCancel", comment: "отменена"))
                        } else {
                            message.append(" ")
                            message.append(NSLocalizedString("text.paymentStatusSuccess", comment: "paymentStatusSuccess"))
                            message.append("\npaymentId = \(result.paymentId)")
                        }
                    case .failure(let error):
                        message = error.localizedDescription
                }
                result(message)
           }
        } else {
           result("not initialized")
        }
        
    } else if(call.method == "getPlatformVersion") {
        result("iOS " + UIDevice.current.systemVersion)
    } else {
        result(FlutterMethodNotImplemented)
    }
  }

//
//  let products = [
//        Product.init(price: 100.0, name: "Шантарам - 2. Тень горы", id: 1),
//        Product.init(price: 200.0, name: "Воздушные змеи", id: 1),
//        Product.init(price: 300.0, name: "Чайка по имени Джонатан Ливингстон", id: 1)
//    ]
//
    
//    private func productsAmount() -> Double {
//        var amount: Double = 0
//
//        products.forEach { (product) in
//            amount += product.price.doubleValue
//        }
//
//        return amount
//    }
    
//    private func createPaymentData() -> PaymentInitData {
//        let amount = productsAmount()
//        var paymentData = PaymentInitData.init(amount: NSDecimalNumber.init(value: amount), orderId: Int64(arc4random()), customerKey: StageTestData.customerKey)
//        var receiptItems: [Item] = []
//        products.forEach { (product) in
//            receiptItems.append(Item.init(amount: product.price, price: product.price, name: product.name, tax: .vat10))
//        }
//
//        paymentData.receipt = Receipt.init(shopCode: nil,
//                                           email: "customer@email.com",
//                                           taxation: .osn,
//                                           phone: nil,
//                                           items: receiptItems,
//                                           agentData: nil,
//                                           supplierInfo: nil,
//                                           customer: nil,
//                                           customerInn: nil)
//
//        return paymentData
//    }
    
//    private func acquiringViewConfigration() -> AcquiringViewConfigration {
//        let viewConfigration = AcquiringViewConfigration.init()
////        viewConfigration.scaner = scaner
//
//        viewConfigration.fields = []
//        // InfoFields.amount
//        let title = NSAttributedString.init(string:"Оплата", attributes: [.font: UIFont.boldSystemFont(ofSize: 22)])
//        let amountString = Utils.formatAmount(NSDecimalNumber.init(floatLiteral: productsAmount()))
//        let amountTitle = NSAttributedString.init(string: "\("на сумму") \(amountString)", attributes: [.font : UIFont.systemFont(ofSize: 17)])
//        // fields.append
//        viewConfigration.fields.append(AcquiringViewConfigration.InfoFields.amount(title: title, amount: amountTitle))
//
//        // InfoFields.detail
//        let productsDetatils = NSMutableAttributedString.init()
//        productsDetatils.append(NSAttributedString.init(string: "Книги\n", attributes: [.font : UIFont.systemFont(ofSize: 17)]))
//
//        let productsDetails = products.map { (product) -> String in
//            return product.name
//        }.joined(separator: ", ")
//
//        productsDetatils.append(NSAttributedString.init(string: productsDetails, attributes: [.font : UIFont.systemFont(ofSize: 13), .foregroundColor: UIColor(red: 0.573, green: 0.6, blue: 0.635, alpha: 1)]))
//        // fields.append
//        viewConfigration.fields.append(AcquiringViewConfigration.InfoFields.detail(title: productsDetatils))
//
////        if AppSetting.shared.showEmailField {
////            viewConfigration.fields.append(AcquiringViewConfigration.InfoFields.email(value: nil, placeholder: NSLocalizedString("plaseholder.email", comment: "Отправить квитанцию по адресу")))
////        }
////
////        // fields.append InfoFields.buttonPaySPB
////        if AppSetting.shared.paySBP {
////            viewConfigration.fields.append(AcquiringViewConfigration.InfoFields.buttonPaySPB)
////        }
//
//        viewConfigration.viewTitle = "Оплата"
////        viewConfigration.localizableInfo = AcquiringViewConfigration.LocalizableInfo.init(lang: "ru")//AppSetting.shared.languageId)
//
//        return viewConfigration
//    }
}
//struct Product: Codable {
//
//    var price: NSDecimalNumber
//    var name: String
//    var id: Int
//
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case price
//        case name
//    }
//
//    init(price: Double, name: String, id: Int) {
//        self.price = NSDecimalNumber.init(value: price)
//        self.name = name
//        self.id = id
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(Int.self, forKey: .id)
//        let priceDouble = try container.decode(Double.self, forKey: .price)
//        price = NSDecimalNumber.init(value: priceDouble)
//
//        name = try container.decode(String.self, forKey: .name)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(name, forKey: .name)
//        try container.encode(price.doubleValue, forKey: .price)
//    }
//
//}

/// Тестовые данные для проведения тестовых платежей
public struct StageTestData {
	
	/// Открытый ключ для шифрования карточных данных (номер карты, срок дейсвия и секретный код)
	public static let testPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqBiorLS9OrFPezixO5lSsF+HiZPFQWDO7x8gBJp4m86Wwz7ePNE8ZV4sUAZBqphdqSpXkybM4CJwxdj5R5q9+RHsb1dbMjThTXniwPpJdw4WKqG5/cLDrPGJY9NnPifBhA/MthASzoB+60+jCwkFmf8xEE9rZdoJUc2p9FL4wxKQPOuxCqL2iWOxAO8pxJBAxFojioVu422RWaQvoOMuZzhqUEpxA9T62lN8t3jj9QfHXaL4Ht8kRaa2JlaURtPJB5iBM+4pBDnqObNS5NFcXOxloZX4+M8zXaFh70jqWfiCzjyhaFg3rTPE2ClseOdS7DLwfB2kNP3K0GuPuLzsMwIDAQAB"
	
	/// Уникальный идентификатор терминала, выдается Продавцу Банком на каждый магазин.
	public static let terminalKey = "TestSDK"
	
	/// Пароль от терминала
	public static let terminalPassword = "5l9v23g7hlhqchyb"
	
	/// Идентификатор клиента в системе продавца. Например, для этого идентификатора будут сохраняться список карт.
	public static let customerKey = "TestSDK_CustomerKey1"

}


class Utils {
	private static let amountFormatter = NumberFormatter()

	static func formatAmount(_ value: NSDecimalNumber, fractionDigits: Int = 2, currency: String = "₽") -> String {
		amountFormatter.usesGroupingSeparator = true
		amountFormatter.groupingSize = 3
		amountFormatter.groupingSeparator = " "
		amountFormatter.alwaysShowsDecimalSeparator = false
		amountFormatter.decimalSeparator = ","
		amountFormatter.minimumFractionDigits = 0
		amountFormatter.maximumFractionDigits = fractionDigits

		return "\(amountFormatter.string(from: value) ?? "\(value)") \(currency)"
	}
}
