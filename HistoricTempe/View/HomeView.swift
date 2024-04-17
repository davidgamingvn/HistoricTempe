//
//  HomeView.swift
//  ClassProject
//
//  Created by Dinh Phuc Nguyen on 3/17/24.
//

import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth


struct HomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showSidebar = false
    @StateObject private var siteVM = SiteModel()
    @State private var numberOfPins: Int = 5 // Default number of pins
    @State private var selectedSite : HistoricalSite?
    @State private var hovered = false
    @State private var currentUser: FirebaseAuth.User?

    
    let tempePos = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.424564, longitude: -111.928001),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    init() {
        guard let user = Auth.auth().currentUser else {
            // User is not logged in, navigate back to the LandingPage
            return
        }
        // User is logged in, proceed to the HomeView
        self._currentUser = State(initialValue: user)

    }
    
    var body: some View {
        NavigationView{
            VStack{
                HStack(alignment: .lastTextBaseline, content: {
                    
                    Button(action: {
                        showSidebar.toggle()
                    }){
                        Image(systemName: "line.horizontal.3")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                    }
                    
                    Spacer()
                    
                    HStack{
                        Image(systemName: "person.circle")
                        Text(siteVM.currentUser?.username ?? "Guest")
                                                
                        Button(action: {
                            signOut()
                        }) {
                            Text("Sign Out")
                                .foregroundStyle(.red)
                        }
                        
                    }.padding()
                })
                
                Text("Find your next historical site")
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
                Map(coordinateRegion: .constant(tempePos), annotationItems: siteVM.historicalSites.prefix(numberOfPins)) { site in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: site.location.latitude!, longitude: site.location.longitude!
                    ), content: {
                        VStack {
                            Button(action: {
                                selectedSite = site
                                hovered = true
                            }) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.0))
                        }
                    })
                }
                .mapStyle(.standard)
                .safeAreaInset(edge: .bottom, content: {
                    VStack{
                        HStack(alignment: .center)
                        {
                            if selectedSite != nil {
                                Button(action: {
                                    siteVM.addToWishlist(selectedSite!)
                                }) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(15)
                                }
                                
                                Button(action: {
                                    siteVM.addToFavorites(selectedSite!)
                                }) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(15)
                                }
                                
                                Button(action: {
                                    siteVM.addToVisited(selectedSite!)
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(15)
                                }
                            }
                            
                        }
                        // Slider to control pin count
                        Stepper("Number of sites: \(numberOfPins)", value: $numberOfPins, in: 1...20, step: 1)
                            .padding()
                        
                        HStack {
                            Text("Your current site:")
                            Text(selectedSite?.propertyName ?? "")
                        }
                    }
                    .padding()
                }
                )
                Spacer()
                
                if let selectedSite = selectedSite {
                    NavigationLink(destination: ARView(historicalSite: selectedSite)) {
                        Text("Street View")
                            .foregroundStyle(.white)
                            .padding()
                            .background(.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
            }.alert(isPresented: $hovered) {
                Alert(
                    title: Text(selectedSite?.propertyName ?? ""),
                    message: Text(selectedSite?.areaOfSignificance ?? ""),
                    primaryButton: .default(Text("OK")),
                    secondaryButton: .cancel()
                )
            }
        }
        .overlay(
            // Sidebar
            SidebarView(showSidebar: $showSidebar)
                .offset(x : showSidebar ? 0 : -400, y : 50)
                .animation(.easeInOut(duration: 0.3))
                .environmentObject(siteVM)
            
        )
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    
    struct SidebarView : View {
        @Binding var showSidebar : Bool
        @EnvironmentObject var siteVM : SiteModel
        
        var body : some View {
            ZStack(alignment: .topLeading) {
                ScrollView{
                    VStack(alignment: .leading){
                        Text("Wishlist")
                            .font(.headline)
                            .padding(.leading)
                        
                        List {
                            ForEach(siteVM.wishlist, id: \.id) { site in
                                Text(site.propertyName)
                            }.onDelete{
                                indexSet in
                                siteVM.wishlist.remove(atOffsets: indexSet)
                                
                            }
                        }.frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                        
                        Divider()
                        
                        
                        Text("Favourites")
                            .font(.headline)
                            .padding(.leading)
                        
                        List {
                            ForEach(siteVM.favourites, id: \.id) { site in
                                Text(site.propertyName)
                            }.onDelete{
                                indexSet in
                                siteVM.favourites.remove(atOffsets: indexSet)
                                
                            }
                        }.frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                        
                        Divider()
                        
                        Text("Visited")
                            .font(.headline)
                            .padding(.leading)
                        
                        List {
                            ForEach(siteVM.visited, id: \.id) { site in
                                Text(site.propertyName)
                            }.onDelete{
                                indexSet in
                                siteVM.visited.remove(atOffsets: indexSet)
                                
                            }
                        }.frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                        
                        Button(action: {
                            showSidebar = false
                        }){
                            Image(systemName : "xmark")
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                    }
                }
                .padding()
                .background(showSidebar ? Color.white.opacity(1) : Color.white.opacity(0))
            }
            .transition(.move(edge: .leading))
        }
    }
    
}

#Preview {
    HomeView()
}
