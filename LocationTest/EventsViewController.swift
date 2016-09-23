//
//  EventsViewController.swift
//  LocationTest
//
//  Created by Henk van der Spek on 23/09/16.
//  Copyright © 2016 Henk van der Spek. All rights reserved.
//

import UIKit
import Graph

class EventCell: UITableViewCell {
}

class EventsViewController: UIViewController {
    
    let graph = Graph()
    var session: Entity?
    var actions = [Action]()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        logAppEvent("Load events view controller")
        graph.delegate = self
        graph.watchForAction()
        reloadGraph()
    }
    
    func reloadGraph() {
        guard let session = session else { return }
        actions = session.actions
        actions.sortInPlace{ $0.createdDate.compare($1.createdDate) == .OrderedDescending }
        tableView.reloadData()
    }
}

extension EventsViewController: GraphDelegate {
    func graphDidInsertAction(graph: Graph, action: Action, fromCloud: Bool) {
        if let session = action.subjects.first where session == session {
            reloadGraph()
        }
    }
}

extension EventsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        let action = actions[indexPath.row]
        let event = action.objects.first!
        
        cell.textLabel?.font = UIFont(name: "SourceCodePro-Regular", size: 13)
        cell.textLabel?.text = dateFormatter.stringFromDate(event.createdDate)
        
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(10)
        cell.detailTextLabel?.text = event["description"] as? String ?? nil
        
        return cell
    }
}
