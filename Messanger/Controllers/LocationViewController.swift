//
//  LocationViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 8/24/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationViewController: UIViewController {
    
    var completion: ((CLLocationCoordinate2D) -> Void)?
    var coordinate: CLLocationCoordinate2D?
    var isPickable = true
    init(coordinates: CLLocationCoordinate2D?){
        self.coordinate = coordinates
        isPickable = false
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let map: MKMapView = {
        let map = MKMapView()
        map.isZoomEnabled = true
        
        return map
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        if isPickable{
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Send", style: .done, target: self, action: #selector(sendLocationButtonTapped))
            map.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapMap))
            gesture.numberOfTapsRequired = 1
            gesture.numberOfTouchesRequired = 1
            map.addGestureRecognizer(gesture)
            
        }else{
            guard let coordinate = coordinate else { return }
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            
            map.addAnnotation(pin)
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    @objc func sendLocationButtonTapped(){
        guard let coordinate = coordinate else{
            return
        }
//        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
        completion?(coordinate)
    }
    @objc func tapMap(_ gesture: UITapGestureRecognizer){
        let locationView = gesture.location(in: map)
        let coordinate = map.convert(locationView, toCoordinateFrom: map)
        self.coordinate = coordinate
        //drop a pin on the point
        for annotaton in map.annotations{
            map.removeAnnotation(annotaton	)
        }
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        map.addAnnotation(pin)
    }
}
