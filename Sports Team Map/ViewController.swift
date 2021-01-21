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
        }
       
        
        let filteredTeams = self.teams.filter { (team) -> Bool in
            return team.division == "North" && team.conference == "AFC"
        }
        
        
        let coordiates = filteredTeams.map { (team) -> CLLocationCoordinate2D in
            return team.coordinate
        }

        
        let poly = MKPolygon(coordinates: coordiates, count: coordiates.count)

        
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
        print("make an overlay!")
        if overlay is MKPolygon {
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
