//
//  ClassProjectApp.swift
//  ClassProject
//
//  Created by Dinh Phuc Nguyen on 3/17/24.
//

import SwiftUI
import Firebase
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        let GOOGLE_API_KEY = "AIzaSyB1YDk503zKf0qQEAChA_6OSNiqjgHZPXM"
        GMSServices.provideAPIKey(GOOGLE_API_KEY)
        return true
    }
}

@main
struct HistoricTempe: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NavigationView{
                LandingPage()
            }
        }
    }
}
