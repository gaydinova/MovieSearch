//
//  AppDelegate.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 6/29/24.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MoviSearch")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.overrideUserInterfaceStyle = .dark

        // Initialize the Core Data stack
        let context = persistentContainer.viewContext

        // Create and set the root view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let initialViewController = storyboard.instantiateInitialViewController() as? UINavigationController,
           let rootViewController = initialViewController.viewControllers.first as? MovieSearchViewController {
            rootViewController.managedObjectContext = context
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        }

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveContext()
    }

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
