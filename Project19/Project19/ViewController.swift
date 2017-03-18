//
//  ViewController.swift
//  Project19
//
//  Created by D D on 2017-03-11.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //  Create some capital cities.  They conform to teh MKAnnotation protocol
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2DMake(51.507222, -0.1275), info: "Home of the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2DMake(59.95, 10.75), info: "Founded over 1000 years ago")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2DMake(48.8567, 2.3508), info: "Often called the city of light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2DMake(41.9, 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2DMake(38.895111, -77.036667), info: "Named after George himself.")
        
        //  Send to MapView for display
        mapView.addAnnotation(london)
        mapView.addAnnotation(oslo)
        mapView.addAnnotation(paris)
        mapView.addAnnotation(rome)
        mapView.addAnnotation(washington)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //  Annotation identifier.  For re-use purposes
        let identifier = "Capital"
        
        //  Forst see if the annotation is one of our Capital objects
        if annotation is Capital {
            
            //  If so then....
            //  Try to dequeue an annotation  view from the pool
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            //  If we do not have one available
            if annotationView == nil {
                
                //  Create a new one
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                //  canShowCallout = true triggers the popup
                annotationView!.canShowCallout = true
                
                //  Create the little 'i' button and add to the view
                let btn = UIButton(type: .detailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
                
            } else {
                //  There is one then use it
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
        //  Not one of our Capital objects
        return nil
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        //  Our annotation is a Capital so typecast it so we can get at
        //  the properties
        let capital = view.annotation as! Capital
        let placeName = capital.title
        let placeInfo = capital.info
        
        //  Show an alert box when the button is clicked
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    
    }
}

