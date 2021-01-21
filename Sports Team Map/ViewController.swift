//
//  ViewController.swift
//  Football Reorg
//
//  Created by Poul Hornsleth on 1/16/21.
//

import Cocoa
import MapKit

class ViewController: NSViewController , MKMapViewDelegate {

    var array : [CLLocationCoordinate2D] = []

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Teams").appendingPathExtension("plist")
    
    var teams : [Team] = []
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
      

        print(dataFilePath)
        
        let teamsPath = URL(fileURLWithPath: Bundle.main.path(forResource: "Teams", ofType: "plist")!)
        if let data = try? Data(contentsOf: teamsPath) {
            let decoder = PropertyListDecoder()
            do {
                self.teams = try decoder.decode([Team].self, from: data)
            } catch {
                print(error)
            }
        }
        print(teams)
        for team in teams {
            self.mapView.addAnnotation(team)
        }
        return
        var done = 0
        for team in teams {
            if team.latitude != 0.0 && team.longitude != 0.0 {
                print("\(team.title!) has coordinates. skipping")
                continue
            }
            return
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = team.subtitle
            MKLocalSearch(request: request).start { (response, error) in
                
                if let mapItems = response?.mapItems {
                    for mapItem in mapItems {
                        done = done + 1
                        team.latitude = mapItem.placemark.coordinate.latitude
                        team.longitude = mapItem.placemark.coordinate.longitude
                        
                        if done == self.teams.count {
                            print("have all coordinates")
                            let encoder = PropertyListEncoder()
                            do {
                                let data = try encoder.encode(self.teams)
                                try data.write(to: self.dataFilePath!)
                            } catch {
                                print(error)
                            }
                        }
                        //                        if self.array.count < 4 {
//                       //     print("adding \(team.title)")
//                            self.array.append(team.coordinate)
//                        } else if firstTime == false {
//                            firstTime = true
//                            print("making poly")
//
//                            let poly = MKPolygon(coordinates: &self.array, count: self.array.count)
//
//                            DispatchQueue.main.async {
//                                print("drawing")
//                                print(poly)
//
//
//                            }
//                        }
                        DispatchQueue.main.async {
                            self.mapView.addAnnotation(team)
                        }
                    }
                }
            }
        }


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

