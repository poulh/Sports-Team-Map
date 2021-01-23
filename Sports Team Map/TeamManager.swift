//
//  TeamManager.swift
//  Sports Team Map
//
//  Created by Poul Hornsleth on 1/21/21.
//

import Foundation
import MapKit

protocol TeamManagerDelegate {
    func onSsearchCoordinateResults(_: Team, _: MKMapItem)
    func onSearchCoordinateError(error: Error)
    
    func onRead(_: [Team])
    func onReadError(error: Error)
    func onWriteError(error: Error)
}

class TeamManager {
    
    var teamMap : [String :[String:[Team]] ] = [:]
    var uiArray : [Any] = []
    
    var delegate : TeamManagerDelegate?
    
    let basename = "Teams"
    let filetype = "plist"
    var filename : String {
        return "\(basename).\(filetype)"
    }
    
    var defaultURL : URL? {
        guard let filePath = Bundle.main.path(forResource: self.basename, ofType: self.filetype) else {
            return nil
        }
        return URL(fileURLWithPath: filePath)
    }
    

    
    var documentsURL : URL? {

        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(self.basename).appendingPathExtension(self.filetype)
    }
    
    func searchCoordinate(forTeam team: Team) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = team.subtitle
        MKLocalSearch(request: request).start { (response, error) in
            if let error = error {
                self.delegate?.onSearchCoordinateError(error: error)
            }
            if let mapItems = response?.mapItems,
               let mapItem = mapItems.first {
                //                team.latitude = mapItem.placemark.coordinate.latitude
                //                team.longitude = mapItem.placemark.coordinate.longitude
                self.delegate?.onSsearchCoordinateResults(_: team, _: mapItem)
            }
        }
    }
    
    func initDefault() {
        guard let defaultURL = self.defaultURL,
              let teams = self.read(from: defaultURL) else {
            
            return
        }
        
        for team in teams {
            var div = teamMap[team.conference, default: [:] ]
            var teams :[Team] = div[team.division, default: []]
                // now val is not nil and the Optional has been unwrapped, so use it
            teams.append(team)
            div[team.division] = teams
            teamMap[team.conference] = div
        }
        rebuildUITable()
        //self.teams = teams
    }
    
    var conferences : [String] {
        return Array(teamMap.keys)
    }
    
    var divisions : [String] {
        let div = teamMap.map { $1.keys }
        print (div)
        return div.reduce([], +) // flatten the array of arrays
    }
    
    var teams : [Team] {
        var t :[ Team ] = []
        for (_, divisions) in teamMap {

            for (_, teams) in divisions {
                
                for team in teams {
                    t.append(team)
                }
            }
        }
        return t
    }
    
    func uiTableRowCount() -> Int {
        return uiArray.count
       // return conferences.count + divisions.count + teams.count
    }
    
    func rebuildUITable() {
        self.uiArray = []
        for (conference, divisions) in teamMap {
            uiArray.append(conference)
            for (division, teams) in divisions {
                
                uiArray.append([conference,division])
                for team in teams {
                    uiArray.append(team)
                }
            }
        }
        print("ui count: \(uiArray.count)")
    }
    
    func read(from teamsPath: URL) -> [Team]? {
//        guard let teamsPath = teamsPath else {
//            return nil
//        }
     //   let teamsPath = URL(fileURLWithPath: Bundle.main.path(forResource: "Teams", ofType: "plist")!)
        if let data = try? Data(contentsOf: teamsPath) {
            let decoder = PropertyListDecoder()
            if let teams = try? decoder.decode([Team].self, from: data) {
                return teams
            }
        }
        return nil
    }
    
    func write(teams: [Team], to saveFilePath: URL) {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(teams)

            try data.write(to: saveFilePath)
        } catch {
            delegate?.onWriteError(error: error)
        }
    }
    
}
