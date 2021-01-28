//
//  Group.swift
//  Sports Team Map
//
//  Created by Poul Hornsleth on 1/23/21.
//

import Foundation
import MapKit

class Group {
    
    init(withName name: String, andTeams teams: [Team]) {
        self.name = name
        let _ = addTeams(teams)
    }
    
    var name : String
    var parentGroup : Group? = nil
    var subGroupDict : [String:Group] = [:]
    var teamsDict : [String:Team] = [:]
    var calculatedShortestTour : [Team]?
    
    
    var path : [String] {
        if let parent = parentGroup {
            var parentPath =  parent.path
            parentPath.append(name)
            return parentPath
        }
        return []
    }
    
    var hasSubGroups : Bool {
        return !subGroupDict.isEmpty
    }
    
    func addTeam(_ team:Team) -> Bool {
        if subGroupDict.keys.count > 0 {
            return false
        }
        teamsDict[team.fullName] = team
        team.groupPath = self.path
        calculatedShortestTour = nil
        return true
    }
    
   
    func addTeam(_ team:Team, toGroupPath groupPath: [String]) -> Bool {
        var pathComponents = groupPath
        if pathComponents.isEmpty {
            return addTeam(team)
        }
        
        let first = pathComponents.removeFirst()
        if let subGroup = addSubGroup(withName: first) {
            return subGroup.addTeam(team, toGroupPath: pathComponents)

        }
        return false
    }
    
    
    func addTeams( _ teams: [Team]) -> Bool {
        for team in teams {
            let added = addTeam(team)
            if !added {
                return false
            }
        }
        return true
    }
    
    func removeTeam(_ team:Team) -> Team? {
        let team =  self.teamsDict.removeValue(forKey: team.fullName)
        team?.groupPath = nil
        calculatedShortestTour = nil

        return team
    }
    
    func getSubGroup(atPath groupPath: [String]) -> Group? {
        var pathComponents = groupPath

        if pathComponents.isEmpty {
            return self
        } else {
            let first = pathComponents.removeFirst()
            if let subGroup = subGroupDict[first] {
                return subGroup.getSubGroup(atPath: pathComponents)
            }
        }
        return nil
    }
    
    func getSubGroup(forTeam team: Team?) -> Group? {
        guard let team = team,
              let teamGroupPath = team.groupPath else  {
            return nil
        }
        return self.getSubGroup(atPath: teamGroupPath)
    }
    
    func addSubGroup(withName name: String) -> Group? {
        if let subGroup = subGroupDict[name] {
            return subGroup
        }
        
        let subGroup = Group(withName: name, andTeams: Array(self.teamsDict.values))
        subGroup.parentGroup = self
        subGroupDict[name] = subGroup
        self.teamsDict = [:]
        return subGroup
    }
    
    func groupDepth() -> Int {
        var depth = 0
        var parent = self.parentGroup
        while parent != nil {
            parent = self.parentGroup
            depth += 1
        }
        return depth
    }
    
    func teams() -> [Team] {
        
        if subGroupDict.keys.isEmpty {
            return Array(teamsDict.values)
        }
        var teams : [Team] = []
        
        for subGroup in subGroupDict.values {
            teams.append(contentsOf: subGroup.teams())
        }
        
        return teams
    }
    
    func teamsAndGroups() -> [Any] {
        var rval : [Any] = [self]
        if subGroupDict.keys.isEmpty {
            rval.append(contentsOf: Array(teamsDict.values))
        } else {
            for subGroup in subGroupDict.values {
                rval.append(contentsOf: subGroup.teamsAndGroups())
            }
        }
        return rval
    }
    
    func calculateShortestTour() -> [Team] {
        if let shortest = self.calculatedShortestTour {
            return shortest
        }
        
        var shortest : [Team] = []
        let tours = permutations(xs: self.teams())
        var shortestTourDistance : CLLocationDistance = CLLocationDistance.greatestFiniteMagnitude
        
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
                    shortest = tour
                    shortestTourDistance = currentTourDistance
                }
            }
        }
        self.calculatedShortestTour = shortest
        return calculateShortestTour()
    }
    
    func calculateShortestTourPolygon() -> MKPolygon {
        let coordinates = self.calculateShortestTour().map {$0.coordinate}
        let rval = MKPolygon(coordinates: coordinates, count: coordinates.count)
        return rval
    }

    
//    func moveTeamsToSubGroup(withName name: String) -> Group? {
//        guard let subGroup = addSubGroup(withName: name) else {
//            return nil
//        }
//
//        subGroup.addTeams(self.teams)
//        self.teams = []
//        return subGroup
//    }
    
    
}
