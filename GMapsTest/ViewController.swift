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
        let path = Bundle.main.path(forResource: "doc", ofType: "kml")
        let url = URL(fileURLWithPath: path!)
        let kmlParser = GMUKMLParser(url: url)
        kmlParser.parse()

        // Put styles in hash map with ID
        var styles: [String: GMUStyle] = [:]
        for style in kmlParser.styles {
            styles.updateValue(style, forKey: style.styleID)
        }

        // Match -normal and -highlight IDs to regular ID
        // e.g. convert <"icon-1033-normal", Style> to <"icon-1033", Style>
        for styleMap in kmlParser.styleMaps {
            let style = styles.removeValue(forKey: styleMap.pairs[0].styleUrl)!
            styles.updateValue(style, forKey: styleMap.styleMapId)
        }

        // Set the map's bounds by adding each coordinate
        var bounds = GMSCoordinateBounds()
        for mark in kmlParser.placemarks {
            let point = mark.geometry as! GMUPoint
            bounds = bounds.includingCoordinate(point.coordinate)

            // Custom marker creation because GMUStyles don't work
            let placemark = mark as! GMUPlacemark
            let markerStyle = styles[placemark.styleUrl!]
            let marker = GMSMarker(position: point.coordinate)
            marker.title = placemark.title
            marker.snippet = placemark.snippet
            // Parse description markup
            if let str = placemark.snippet {
                // Remove the break tags after images
                var subString = str.replacingOccurrences(of: "/><br><br>", with: ">")
                subString = subString.replacingOccurrences(of: "<br><br><", with: "<")
                // Replace break tags with new lines
                subString = subString.replacingOccurrences(of: "<br>", with: "\n")
                // Remove image tags
                subString = subString.replacingOccurrences(of: "\\s?\\<[^>]*\\>", with: "", options: .regularExpression)
                marker.snippet = subString
            }
            // Remove the images
            let icon = (markerStyle?.iconUrl)!.components(separatedBy: "/")[1]
            marker.icon = UIImage(named: icon)
            marker.map = mapView
        }
        
        // Fit camera to bounds with padding
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        mapView.animate(with: update)
    }
}

