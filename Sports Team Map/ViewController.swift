//
//  ViewController.swift
//  Football Reorg
//
//  Created by Poul Hornsleth on 1/16/21.
//

import Cocoa
import MapKit

class ViewController: NSViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: NSTableView!

//    var array : [CLLocationCoordinate2D] = []
//
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Teams").appendingPathExtension("plist")
    
    let teamManager = TeamManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        mapView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        teamManager.initDefault()

        for team in teamManager.teams {
            self.mapView.addAnnotation(team)
        }
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
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = NSColor.gray.withAlphaComponent(0.25)
            renderer.strokeColor = NSColor.black
            renderer.lineWidth = 2
            return renderer
        }
        else if overlay is MKPolygon {
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = NSColor.purple.withAlphaComponent(0.5)
            renderer.strokeColor = NSColor.blue
            renderer.lineWidth = 2
            return renderer
        }

        return MKOverlayRenderer()
    }
}

extension ViewController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return teamManager.uiArray.count
    }
}


extension ViewController  : NSTableViewDelegate{
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let obj = teamManager.uiArray[row]
        
        if let conference = obj as? String {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TeamCellID"), owner: nil) as? NSTableCellView {

                cell.textField?.stringValue = conference
                cell.textField?.textColor = .red

                return cell
            }

        } else if let division = obj as? NSArray {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TeamCellID"), owner: nil) as? NSTableCellView {

                cell.textField?.stringValue = "\(division.firstObject!) \(division.lastObject!)"
                cell.textField?.textColor = .orange
                return cell
            }
        } else if let team = obj as? Team {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TeamCellID"), owner: nil) as? NSTableCellView {

                cell.textField?.stringValue = team.title!
                return cell
            }
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let obj = teamManager.uiArray[tableView.selectedRow]
        mapView.removeOverlays(mapView.overlays)

        if let conference = obj as? String {
            print(conference)
            if let divisions :[String: [Team]] = teamManager.teamMap[conference] {
                for (_, teams) in divisions {
                    var  coordinates = teams.map { $0.coordinate }
                    coordinates = coordinates.sorted { (lhs, rhs) -> Bool in
                        lhs.longitude < rhs.longitude
                        
                    }
                    let poly = MKPolygon(coordinates: coordinates, count: coordinates.count)
                    mapView.addOverlay(poly)
                }
            }

        } else if let division = obj as? [String],
                  let divisionConference = division.first,
                  let divisionName = division.last {

            if let teams = teamManager.teamMap[divisionConference]?[divisionName] {
                var  coordinates = teams.map { $0.coordinate }
                coordinates = coordinates.sorted { (lhs, rhs) -> Bool in
                    lhs.longitude < rhs.longitude
                }
                let poly = MKPolygon(coordinates: coordinates, count: coordinates.count)
                mapView.addOverlay(poly)

            }
        } else if let team = obj as? Team {
            let influenceCircle = MKCircle(center: team.coordinate, radius: 150 * 1.6 * 1000)
            mapView.addOverlay(influenceCircle)
        }
    }
}
