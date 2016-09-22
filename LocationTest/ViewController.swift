//
//  ViewController.swift
//  LocationTest
//
//  Created by Henk van der Spek on 22/09/16.
//  Copyright © 2016 Henk van der Spek. All rights reserved.
//

import UIKit
import Graph

var formatter: NSDateFormatter = {
    let f = NSDateFormatter()
    f.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
    return f
}()

class ViewController: UIViewController {
    
    lazy var graph = Graph()
    private var sessions = [Entity]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    private func prepareGraph() {
        graph.delegate = self
        graph.watchForEntity(types: ["Session"])
    }
}

extension ViewController: GraphDelegate {
    func graphDidInsertEntity(graph: Graph, entity: Entity, fromCloud: Bool) {
        sessions.append(entity)
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        let session = sessions[indexPath.row]
        
        cell.textLabel?.text = formatter.stringFromDate(session.createdDate)
        
        return cell
    }
}
