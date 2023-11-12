//
//  AppDelegate.swift
//  Shoof
//
//  Created by Husam Aamer on 9/7/17.
//  Copyright © 2017 HA. All rights reserved.
//
import UserNotifications
import Firebase
extension AppDelegate {

    func askForNotifications () {
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        //Set user property for Notification
        //Assuming user takes maximum 6sec for allow or decline notifications
        delay(6) {
            let value = UIApplication.shared.isRegisteredForRemoteNotifications ? 1 : 0
            FIRSet(userProperty: "\(value)", name: .isNotificationEnabled)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
         Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        /*
         [AnyHashable("target"): {"id":"JZETSHNJ7JyNw21","type":"movie"}, AnyHashable("gcm.message_id"): 1617713793293860, AnyHashable("aps"): {
             alert =     {
                 body = "2020
         \nIMDB \U2b50 7.5
         \nDrama \Ud83c\Udfad
         \n\U062f\U0627\U0631\U064a\U0646 \U060c \U0645\U0648\U0633\U064a\U0642\U064a \U0634\U0627\U0628 \U0645\U0648\U0647\U0648\U0628 \U060c \U064a\U062d\U0644\U0645 \U0628\U0635\U0646\U0627\U0639\U0629 \U0645\U0648\U0633\U064a\U0642\U0649 \U0644\U0645 \U064a\U0633\U0628\U0642 \U0644\U0647\U0627 \U0645\U062b\U064a\U0644. \U0644\U0643\U0646\U0647\U0627 \U0645\U0641\U0644\U0633\U0629. \U0641\U064a \U062d\U0627\U062c\U0629 \U0645\U0627\U0633\U0629 \U0625\U0644\U0649 \U0627\U0644\U0645\U0627\U0644 \U060c \U0642\U0627\U0645\U062a \U0628\U0627\U0644\U062a\U0633\U062c\U064a\U0644 \U0641\U064a \U0645\U0648\U0642\U0639 \U0625\U0644\U0643\U062a\U0631\U0648\U0646\U064a \U0644\U0644\U0645\U0648\U0627\U0639\U062f\U0629 \U0645\U062f\U0641\U0648\U0639\U0629 \U0627\U0644\U0623\U062c\U0631 \U060c \U062d\U064a\U062b \U0623\U0644\U0642\U062a \U0628\U0646\U0641\U0633\U0647\U0627 \U0641\U064a \U0637\U0631\U064a\U0642 \U0645\U0638\U0644\U0645 \U064a\U0634\U0643\U0644 \U0645\U0648\U0633\U064a\U0642\U0627\U0647\U0627 \U0628\U0647.";
                 title = "Sugar Daddy";
             };
             sound = default;
         }, AnyHashable("google.c.a.e"): 1, AnyHashable("google.c.sender.id"): 179142355788]
         */

        
        let notif = Notification(name: Notification.Name(rawValue: gnNotification.didRecieveRemoteNotification),
                                 object: nil, userInfo: userInfo)

        //If app was in background
        NotificationCenter.default.post(notif)
        
        
        //If app launched from notification then add object to queue
        if objectsToBeHandled == nil {
            objectsToBeHandled = [:]
        }
        objectsToBeHandled?[gnNotification.didRecieveRemoteNotification] = notif
        
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FIRSet(userProperty: "1", name: .isNotificationEnabled)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("fcmToken",fcmToken)
    }
}
