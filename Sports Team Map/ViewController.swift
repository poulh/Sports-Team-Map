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

        self.mapView.fitAll(in: teamManager.teams, andShow: true)

        //        for team in teamManager.teams {
//            self.mapView.addAnnotation(team)
//        }
//
//        self.mapView.showAnnotations(self.mapView.annotations, animated: true)

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
                    let sortedTeams = teamManager.shortestTour(teams: teams)
                    let coordinates = teamManager.shortestTour(teams: sortedTeams).map {$0.coordinate}
                    let poly = MKPolygon(coordinates: coordinates, count: coordinates.count)
                    mapView.addOverlay(poly)
                    
                }
            }

        } else if let division = obj as? [String],
                  let divisionConference = division.first,
                  let divisionName = division.last {

            if let teams = teamManager.teamMap[divisionConference]?[divisionName] {
                let sortedTeams = teamManager.shortestTour(teams: teams)
                let coordinates = teamManager.shortestTour(teams: sortedTeams).map {$0.coordinate}
                let poly = MKPolygon(coordinates: coordinates, count: coordinates.count)
                mapView.addOverlay(poly)
            }
        } else if let team = obj as? Team {
            let influenceCircle = MKCircle(center: team.coordinate, radius: 150 * 1.6 * 1000)
            mapView.addOverlay(influenceCircle)
        }
    }
}

extension MKMapView {
    /// when we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
    func fitAll() {
        var zoomRect            = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect       = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01);
            zoomRect            = zoomRect.union(pointRect);
        }

        // setVisibleMapRect(zoomRect, edgePadding: NSEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
        setVisibleMapRect(zoomRect, animated: true)
    }

    /// we call this function and give it the annotations we want added to the map. we display the annotations if necessary
    func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
        var zoomRect:MKMapRect  = MKMapRect.null

        for annotation in annotations {
            let aPoint          = MKMapPoint(annotation.coordinate)
            let rect            = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)

            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        
        
        
        // setVisibleMapRect(zoomRect, edgePadding: NSEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
        setVisibleMapRect(zoomRect, animated: true)
    }

}
