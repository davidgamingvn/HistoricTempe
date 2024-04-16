//
//  SiteModel.swift
//  ClassProject
//
//  Created by Dinh Phuc Nguyen on 3/17/24.
//

import Foundation
import Combine
import Firebase


class SiteModel : ObservableObject {
    @Published var historicalSites : [HistoricalSite] = []
    
    private let db = Firestore.firestore()
    private let GOOGLE_API_KEY = "AIzaSyB1YDk503zKf0qQEAChA_6OSNiqjgHZPXM"
    
    init() {
        loadHistoricalSites()
    }
    
    func loadHistoricalSites() {
        db.collection("sites").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching historical sites: \(error)")
                return
            }
            
            var updatedHistoricalSites: [HistoricalSite] = []
            for document in querySnapshot?.documents ?? [] {
                guard let areaOfSignificance = document.get("areaOfSignificance") as? String,
                      let category = document.get("categoryOfProperty") as? String,
                      let otherNames = document.get("otherNames") as? [String],
                      let propertyName = document.get("propertyNames") as? String,
                      let statusDateTimestamp = document.get("statusDate") as? Timestamp,
                      let streetAndNumber = document.get("streetAndNumber") as? String else {
                    continue
                }
                
                let statusDate = statusDateTimestamp.dateValue()
                let historicalSite = HistoricalSite(areaOfSignificance: areaOfSignificance, category: category, otherNames: otherNames.joined(separator: ", "), propertyName: propertyName, statusDate: statusDate, streetAndNumber: streetAndNumber, location: Location(latitude: 33.424564, longitude: -111.928001))
                updatedHistoricalSites.append(historicalSite)
                self.fetchLocationDetails(for: historicalSite)
            }
            
            DispatchQueue.main.async {
                self.historicalSites = updatedHistoricalSites
            }
        }
    }
    
    func fetchLocationDetails(for site: HistoricalSite) {
        let streetAndNumber = site.streetAndNumber
        let address = "\(streetAndNumber), Tempe, AZ, USA"
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(String(describing: address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))&key=\(GOOGLE_API_KEY)"
        guard let url = URL(string : urlString) else {return}
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                print ("Error fetching geocoding details from Google : \(error)")
                return
            }
            
            if let data = data {
                do {
                    let geocodeResponse = try JSONDecoder().decode(GoogleGeocodingResponse.self, from: data)
                    if let location = geocodeResponse.results.first?.geometry.location {
                        let locationDetails = Location(latitude: location.lat, longitude: location.lng)
                        DispatchQueue.main.async {
                            var updatedSite = site
                            updatedSite.location = locationDetails
                            self.historicalSites[self.historicalSites.firstIndex(of: site)!] = updatedSite
                        }
                    }
                } catch {
                    print("error decoding Google geocoding API: \(error)")
                }
            }
        }.resume()
        
    }
}
