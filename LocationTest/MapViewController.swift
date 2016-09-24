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

extension Entity {
    var annotation: PointAnnotation? {
        guard let location = self["data"] as? CLLocation else { return nil }
        let point = PointAnnotation()
        point.coordinate = location.coordinate
        point.title = "Title"
        point.subtitle = "Sub title"
        return point
    }
}

class AnnotationView: MKAnnotationView {
}

class PointAnnotation: MKPointAnnotation {
    var highlighted = true
    func clone(highlighted: Bool = false) -> PointAnnotation {
        let a = PointAnnotation()
        a.highlighted = highlighted
        a.coordinate = coordinate
        a.title = title
        a.subtitle = subtitle
        return a
    }
}

class MapViewController: UIViewController {
    
    let graph = Graph()
    var liveUpdates = true
    var missedItems = 0
    var lastAnnotation: PointAnnotation?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAppEvent("Load map view controller")
        graph.delegate = self
        graph.watchForEntity(types: ["Location"])
        reloadGraph()
    }
    
    func reloadGraph() {
        let locations = graph.searchForEntity(types: ["Location"]).suffix(1 + missedItems)
        let tmp = locations.map { $0.annotation! } as [PointAnnotation]
        let annotations = tmp.map { (point) -> PointAnnotation in
            if point == tmp.last {
                return point
            } else {
                return point.clone()
            }
        }
        mapView.showAnnotations(annotations, animated: true)
        if let lastAnnotation = lastAnnotation {
            let a = lastAnnotation.clone()
            a.highlighted = false
            mapView.removeAnnotation(lastAnnotation)
            mapView.addAnnotation(a)
        }
        lastAnnotation = annotations.last
    }
}

extension MapViewController {
    @IBAction func toggleShowLocation(sender: UIBarButtonItem?) {
        liveUpdates = !liveUpdates
        sender?.tintColor = liveUpdates ? view.tintColor : UIColor.lightGrayColor()
    }
}

extension MapViewController: GraphDelegate {
    func graphDidInsertEntity(graph: Graph, entity: Entity, fromCloud: Bool) {
        if liveUpdates {
            self.reloadGraph()
            self.missedItems = 0
        } else {
            missedItems = missedItems + 1
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard let a = annotation as? PointAnnotation else { return nil }
        let id = "annotation"
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(id) as? AnnotationView
        if view == nil {
            view = AnnotationView(annotation: annotation, reuseIdentifier: id)
            view?.backgroundColor = UIColor.redColor()
            view?.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
            view?.layer.cornerRadius = 10
            view?.layer.borderColor = UIColor.whiteColor().CGColor
            view?.layer.borderWidth = 4
            view?.layer.shadowColor = UIColor.blackColor().CGColor
            view?.layer.shadowOpacity = 0.5
            view?.layer.shadowRadius = 3
            view?.layer.shadowOffset = CGSize(width: 0, height: 0)
        } else {
            view?.annotation = annotation
        }
        view?.backgroundColor = a.highlighted ? UIColor.redColor() : UIColor.darkGrayColor()
        return view
    }
}
