//
//  ViewController.swift
//  Football Reorg
//
//  Created by Poul Hornsleth on 1/16/21.
//

import Cocoa
import MapKit


class Team : NSObject, MKAnnotation, Codable {
    
    init( mascot:String, city:String, state:String) {
        self.mascot = mascot
        self.city = city
        self.state = state
    }
    
    var name : String?
    var mascot : String
    
    var city : String
    var state : String
    var country : String = "USA"
    var longitude : CLLocationDegrees = 0.0 // Double
    var latitude : CLLocationDegrees = 0.0 // Double
    
    var sport : String = "Professional Football"
    var league : String = "National Football League"
    var conference: String = "AFC"
    var division : String = "North"
    
    var primaryColorName : String = "Red"
    var primaryColorHex : String = "#ff0000"
    var secondaryColorName : String = "Blue"
    var secondaryColorHex : String = "#00ff00"
    
   
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    var primaryColor : NSColor {
        return NSColor(hex: primaryColorHex) ?? .white
    }
    
    var secondaryColor : NSColor {
        return NSColor(hex: secondaryColorHex) ?? .white
    }
    
    var title : String? {
        return "\(name ?? city) \(mascot)"
    }
    
    var subtitle: String? {
        return "\(city), \(state)"
    }
    
   // var color : NSColor
   // var coordinate : CLLocationCoordinate2D
//    func init( mascot: String, conference: String, city: String, state:String) {
//        self.mascot = mascot
//        self.city = city
//        self.state = state
//        self.conference = conference
//    }
}

extension NSColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    //a = CGFloat(hexNumber & 0x000000ff) / 255
                    a = 1.0
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

//class Team: NSObject, MKAnnotation {
//
//
//    let title: String?
//    let locationName: String?
//    var coordinate: CLLocationCoordinate2D
//
//    init(
//        title: String?,
//        locationName: String?
//    ) {
//        self.title = title
//        self.locationName = locationName
//
//        self.coordinate = CLLocationCoordinate2D()
//
//        super.init()
//    }
//
//    var subtitle: String? {
//        return locationName
//    }
//}




class ViewController: NSViewController , MKMapViewDelegate {

    var array : [CLLocationCoordinate2D] = []

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Teams").appendingPathExtension("plist")
    
    var teams : [Team] = [
        
        Team(mascot: "Bills", city: "Buffalo", state: "NY"),
        Team(mascot: "Jets", city: "New York", state: "NY"),
        Team(mascot: "Dolphins", city: "Miami", state: "FL"),
        Team(mascot: "Patriots", city: "Boston", state: "MA"),
        
        Team(mascot: "Colts", city: "Indianapolis", state: "IN"),
        Team(mascot: "Titans", city: "Nashville", state: "TN"),
        Team(mascot: "Texans", city: "Houston", state: "TX"),
        Team(mascot: "Jaguars", city: "Jacksonville", state: "FL"),
        
        Team(mascot: "Ravens", city: "Baltimore", state: "MD"),
        Team(mascot: "Steelers", city: "Pittsburg", state: "PA"),
        Team(mascot: "Browns", city: "Cleveland", state: "OH"),
        Team(mascot: "Bengals", city: "Cincinnati", state: "OH"),
        
        Team(mascot: "Chiefs", city: "Kansas City", state: "MO"),
        Team(mascot: "Raiders", city: "Las Vegas", state: "NV"),
        Team(mascot: "Broncos", city: "Denver", state: "CO"),
        Team(mascot: "Chargers", city: "San Diego", state: "CA"),
        
        Team(mascot: "Packers", city: "Green Bay", state: "WI"),
        Team(mascot: "Bears", city: "Chicago", state: "IL"),
        Team(mascot: "Lions", city: "Detroit", state: "MI"),
        Team(mascot: "Vikings", city: "Minneapolis", state: "MN"),
        
        Team(mascot: "Giants", city: "New York", state: "NY"),
        Team(mascot: "Cowboys", city: "Dallas", state: "TX"),
        Team(mascot: "Football Team", city: "Landover", state: "MD"),
        Team(mascot: "Eagles", city: "Philadelphia", state: "PA"),
        
        Team(mascot: "Rams", city: "Los Angeles", state: "CA"),
        Team(mascot: "Seahawks", city: "Seattle", state: "WA"),
        Team(mascot: "49ers", city: "San Francisco", state: "CA"),
        Team(mascot: "Cardinals", city: "Phoenix", state: "AZ"),
        
        Team(mascot: "Saints", city: "New Orleans", state: "LA"),
        Team(mascot: "Buccaneers", city: "Tampa", state: "FL"),
        Team(mascot: "Panthers", city: "Charlotte", state: "NC"),
        Team(mascot: "Falcons", city: "Atlanta", state: "GA"),
        
        
      //  https://www.raywenderlich.com/7738344-mapkit-tutorial-getting-started
        
        
    ]
    
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

