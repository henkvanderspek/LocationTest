//
//  MapViewController.swift
//  LocationTest
//
//  Created by Henk van der Spek on 23/09/16.
//  Copyright © 2016 Henk van der Spek. All rights reserved.
//

import UIKit
import MapKit
import Graph

class MapViewController: UIViewController {
    
    let graph = Graph()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAppEvent("Load map view controller")
        graph.delegate = self
        graph.watchForEntity(types: ["Location"])
        reloadGraph()
    }
    
    func reloadGraph() {
        let locations = graph.searchForEntity(types: ["Location"]).suffix(100)
        var coordinates = locations.map { ($0["data"] as! CLLocation).coordinate }
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
    }
}

extension MapViewController: GraphDelegate {
    func graphDidInsertEntity(graph: Graph, entity: Entity, fromCloud: Bool) {
        if entity.type == "Location" {
            reloadGraph()
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        var renderer = MKOverlayRenderer()
        if overlay is MKPolyline {
            let r = MKPolylineRenderer(overlay: overlay)
            r.strokeColor = UIColor.blueColor()
            r.lineWidth = 5
            renderer = r
        }
        return renderer
    }
}
