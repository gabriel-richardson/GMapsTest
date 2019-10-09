//
//  ViewController.swift
//  Google Maps API test
//
//  Created by Gabriel Richardson on 10/3/19.
//  Copyright © 2019 richardson. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        
        // Set the camera and frame
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        self.view = mapView

        // Find kml and parse
        let path = Bundle.main.path(forResource: "KML/doc", ofType: "kml")
        let url = URL(fileURLWithPath: path!)
        let kmlParser = GMUKMLParser(url: url)
        kmlParser.parse()
        
        var styles: [String: GMUStyle] = [:]
        for style in kmlParser.styles {
            styles.updateValue(style, forKey: style.styleID)
        }
        
        // Set the map's bounds by adding each coordinate
        var bounds = GMSCoordinateBounds()
        for mark in kmlParser.placemarks {
            let point = mark.geometry as! GMUPoint
            bounds = bounds.includingCoordinate(point.coordinate)
            
//            // Custom marker creation because styles weren't working
//            let placemark = mark as! GMUPlacemark
//            let markerStyle = styles[placemark.styleUrl!]
//            let marker = GMSMarker(position: point.coordinate)
//            marker.title = placemark.title
//            marker.snippet = placemark.snippet
//            marker.icon = UIImage(named: (markerStyle?.iconUrl)!)
//            marker.map = mapView
        }

        // Fit camera to bounds with padding
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        mapView.animate(with: update)

        // Render the kml, this doesn't display icons
        let renderer = GMUGeometryRenderer(map: mapView,
                                           geometries: kmlParser.placemarks,
                                           styles: kmlParser.styles)
        renderer.render()
    }
}

/*
 
 We may need to parse the kml data and make each marker with title/desc separately if we want to have custom display
 
 */

