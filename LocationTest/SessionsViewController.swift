//
//  ViewController.swift
//  LocationTest
//
//  Created by Henk van der Spek on 22/09/16.
//  Copyright © 2016 Henk van der Spek. All rights reserved.
//

import UIKit
import Graph

class SessionCell: UITableViewCell {
}

class SessionsViewController: UIViewController {
    
    let graph = Graph()
    var sessions = [Entity]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAppEvent("Load sessions view controller")
        graph.watchForEntity(types: ["Session"])
        reloadGraph()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        graph.delegate = self
    }
    
    func reloadGraph() {
        sessions = graph.searchForEntity(types: ["Session"])
        sessions.sortInPlace{ $0.createdDate.compare($1.createdDate) == .OrderedDescending }
        tableView.reloadData()
    }
}

extension SessionsViewController: GraphDelegate {
    func graphDidInsertEntity(graph: Graph, entity: Entity, fromCloud: Bool) {
        reloadGraph()
    }
}

extension SessionsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        let session = sessions[indexPath.row]
        
        var text = dateFormatter.stringFromDate(session.createdDate)
        if let d = session["endedDate"] as? NSDate {
            text = text + " - " + dateFormatter.stringFromDate(d)
        }
        
        cell.textLabel?.font = UIFont(name: "SourceCodePro-Regular", size: 12)
        cell.textLabel?.text = text
        
        let state = session["state"] as? String ?? "Unknown"
        let result = session["result"] as? String ?? "Running"
        
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(10)
        cell.detailTextLabel?.text = "\(result) (while app state: \(state))"
        
        cell.accessoryType = (session.actions.count == 0 ? .None : .DisclosureIndicator)
        
        return cell
    }
}

extension SessionsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let session = sessions[indexPath.row]
        if session.actions.count > 0 {
            logAppEvent("Push events view controller")
            let vc = storyboard?.instantiateViewControllerWithIdentifier("Events") as! EventsViewController
            vc.session = sessions[indexPath.row]
            navigationController!.pushViewController(vc, animated: true)
        }
    }
}
