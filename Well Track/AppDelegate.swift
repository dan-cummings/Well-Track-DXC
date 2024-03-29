//
//  AppDelegate.swift
//  Well Track
//
//  Created by Daniel Cummings on 1/27/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import UserNotifications
import OAuthSwift
import HealthKit
import WatchConnectivity

let googleApiKey =  "AIzaSyCmyVu2yUf1svtM2_K330G2_AQrw_aa0sE"

let BACKGROUND_COLOR = UIColor(named: "BACKGROUND_COLOR")
let TEXT_HIGHLIGHT_COLOR = UIColor(named: "TEXT_HIGHLIGHT_COLOR")
let TEXT_DEFAULT_COLOR = UIColor(named: "TEXT_DEFAULT_COLOR")
let HEADER_BACKGROUND_COLOR = UIColor(named: "HEADER_BACKGROUND")
let BACKGROUND_COLOR_DARK = UIColor(named: "BACKGROUND_COLOR_DARK")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var healthStore: HKHealthStore?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = TEXT_HIGHLIGHT_COLOR
        UINavigationBar.appearance().barTintColor = TEXT_DEFAULT_COLOR
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: TEXT_HIGHLIGHT_COLOR as Any]
        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        GMSServices.provideAPIKey("AIzaSyBoqRmhL_IqQ097skdZk3gxBtmc219Wz5Y")
        GMSPlacesClient.provideAPIKey("AIzaSyBoqRmhL_IqQ097skdZk3gxBtmc219Wz5Y")
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        //Create a new healthstore object to be used universally.
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
            let readTypes: Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
            self.healthStore?.requestAuthorization(toShare: nil, read: readTypes) { (set, error) in
                if !set {
                    self.healthStore = nil
                }
            }
        }
        
        // Sets up notifications
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
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        // Creates token and prints it, if you want to send individual push notifications
        // May want to remove this
        // let token = Messaging.messaging().fcmToken
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    // Method needed in order to receive notifications even while app is active
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    // added for Thermo
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.absoluteString.split(separator: ":")[0] == "well-track") {
            OAuthSwift.handle(url: url)
        }
        return true
    }
    
}

extension AppDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("Connected")
        case .inactive:
            fallthrough
        case .notActivated:
            print("No good")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Inactive")
        return
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Deactivated")
        return
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "heartRateRecieved"), object: self, userInfo: message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "heartRateRecieved"), object: self, userInfo: message)
    }
}

