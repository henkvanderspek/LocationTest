//
//  AppDelegate.swift
//  LocationTest
//
//  Created by Henk van der Spek on 22/09/16.
//  Copyright © 2016 Henk van der Spek. All rights reserved.
//

import UIKit
import Graph

extension UIApplicationState {
    var text: String {
        switch self {
        case .Active:
            return "Active"
        case .Inactive:
            return "Inactive"
        case .Background:
            return "Background"
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    lazy var graph = Graph()
    private var session: Entity?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        logAppEvent(withDescription: "Application will enter foreground")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        createSession(withState: application.applicationState.text)
        logAppEvent(withDescription: "Application did become active")
    }

    func applicationWillResignActive(application: UIApplication) {
        logAppEvent(withDescription: "Application will resign active")
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        createSession(withState: application.applicationState.text)
        logAppEvent(withDescription: "Application did enter background")
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        logAppEvent(withDescription: "Application did receive memory warning")
    }
    
    func applicationWillTerminate(application: UIApplication) {
        logAppEvent(withDescription: "Application will terminate")
    }
}

extension AppDelegate {
    
    func createSession(withState state: String) {
    
        if let s = session {
            s["endedDate"] = NSDate()
            s.addToGroup("Finished")
        }
        
        session = Entity(type: "Session")
        session!.addToGroup("\(state)")
        
        graph.async { (success: Bool, error: NSError?) in
            if let e: NSError = error {
                print(e)
            }
        }
    }

    func logAppEvent(withDescription description: String) {

        let event = Entity(type: "Event")
        event["description"] = description
        
        let log = Relationship(type: "Log")
        log.subject = event
        log.object = session
        log.addToGroup("Application")
        
        graph.async { (success: Bool, error: NSError?) in
            if let e: NSError = error {
                print(e)
            }
        }
    }
}
