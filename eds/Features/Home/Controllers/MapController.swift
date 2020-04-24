//
//  MapController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/24.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController {

    let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 0
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 1
    }

    private func initViews() {
        mapView.showsLargeContentViewer = true
        mapView.showsBuildings = true
        view.addSubview(mapView)
        mapView.edgesToSuperview()
        let geoCoder = CLGeocoder()
        let basic = BasicUtility.sharedInstance.basic
        guard let address = basic?.location else {
            return
        }
        geoCoder.geocodeAddressString(address) { placemarks, error in
            guard let location = placemarks?.first?.location else {
                return
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = basic?.user
            let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: false)

        }
    }

}
