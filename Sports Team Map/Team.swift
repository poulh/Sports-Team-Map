//
//  Team.swift
//  Sports Team Map
//
//  Created by Poul Hornsleth on 1/21/21.
//

import Foundation
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
    
}
