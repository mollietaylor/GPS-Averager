//
//  SavedVC.swift
//  GPS Averager
//
//  Created by Mollie on 2/27/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit
import MapKit

class SavedVC: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var sendCoords: [String:AnyObject] = [:]
    var sendCoordsIndex = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if (defaults.objectForKey("coordFormat") != nil) {
            coordFormat = defaults.objectForKey("coordFormat") as String
        } else {
            coordFormat = "Decimal degrees"
        }
        if defaults.objectForKey("baseMap") != nil {
            baseMap = defaults.objectForKey("baseMap") as String
        } else {
            defaults.setValue("Standard", forKey: "baseMap")
            baseMap = "Standard"
        }
        
        let mapTypes = ["Standard","Satellite","Hybrid"]
        let baseMapsIndex = UInt(find(mapTypes, baseMap)!)
        mapView.mapType = MKMapType(rawValue: baseMapsIndex)!
        
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        if (defaults.objectForKey("coordFormat") != nil) {
            coordFormat = defaults.objectForKey("coordFormat") as String
        } else {
            coordFormat = "Decimal degrees"
        }
        
        if (defaults.objectForKey("savedAverages") != nil) {
            savedAverages = defaults.objectForKey("savedAverages") as Array
        } else {
            savedAverages = []
        }
        
        // MARK: Mapping
        mapView.frame.size.width = self.view.frame.width
        
        mapView.delegate = self
        
        for average in savedAverages {
            
            let tempLat:String = average["Latitude"] as String
            let mapLat = (tempLat as NSString).doubleValue
            
            let tempLon:String = average["Longitude"] as String
            let mapLon = (tempLon as NSString).doubleValue
            
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(mapLat, mapLon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            
            let annLatLon = Functions.formatCoordinateString(lat: mapLat, lon: mapLon)
            annotation.title = "\(annLatLon.latString), \(annLatLon.lonString)"
            annotation.subtitle = average["Date"] as String
            
            mapView.addAnnotation(annotation)
            
        }
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.separatorInset = UIEdgeInsetsZero
        
        UIToolbar.appearance().barTintColor = UIColor.whiteColor()
        
        tableView.reloadData()
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        var rightArrowButton = ArrowButton(frame: CGRectMake(0, 0, 22, 22))
        rightArrowButton.strokeColor = (UIColor (red:1.00, green:0.23, blue:0.19, alpha:1))
        rightArrowButton.strokeSize = 1.2
        
        var pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        pinView.rightCalloutAccessoryView = rightArrowButton
        pinView.canShowCallout = true
        
        return pinView
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // TODO: Make sections by month or day
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedAverages.count
    }
    
    // MARK: Cell separators
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    // MARK: Cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        cell.accessoryView = UIImageView(image: UIImage(named: "accessory"))
        
        let coordsForCell = savedAverages[indexPath.row]
        
        let latToDisplay = coordsForCell["Latitude"] as String
        let lonToDisplay = coordsForCell["Longitude"] as String
        
        let LatLon = Functions.formatCoordinateString(lat: (latToDisplay as NSString).doubleValue, lon: (lonToDisplay as NSString).doubleValue)
        
        
        cell.textLabel?.text = "\(LatLon.latString), \(LatLon.lonString)"
        cell.detailTextLabel?.text = coordsForCell["Date"] as? String
        
        return cell
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        var i:Int = 0
        
        for average in savedAverages {
            
            if average["Date"] as? String == view.annotation.subtitle {
                
                sendCoords = savedAverages[i]
                sendCoordsIndex = i
                performSegueWithIdentifier("showSaved", sender: self)
                return
                
            } else {
                i++
            }
            
        }
        
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            savedAverages.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            defaults.setValue(savedAverages, forKey: "savedAverages")
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - Navigation
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        // this needs to be in willSelect so it will run before prepareForSegue runs
        sendCoords = savedAverages[indexPath.row]
        sendCoordsIndex = indexPath.row
        
        return indexPath
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "showSaved") {
            
            let newVC = segue.destinationViewController as AveragedVC
            newVC.coordsToDisplay = sendCoords
            newVC.coordsToDisplayIndex = sendCoordsIndex
            
        }
        
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        
        tableView.reloadData()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        navigationController?.setToolbarHidden(true, animated: true)
        
    }
    
}