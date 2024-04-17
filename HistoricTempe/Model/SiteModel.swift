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
    @Published var geocodedLocations: [String: Location] = [:]
    @Published var wishlist : [HistoricalSite] = []
    @Published var favourites : [HistoricalSite] = []
    @Published var visited : [HistoricalSite] = []
    @Published var currentUser: User?
    private var userDocRef: DocumentReference?
    
    private let db = Firestore.firestore()
    private let GOOGLE_API_KEY = "AIzaSyB1YDk503zKf0qQEAChA_6OSNiqjgHZPXM"
    
    init() {
        loadHistoricalSites { updatedSites in
            self.historicalSites = updatedSites
            for site in updatedSites {
                self.fetchLocationDetails(for: site)
            }
            self.setupCurrentUser()
        }
        setupCurrentUser()
    }
    
    private func setupCurrentUser() {
        guard let user = Auth.auth().currentUser else {
            currentUser = nil
            userDocRef = nil
            return
        }
        
        let db = Firestore.firestore()
        userDocRef = db.collection("users").document(user.uid)
        getCurrentUserData()
    }
    
    private func getCurrentUserData() {
        userDocRef?.getDocument { snapshot, error in
            if let error = error {
                print("Error getting user data: \(error)")
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                let data = snapshot.data()
                let userId = data?["userId"] as? String
                let username = data?["username"] as? String
                self.currentUser = User(userId: userId!, username: username!)
                self.wishlist = self.getHistoricalSites(from: data?["wishlist"] as? [String] ?? [])
                self.favourites = self.getHistoricalSites(from: data?["favourites"] as? [String] ?? [])
                self.visited = self.getHistoricalSites(from: data?["visited"] as? [String] ?? [])
                
            } else {
                self.currentUser = nil
            }
        }
    }
    
    private func getHistoricalSites(from ids: [String]) -> [HistoricalSite] {
        return ids.compactMap { id in
            self.historicalSites.first { $0.internalID == id }
        }
    }
    
    func addToWishlist(_ site: HistoricalSite) {
        if !wishlist.contains(site) {
            wishlist.append(site)
            updateUserWishlist()
        }
    }
    
    func addToFavorites(_ site: HistoricalSite) {
        if !favourites.contains(site) {
            favourites.append(site)
            updateUserFavorites()
        }
    }
    
    func addToVisited(_ site: HistoricalSite) {
        if !visited.contains(site) {
            visited.append(site)
            updateUserVisited()
        }
    }
    
    private func updateUserWishlist() {
        guard let userDocRef = userDocRef else { return }
        userDocRef.updateData(["wishlist": wishlist.map { $0.internalID }])
    }
    
    private func updateUserFavorites() {
        guard let userDocRef = userDocRef else { return }
        userDocRef.updateData(["favourites": favourites.map { $0.internalID }])
    }
    
    private func updateUserVisited() {
        guard let userDocRef = userDocRef else { return }
        userDocRef.updateData(["visited": visited.map { $0.internalID }])
    }
    
    func removeFromWishlist(_ site: HistoricalSite) {
        if let index = wishlist.firstIndex(of: site) {
            wishlist.remove(at: index)
            updateUserWishlist()
        }
    }
    
    func removeFromFavorites(_ site: HistoricalSite) {
        if let index = favourites.firstIndex(of: site) {
            favourites.remove(at: index)
            updateUserFavorites()
        }
    }
    
    func removeFromVisited(_ site: HistoricalSite) {
        if let index = visited.firstIndex(of: site) {
            visited.remove(at: index)
            updateUserVisited()
        }
    }
    
    func loadHistoricalSites(completion: @escaping ([HistoricalSite]) -> Void) {
        db.collection("sites").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching historical sites: \(error)")
                return
            }
            
            var updatedHistoricalSites: [HistoricalSite] = []
            for document in querySnapshot?.documents ?? [] {
                guard let areaOfSignificance = document.get("areaOfSignificance") as? [String],
                      let category = document.get("categoryOfProperty") as? String,
                      let otherNames = document.get("otherNames") as? [String],
                      let propertyName = document.get("propertyName") as? String,
                      let statusDateTimestamp = document.get("statusDate") as? String,
                      let siteId = document.documentID as? String,
                      let streetAndNumber = document.get("streetAndNumber") as? String else {
                    continue
                }
                
                
                let statusDate = self.convertStringToDate(dateString: statusDateTimestamp)
                
                let historicalSite = HistoricalSite(internalID: siteId, areaOfSignificance: areaOfSignificance.joined(separator: ", "), category: category, otherNames: otherNames.joined(separator: ", "), propertyName: propertyName, statusDate: statusDate!, streetAndNumber: streetAndNumber, location: Location(latitude: 33.424564, longitude: -111.928001))
                updatedHistoricalSites.append(historicalSite)
                DispatchQueue.main.async {
                    self.historicalSites = updatedHistoricalSites
                }
            }
            completion(updatedHistoricalSites)
        }
    }
    
    func convertStringToDate(dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: dateString)
    }
    
    func fetchLocationDetails(for site: HistoricalSite) {
        let streetAndNumber = site.streetAndNumber
        let address = "\(streetAndNumber), Tempe, AZ, USA"
        guard let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error encoding address string.")
            return
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(encodedAddress)&key=\(GOOGLE_API_KEY)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
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
                            if let index = self.historicalSites.firstIndex(of: site) {
                                self.historicalSites[index] = updatedSite
                            }
                            self.geocodedLocations[site.id.uuidString] = locationDetails
                        }
                    }
                } catch {
                    print("error decoding Google geocoding API: \(error)")
                }
            }
        }.resume()
        
    }
}
