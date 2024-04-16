//
//  Site.swift
//  ClassProject
//
//  Created by Dinh Phuc Nguyen on 3/17/24.
//

import Foundation
import CoreLocation


struct HistoricalSite : Identifiable, Equatable {
    let id = UUID()
    let areaOfSignificance : String
    let category : String
    let otherNames : String
    let propertyName : String
    let statusDate : Date
    let streetAndNumber : String
    var location : Location
    static func == (lhs: HistoricalSite, rhs : HistoricalSite) -> Bool {
        return lhs.id == rhs.id
    }
}


struct Location : Equatable {
    let latitude : Double!
    let longitude : Double!
    
    static func == (lhs : Location, rhs: Location) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct GoogleGeocodingResponse : Codable {
    let results : [GoogleGeocodingResult]
}

struct GoogleGeocodingResult : Codable {
    let geometry : GoogleGeocodingGeometry
}

struct GoogleGeocodingGeometry : Codable {
    let location : GoogleGeocodingLocation
}

struct GoogleGeocodingLocation : Codable {
    let lat : Double
    let lng : Double
}
