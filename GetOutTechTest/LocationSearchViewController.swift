//
//  LocationSearchViewController.swift
//  GetOutTechTest
//
//  Created by Niklas Danz on 01.02.18.
//  Copyright © 2018 Monocular. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GooglePlacesSearchController

class LocationSearchViewController: ViewController {

    let GoogleSearchPlaceAPIKey = "AIzaSyDFR4_-SpHKvrYtAKMhAwuDzmChOICI24g"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let controller = GooglePlacesSearchController(apiKey: GoogleSearchPlaceAPIKey)
        controller.didSelectGooglePlace { (place) in
            print(place.description)
            controller.isActive = false
        }
        // Do any additional setup after loading the view.
        present(controller, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
