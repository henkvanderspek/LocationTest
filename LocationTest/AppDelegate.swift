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

let graph = Graph()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var session: Entity? {
        didSet {
            isSessionPending = (session != nil)
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        logAppEvent(withDescription: "Application will enter foreground")
        createSession(withState: "Inactive")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        createSession(withState: "Active")
        logAppEvent(withDescription: "Application did become active")
    }

    func applicationWillResignActive(application: UIApplication) {
        logAppEvent(withDescription: "Applicaiton will resign active")
        createSession(withState: "Inactive")
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        createSession(withState: "Background")
        logAppEvent(withDescription: "Application did enter background")
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        logAppEvent(withDescription: "Application did receive memory warning")
    }
    
    func applicationWillTerminate(application: UIApplication) {
        logAppEvent(withDescription: "Application will terminate")
        endSession(withResult: "Terminated")
    }
    
    var isSessionPending: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("SessionPending")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SessionPending")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}

extension AppDelegate {
    
    func createSession(withState state: String = UIApplication.sharedApplication().applicationState.text) {
    
        if let _ = session {
            endSession(withResult: "Finished")
        } else if isSessionPending {
            endSession(withResult: "Crashed")
        }
        
        let s = Entity(type: "Session")
        s["state"] = state
        s.addToGroup("\(state)")
        session = s
        
        graph.async { (success: Bool, error: NSError?) in
            if let e: NSError = error {
                print(e)
            }
        }
    }
    
    func endSession(withResult result: String) {
        
        if let s = graph.searchForEntity(types: ["Session"]).last {
            s["endedDate"] = NSDate()
            s["result"] = result
            s.addToGroup(result)
            session = nil
            
            graph.async { (success: Bool, error: NSError?) in
                if let e: NSError = error {
                    print(e)
                }
            }
        }
    }

    func logAppEvent(withDescription description: String) {

        let event = Entity(type: "Event")
        event["description"] = description
        
        let se = Relationship(type: "SessionEvent")
        se.subject = event
        se.object = session
        se.addToGroup("Application")
        
        if let id = session?.id {
            se.addToGroup(id)
        }
        
        graph.async { (success: Bool, error: NSError?) in
            if let e: NSError = error {
                print(e)
            }
        }
    }
}
