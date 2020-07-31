package com.example.tinkoff_acquiring

import android.app.Activity
import android.util.Log
import androidx.annotation.NonNull
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import ru.tinkoff.acquiring.sdk.AcquiringSdk
import ru.tinkoff.acquiring.sdk.TinkoffAcquiring
import ru.tinkoff.acquiring.sdk.localization.AsdkSource
import ru.tinkoff.acquiring.sdk.localization.Language
import ru.tinkoff.acquiring.sdk.models.DarkThemeMode
import ru.tinkoff.acquiring.sdk.models.enums.CheckType
import ru.tinkoff.acquiring.sdk.models.options.screen.PaymentOptions
import ru.tinkoff.acquiring.sdk.utils.Money
import ru.tinkoff.cardio.CameraCardIOScanner

const val TAG : String = "TinkoffAcquiringPlugin"
const val PAYMENT_REQUEST_CODE = 99
const val CHANNEL_NAME = "tinkoff_acquiring"
/// Открытый ключ для шифрования карточных данных (номер карты, срок дейсвия и секретный код)
const val testPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqBiorLS9OrFPezixO5lSsF+HiZPFQWDO7x8gBJp4m86Wwz7ePNE8ZV4sUAZBqphdqSpXkybM4CJwxdj5R5q9+RHsb1dbMjThTXniwPpJdw4WKqG5/cLDrPGJY9NnPifBhA/MthASzoB+60+jCwkFmf8xEE9rZdoJUc2p9FL4wxKQPOuxCqL2iWOxAO8pxJBAxFojioVu422RWaQvoOMuZzhqUEpxA9T62lN8t3jj9QfHXaL4Ht8kRaa2JlaURtPJB5iBM+4pBDnqObNS5NFcXOxloZX4+M8zXaFh70jqWfiCzjyhaFg3rTPE2ClseOdS7DLwfB2kNP3K0GuPuLzsMwIDAQAB"
/// Уникальный идентификатор терминала, выдается Продавцу Банком на каждый магазин.
const val terminalKey = "TestSDK"
/// Пароль от терминала
const val terminalPassword = "5l9v23g7hlhqchyb"
/// Идентификатор клиента в системе продавца. Например, для этого идентификатора будут сохраняться список карт.
const val customerKey = "TestSDK_CustomerKey1"

/** TinkoffAcquiringPlugin */

/** TinkoffAcquiringPlugin */
public class TinkoffAcquiringPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null

  /**
   * Use this constructor when adding this plugin to an app with v2 embedding.
   */
  constructor() {}

  private constructor(activity: Activity ) {
    this.activity = activity;
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    Log.d(TAG, call.method)
    if (activity?.application == null) {
      val error = "Fail to resolve Application on registration"
      Log.e(call.method, error)
      result.error(call.method, error, Exception(error))
      return
    }
    if (activity !is FragmentActivity) {
      val error = "Got attached to activity which is not a FragmentActivity: $activity"
      Log.e( TAG, error)
      result.error(call.method, error, Exception(error))
      return
    }
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "openPaymentScreen" -> {
        var paymentOptions = PaymentOptions().setOptions {
          orderOptions { // данные заказа
            orderId = "ORDER-ID"
            amount = Money.ofCoins(1000)
            title = "НАЗВАНИЕ ПЛАТЕЖА"
            description = "ОПИСАНИЕ ПЛАТЕЖА"
            recurrentPayment = false
          }
          customerOptions { // данные покупателя
            customerKey = "CUSTOMER_KEY"
            email = "batman@gotham.co"
            checkType = CheckType.NO.toString()
          }
          featuresOptions { // настройки визуального отображения и функций экрана оплаты
            useSecureKeyboard = true
            localizationSource = AsdkSource(Language.RU)
            handleCardListErrorInSdk = true
            cameraCardScanner = CameraCardIOScanner()
            darkThemeMode = DarkThemeMode.AUTO
//                        theme = R.style.MyCustomTheme
          }
        }

        // открытие экрана оплаты. Передается context, настройки и RequestCode для получения результата
        tinkoffAcquiring.openPaymentScreen(
                activity as FragmentActivity, paymentOptions, PAYMENT_REQUEST_CODE)
      }
      else ->
        result.notImplemented()
    }
  }


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    AcquiringSdk.isDeveloperMode = true // используется тестовый URL, деньги с карт не списываются
    AcquiringSdk.isDebug = true
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
    channel.setMethodCallHandler(null)
  }

  companion object {
    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    @JvmStatic
    fun registerWith(registrar: PluginRegistry.Registrar) {
      val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
      channel.setMethodCallHandler(TinkoffAcquiringPlugin(registrar.activity()))
    }

    val tinkoffAcquiring = TinkoffAcquiring(terminalKey, terminalPassword, testPublicKey) // создание объекта для взаимодействия с SDK и передача данных продавца
  }
}
