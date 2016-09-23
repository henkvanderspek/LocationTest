//
//  MainViewController.swift
//  LocationTest
//
//  Created by Henk van der Spek on 23/09/16.
//  Copyright © 2016 Henk van der Spek. All rights reserved.
//

import UIKit
import Graph

class MainViewController: UIViewController {
    
    let graph = Graph()
    
    @IBOutlet weak var locationsCounter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAppEvent("Load main view controller")
        graph.delegate = self
        graph.watchForEntity(types: ["Location"])
        reloadGraph()
    }
    
    func reloadGraph() {
        let locations = graph.searchForEntity(types: ["Location"])
        locationsCounter.text = String(locations.count)
    }
}

extension MainViewController {
    @IBAction func showSessions() {
        logAppEvent("Push sessions view controller")
        let vc = storyboard!.instantiateViewControllerWithIdentifier("Sessions")
        navigationController!.pushViewController(vc, animated: true)
    }
    @IBAction func showMap() {
        logAppEvent("Push map view controller")
        let vc = storyboard!.instantiateViewControllerWithIdentifier("Map")
        navigationController!.pushViewController(vc, animated: true)
    }
}

extension MainViewController: GraphDelegate {
    func graphDidInsertEntity(graph: Graph, entity: Entity, fromCloud: Bool) {
        if entity.type == "Location" {
            reloadGraph()
        }
    }
}
