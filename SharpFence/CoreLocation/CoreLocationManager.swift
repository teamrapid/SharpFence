//
//  CoreLocationManager.swift
//  SharpFence
//
//  Created by Sebin on 16-01-2018.
//  Copyright © 2018 Rapid Value. All rights reserved.
//

import Foundation
import CoreLocation

class CoreLocationManager: NSObject {
    let clLocationManagerObject = CLLocationManager()
    var stateObject: StateObjectModel?
    var selectedAccuracyLevel: CLLocationAccuracy?
    var locations: [LocationModel]?
    var monitoredRegions: [CLCircularRegion]?
    
    func setupLocationManager(stateObject: StateObjectModel?, locationAccuracy: CLLocationAccuracy?) {
        clLocationManagerObject.delegate = self
        self.stateObject = stateObject
        selectedAccuracyLevel = locationAccuracy
        if CLLocationManager.locationServicesEnabled() {
            //handles different cases of app's location services status
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                clLocationManagerObject.requestAlwaysAuthorization()
            case .authorizedAlways:
                locationList()
                trackUserLocation()
                startTrackingGeofencedRegion()
                break
            case .denied,.restricted:
                break
            default:
                break
            }
        } else {
            //executes when device location services is disabled
        }
    }
    
    func stopLocationMonitoring() {
        stopTrackinguserLocation()
        stopTrackingGeofencedRegion()
    }
    
    private func locationList(){
        //Fetch all locations from DB. All the locations should be mapped to Location model
        locations = DataWrapper.locationModels()
    }
    
    private func trackUserLocation()  {
        clLocationManagerObject.desiredAccuracy = selectedAccuracyLevel ?? kCLLocationAccuracyBest
        clLocationManagerObject.allowsBackgroundLocationUpdates = true
        clLocationManagerObject.startUpdatingLocation()
    }
    
    private func stopTrackinguserLocation(){
        clLocationManagerObject.stopUpdatingLocation()
    }
    
    //This method will create circular area, using longitude, latitude and radius, that needs to be monitored
    private func createCircularRegion(location: LocationModel) ->  CLCircularRegion?{
        if let latitude = location.latitude, let longitude = location.longitude,
            let radius = location.radius, let identifier = location.identifier {
            let geoCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let circularRegion = CLCircularRegion(center: geoCoordinate, radius: radius,
                                                  identifier: identifier)
            return circularRegion
        }
        return nil
    }
    
    private func startTrackingGeofencedRegion() {
        guard let _locations = locations else {
            return
        }
        monitoredRegions = [CLCircularRegion]()
        for location in _locations{
            if let _region = createCircularRegion(location: location){
                clLocationManagerObject.startMonitoring(for: _region)
                monitoredRegions?.append(_region)
            }
        }
    }
    
    private func stopTrackingGeofencedRegion(){
        guard let _monitoredRegions = monitoredRegions else {
            return
        }
        for region in _monitoredRegions {
            clLocationManagerObject.stopMonitoring(for: region)
        }
    }
}

extension CoreLocationManager: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion){
            if stateObject?.currentRegionId == nil{
                stateObject?.currentRegionId = region.identifier
                stateObject?.currentState = .green
            }else{
                //Unexpected. At the time of entry, there should not be any current region ID
        }
        stateObject?.objectStateAray.append(StateModel(state: .green, time: NSDate.init(), regionId: region.identifier, coordinate: manager.location?.coordinate))
        stateObject?.onGreen(forRegion: region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion){
        if stateObject?.currentRegionId == nil{
            //Unexpected. At the time of exit, there should be any current region ID
        }else{
            stateObject?.currentRegionId = region.identifier
            stateObject?.currentState = .white
        }
        stateObject?.objectStateAray.append(StateModel(state: .white, time: NSDate.init(), regionId: region.identifier, coordinate: manager.location?.coordinate))
        stateObject?.onWhite(fromRegion: region.identifier)
    }
}

