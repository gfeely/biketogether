//
//  IndiRecordViewController.swift
//  BikeTogether
//
//  Created by Supassara Sujjapong on 12/5/16.
//  Copyright © 2016 Supassara Sujjapong. All rights reserved.
//

import UIKit
import MapKit

class IndiRecordViewController: UIViewController, MKMapViewDelegate {
    
    var rname = ""
    var rid = 0
    var timeDuration = ""
    var distance: Double = 0
    var startTime = ""
    var stopTime = ""
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        print("===========================")
        print("IndiRecordViewController")
        
        print(rname)
        mapView.delegate = self
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: "http://ridebike.atilal.com/viewrecord.php/")!)
        request.HTTPMethod = "POST"
        let postString = "uid=\(userID)&rname=\(rname)"
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let dataTask = session.dataTaskWithRequest(request) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let error = error {
                // Case 1: Error
                // We got some kind of error while trying to get data from the server.
                print("Error:\n\(error)")
            }
            else {
                // Case 2: Success
                // We got a response from the server!
                
                if data != nil{
                    
                    print("** View record (DBMethod)**")
                    let json = JSON(data: data!)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let id = json["rid"].string!
                        let dis = json["distance"].string!

                        self.rid = Int(id)!
                        self.timeDuration = json["timeduration"].string!
                        self.distance = Double(dis)!
                        self.stopTime = json["stoptimestamp"].string!
                        self.startTime = json["starttimestamp"].string!
                        
                        print("rid = \(self.rid)")
                        print("time duration = \(self.timeDuration)")
                        print("distance = \(self.distance)")
                        print("stop time = \(self.stopTime)")
                        print("start time = \(self.startTime)")
                        
                        viewLocation(self.rid, handler: {
                            location, count in
                            
                            let region = MKCoordinateRegion(center: location[count-1].coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                            self.mapView.setRegion(region, animated: true)
                            
                            let source = CLLocationCoordinate2D(latitude: location[0].coordinate.latitude, longitude: location[0].coordinate.longitude)
                            let destination = CLLocationCoordinate2D(latitude: location[count-1].coordinate.latitude, longitude: location[count-1].coordinate.longitude)
                            
                            let startPoint = MKPointAnnotation()
                            startPoint.coordinate = source
                            startPoint.title = "Starting Point"
                            self.mapView.addAnnotation(startPoint)
                            
                            let destPoint = MKPointAnnotation()
                            destPoint.coordinate = destination
                            destPoint.title = "Finishing Point"
                            self.mapView.addAnnotation(destPoint)
                            
                            for i in 1...count-1{
                                //Draw route method needs two points to draw
                                //Continuously send two location points to be drawn by the method
                                drawRoute(self, c1: location[i-1], c2: location[i])
                            }
                        })
                    })
                }
            }
        }
        dataTask.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        //Polyline properties
        
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blueColor()
        polylineRenderer.lineWidth = 4
        return polylineRenderer
    }

}
