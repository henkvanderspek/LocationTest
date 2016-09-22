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
    
    private var sessionEvents = [Relationship]()
    @IBOutlet weak var tableView: UITableView!
    var session: Entity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let group = session?.id else { return }
        graph.delegate = self
        graph.watchForRelationship(types: ["SessionEvent"], groups: [group])
        reloadGraph()
    }
    
    private func reloadGraph() {
        guard let group = session?.id else { return }
        sessionEvents = graph.searchForRelationship(types: ["SessionEvent"], groups: [group]).reverse()
        // For some reason this isn't valid
        sessionEvents.removeFirst()
        tableView.reloadData()
    }
}

extension EventsViewController: GraphDelegate {
    func graphDidInsertRelationship(graph: Graph, relationship: Relationship, fromCloud: Bool) {
        reloadGraph()
    }
}

extension EventsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        let se = sessionEvents[indexPath.row]
        
        cell.textLabel?.font = UIFont(name: "SourceCodePro-Regular", size: 11)
        cell.textLabel?.text = se.subject?["description"] as? String ?? nil
        
        return cell
    }
}
