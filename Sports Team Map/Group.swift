//
//  Group.swift
//  Sports Team Map
//
//  Created by Poul Hornsleth on 1/23/21.
//

import Foundation


class Group {
    
    init(withName name: String, andTeams teams: [Team]) {
        self.name = name
        let _ = addTeams(teams)
    }
    
    var name : String
    var parentGroup : Group? = nil
    var subGroupDict : [String:Group] = [:]
    
    var teamsDict : [String:Team] = [:]
    
    var path : [String] {
        if let parent = parentGroup {
            var parentPath =  parent.path
            parentPath.append(name)
            return parentPath
        }
        return []
    }
    
    func addTeam(_ team:Team) -> Bool {
        if subGroupDict.keys.count > 0 {
            return false
        }
        teamsDict[team.fullName] = team
        team.group = self.path
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
        team?.group = nil
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
