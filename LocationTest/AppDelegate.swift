//
//  AppDelegate.swift
//  LocationTest
//
//  Created by Henk van der Spek on 22/09/16.
//  Copyright © 2016 Henk van der Spek. All rights reserved.
//

import UIKit
import Graph
import CoreLocation

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

extension UIBackgroundRefreshStatus {
    var text: String {
        switch self {
        case .Restricted:
            return "App Background Refresh = Restricted"
        case .Available:
            return "App Background Refresh = Available"
        case .Denied:
            return "App Background Refresh = Denied"
        }
    }
}

let manager = CLLocationManager()
private let graph = Graph()

public enum LogLevel {
    case Fatal
    case Error
    case Warn
    case Info
    case Debug
    case Trace
}

extension LogLevel {
    var text: String {
        switch self {
        case .Fatal:
            return "Fatal"
        case .Error:
            return "Error"
        case .Warn:
            return "Warning"
        case .Info:
            return "Info"
        case .Debug:
            return "Debug"
        case .Trace:
            return "Trace"
        }
    }
}

public func logAppEvent(description: String, level: LogLevel = .Debug) {
    logEvent(description, type: "Application", level: level)
}

public func logLocationEvent(description: String, level: LogLevel = .Debug) {
    logEvent(description, type: "Location", level: level)
}

public func logEvent(description: String, type: String, level: LogLevel = .Debug) {
    
    guard let session = session else { return }
    
    let event = Entity(type: "Event")
    event["description"] = description
    event.addToGroup(type)
    event.addToGroup(level.text)
    
    // TODO: add to app version group
    
    let log = Action(type: "Record")
    log.addSubject(session)
    log.addObject(event)
    
    graph.async { (success: Bool, error: NSError?) in
        if let e: NSError = error {
            print(e)
        }
    }
}

var session: Entity? {
    didSet {
        isSessionPending = (session != nil)
    }
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

public var dateFormatter: NSDateFormatter = {
    let f = NSDateFormatter()
    f.dateFormat = "HH:mm:ss.SSS"
    return f
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        createSession(withState: "Inactive")
        logAppEvent("Application did finish launch")
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.pausesLocationUpdatesAutomatically = true
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.activityType = .Fitness
        manager.startUpdatingLocation()
        logLocationEvent("Location tracking activated")
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        logAppEvent("Application will enter foreground")
        createSession(withState: "Inactive")
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        createSession(withState: "Active")
        logAppEvent("Application did become active")
    }

    func applicationWillResignActive(application: UIApplication) {
        logAppEvent("Applicaiton will resign active")
        createSession(withState: "Inactive")
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        createSession(withState: "Background")
        logAppEvent("Application did enter background")
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        logAppEvent("Application did receive memory warning")
    }
    
    func applicationWillTerminate(application: UIApplication) {
        logAppEvent("Application will terminate")
        endSession(withResult: "Terminated")
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
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Denied:
            logLocationEvent("Location tracking denied")
        case .NotDetermined:
            logLocationEvent("Location tracking authorization status not determined")
        case .Restricted:
            logLocationEvent("Location tracking restricted")
        case .AuthorizedWhenInUse:
            logLocationEvent("Location tracking authorized, when in use")
        case .AuthorizedAlways:
            logLocationEvent("Location tracking always authorized")
            if #available(iOS 9, *) {
                manager.allowsBackgroundLocationUpdates = true
            }
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logLocationEvent("Location manager did update locations")
        
        locations.forEach { (loc) in
            let location = Entity(type: "Location")
            location["data"] = loc
            location.addToGroup(UIApplication.sharedApplication().applicationState.text)
        }
        
        graph.async { (success: Bool, error: NSError?) in
            if let e: NSError = error {
                print(e)
            }
        }
    }
}

