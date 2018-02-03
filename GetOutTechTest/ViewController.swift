//
//  ViewController.swift
//  GetOutTechTest
//
//  Created by Niklas Danz on 30.01.18.
//  Copyright © 2018 Monocular. All rights reserved.
//

import UIKit
import UserNotifications
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    // MARK: Variables and Constants
    
    let manager = CLLocationManager()
    let maxDistance: Double = 300.0 // 100 Meters
    
    var selectedLocation: CLLocationCoordinate2D!
    
    struct Locations {
        static let FrankfurtHauptbahnhof = CLLocationCoordinate2D(latitude: 50.106529, longitude: 8.6621618)
        static let KonstablerWache = CLLocationCoordinate2D(latitude: 50.1146166, longitude: 8.6880945)
        static let DreieichBuchschlag = CLLocationCoordinate2D(latitude: 50.0225189, longitude: 8.661456)
        static let DreieichWeibelfeld = CLLocationCoordinate2D(latitude: 50.007084, longitude: 8.700922)
    }
    
    @IBOutlet weak var maxDistanceLabel: UILabel!
    @IBOutlet weak var currentDistanceLabel: UILabel!
    @IBOutlet weak var selectedLocationLabel: UILabel!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var lonTextField: UITextField!
    
    @IBAction func toLocationSearchBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToLocationSearch", sender: self)
    }
    
    
    
    @IBAction func setCustomLocationBtn(_ sender: Any) {
        if latTextField.text == nil || lonTextField.text == nil {
            return
        }
        if latTextField.text == "" || lonTextField.text == "" {
            return
        }
        let latValue = Double(latTextField.text!)
        let lonValue = Double(lonTextField.text!)
        if latValue != nil && lonValue != nil {
            selectedLocation = CLLocationCoordinate2D(latitude: latValue!, longitude: lonValue!)
        }
        selectedLocationLabel.text = "lat: \(latValue!) lon: \(lonValue!)"
    }
    @IBAction func setLocationFraHbfBtn(_ sender: Any) {
        selectedLocation = Locations.FrankfurtHauptbahnhof
        selectedLocationLabel.text = "Frankfurt Hauptbahnhof"
    }
    @IBAction func setLocationKonstBtn(_ sender: Any) {
        selectedLocation = Locations.DreieichBuchschlag
        selectedLocationLabel.text = "Dreieich-Buchschlag"
    }
    @IBAction func setLocationDreieichBtn(_ sender: Any) {
        selectedLocation = Locations.DreieichWeibelfeld
        selectedLocationLabel.text = "Dreieich-Weibelfeld"
    }
    @IBAction func activateBtn(_ sender: Any) {
        if selectedLocation != nil {
            startLocationManager()
        } else {
            showAlert(title: "No location selected", text: "Please select a location")
        }
    }

    // MARK: View Delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        maxDistanceLabel.text = String(maxDistance)
        
        latTextField.delegate = self
        lonTextField.delegate = self
        latTextField.returnKeyType = .done
        lonTextField.returnKeyType = .done
        
        // Setup Location Manager

        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reset() {
        selectedLocation = nil
        selectedLocationLabel.text = "Please set location"
        currentDistanceLabel.text = ""
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Location Functions
    
    func startLocationManager() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The service is not available.
            return
        }/*
        manager.startMonitoringSignificantLocationChanges()
        print("location manager started")*/
        // Configure and start the service.
        
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.allowsBackgroundLocationUpdates = true
        manager.distanceFilter = 100.0  // In meters.
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        print("location changed to \(lastLocation)")
        
        // Do something with the location.
        let distance = lastLocation.distance(from: CLLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude))
        currentDistanceLabel.text = String(distance)
        print(distance)
        
        if distance < maxDistance {
            sendGetOutNotification()
            //manager.stopMonitoringSignificantLocationChanges()
            manager.stopUpdatingLocation()
            reset()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopUpdatingLocation()
            return
        }
        // Notify the user of any errors.
    }
    
    // MARK: Notification Functions
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    @objc func scheduleLocal() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default()
        
        /*
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        */
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func sendGetOutNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "GET OUT!"
        content.body = "You're about to reach your destination. Prepare to get out!"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "Get Out!"]
        content.sound = UNNotificationSound.default()
        
        /*
         var dateComponents = DateComponents()
         dateComponents.hour = 10
         dateComponents.minute = 30
         let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
         */
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        
        //showAlert(title: "Get Out!", text: "You have reached your destination.")
    }
    
    func showAlert(title: String, text: String) {
        let alertController = UIAlertController(title: title, message:
            text, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }


}

