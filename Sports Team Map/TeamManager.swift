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

    var delegate : TeamManagerDelegate?
    
    var group = Group(withName: "Sports Team Maps", andTeams: [])
    
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
            print(self.defaultURL)
            print("could not load teams plist")
            return
        }
        
        if let nflGroup = group.addSubGroup(withName: "NFL") {
            for team in teams {
                if (nflGroup.addTeam(team, toGroupPath: [team.conference,team.division]) == false) {
                    print("could not add \(team.fullName)")
                }
            }
        }
        print(group.teams())
        print(group.teamsAndGroups())
        //self.teams = teams
    }

    func read(from teamsPath: URL) -> [Team]? {
//        guard let teamsPath = teamsPath else {
//            return nil
//        }
     //   let teamsPath = URL(fileURLWithPath: Bundle.main.path(forResource: "Teams", ofType: "plist")!)
        if let data = try? Data(contentsOf: teamsPath) {
            let decoder = PropertyListDecoder()
            do {
                return try decoder.decode([Team].self, from: data)
            } catch {
                print(error)
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
    
    func shortestTour( teams: [Team]) -> [Team] {
        let tours = permutations(xs: teams)
        var shortestTourDistance : CLLocationDistance = CLLocationDistance.greatestFiniteMagnitude
        var shortestTour : [Team] = []
        for tour in tours {
            if var currentStopLocation = tour.last?.locaton {
                var currentTourDistance : CLLocationDistance = 0.0
                for nextStopOnTour in tour[0..<tour.count] {
                    let nextStopLocation = nextStopOnTour.locaton
                    let nextDistance = currentStopLocation.distance(from: nextStopLocation)
                    currentTourDistance += nextDistance
                    if currentTourDistance >= shortestTourDistance {
                        break
                    }
                        
                    currentStopLocation = nextStopLocation
                    
                }
                
                if currentTourDistance < shortestTourDistance {
                    shortestTour = tour
                    shortestTourDistance = currentTourDistance
                }
            }
        }
        return shortestTour
    }
    
}
