//
//  ViewController.swift
//  Football Reorg
//
//  Created by Poul Hornsleth on 1/16/21.
//

import Cocoa
import MapKit

class ViewController: NSViewController {

    var array : [CLLocationCoordinate2D] = []

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Teams").appendingPathExtension("plist")
    
    let teamManager = TeamManager()
    
    var teams : [Team] = []
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
      
        mapView.delegate = self
        
        guard let defaultURL = teamManager.defaultURL,
              let teams = teamManager.read(from: defaultURL) else {
            
            return
        }
        
        self.teams = teams
        

        for team in self.teams {
            self.mapView.addAnnotation(team)
            let influenceCircle = MKCircle(center: team.coordinate, radius: 150 * 1.6 * 1000)
            mapView.addOverlay(influenceCircle)
        }
       
        
        let filteredTeams = self.teams.filter { (team) -> Bool in
            return team.division == "North" && team.conference == "AFC"
        }
        
        
        let coordinates = filteredTeams.map { $0.coordinate }
        
        let poly = MKPolygon(coordinates: coordinates, count: coordinates.count)

        
        mapView.addOverlay(poly)

        //  mapView.addAnnotation(artwork)
       // let ann = MKAnnotation(
       // mapView.addAnnotation(<#T##annotation: MKAnnotation##MKAnnotation#>)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if overlay is MKCircle {
            print("circle!")
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = NSColor.gray.withAlphaComponent(0.25)
            renderer.strokeColor = NSColor.black
            renderer.lineWidth = 2
            return renderer
        }
        if overlay is MKPolygon {
            print("polygon!")
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = NSColor.purple.withAlphaComponent(0.5)
            renderer.strokeColor = NSColor.blue
            renderer.lineWidth = 2
            return renderer
        }
//        if overlay is MKCircle {
//            let renderer = MKCircleRenderer(overlay: overlay)
//            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
//            renderer.strokeColor = UIColor.blue
//            renderer.lineWidth = 2
//            return renderer
//
//        } else if overlay is MKPolyline {
//            let renderer = MKPolylineRenderer(overlay: overlay)
//            renderer.strokeColor = UIColor.orange
//            renderer.lineWidth = 3
//            return renderer
//        }
        
        return MKOverlayRenderer()
    }
}
