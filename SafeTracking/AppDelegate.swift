
import UIKit
import CoreLocation
import UserNotifications
import FirebaseCrashlytics
import Firebase
import FirebaseMessaging
import FirebaseInAppMessaging
import FirebaseCore
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
  var window: UIWindow?
  
  static let geoCoder = CLGeocoder()
  let center = UNUserNotificationCenter.current()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    UITabBar.appearance().tintColor = UIColor.white
    UINavigationBar.appearance().tintColor = UIColor.white
    
    center.requestAuthorization(options: [.alert, .sound]) { granted, error in }
    
    
    
    
    let locationUpdating = UserDefaults.standard.bool(forKey: "locationUpdating")
    !locationUpdating ? LocationManager.shared.startBackgroundLocationUpdates() : LocationManager.shared.stopBackgroundLocationUpdates()
    
  
    
    
    // Firebase Configure
    FirebaseApp.configure()
    Database.database().isPersistenceEnabled = true
    
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)

    Crashlytics.crashlytics().checkForUnsentReports { hasUnsentReport in
      let hasUserConsent = false
      // ...get user consent.

      if hasUserConsent && hasUnsentReport {
        Crashlytics.crashlytics().sendUnsentReports()
      } else {
        Crashlytics.crashlytics().deleteUnsentReports()
      }
    }

    // Detect when a crash happens during your app's last run.
    Crashlytics.crashlytics().didCrashDuringPreviousExecution()
    
    
    
    
    //Cloud Messging Firebase /Push Notification
    Messaging.messaging().delegate = self
    
    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    //InAppMessaging
    // [START fiam_register_delegate]
    // Register the delegate with the InAppMessaging instance
    let myFiamDelegate = CardActionFiamDelegate()
    InAppMessaging.inAppMessaging().delegate = myFiamDelegate;
    // [END fiam_register_delegate]
    
    //Keyboard
    IQKeyboardManager.shared.enable = true
    
    // Saved User check
    let userLoginStatus = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    
    //Open VC
    if (userLoginStatus) {
      let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
      if let tabbar = mainStoryBoard.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController {
        tabbar.modalPresentationStyle = .fullScreen
        tabbar.modalTransitionStyle = .crossDissolve
        window?.rootViewController = tabbar
        window!.makeKeyAndVisible()
      }
    }
    
    return true
  }
}



















extension AppDelegate : MessagingDelegate {
  
  // [START refresh_token]
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("Firebase registration token: \(fcmToken)")
    
    let dataDict:[String: String] = ["token": fcmToken]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }
  // [END refresh_token]
  // [START ios_10_data_message]
  // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
  // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print("Received data message: \(remoteMessage.appData)")
  }
  // [END ios_10_data_message]
  
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    // Print full message.
    print(userInfo)
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptions.alert)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    // Print full message.
    print("tap on on forground app",userInfo)
    
    completionHandler()
  }
}

