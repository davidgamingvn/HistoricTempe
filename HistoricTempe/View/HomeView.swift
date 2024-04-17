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

struct HomeView: View {
    
    @State private var showSidebar = false
    @StateObject private var siteVM = SiteModel()
    @State private var numberOfPins: Int = 5 // Default number of pins
    @State private var selectedSite : HistoricalSite?
    @State private var hovered = false
    @State private var lookAroundViewLocation: CGPoint = .zero
    @State var showLookAroundView: Bool = false
    
    let tempePos = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.424564, longitude: -111.928001),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    
    var body: some View {
        NavigationView{
            GeometryReader{ geo in
                VStack{
                    Color.white.onAppear {
                        self.lookAroundViewLocation = .init(x: 150, y: geo.size.height - 100)
                    }
                    
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
                            Text("David Nguyen")
                            
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
                                Button(action: {
                                    siteVM.addToWishlist(selectedSite!)
                                }) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(.blue)
                                        .cornerRadius(15)
                                }
                                
                                
                                Button(action: {
                                    siteVM.addToFavorites(selectedSite!)
                                }) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(.red)
                                        .cornerRadius(15)
                                }
                                
                                Button(action: {
                                    siteVM.addToVisited(selectedSite!)
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(.green)
                                        .cornerRadius(15)
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
                    
                    //                NavigationLink(destination: StreetView()) {
                    //                    Text("Street View")
                    //                        .foregroundStyle(.white)
                    //                        .padding()
                    //                        .background(.blue)
                    //                        .cornerRadius(10)
                    //                }.padding()
                    
                    
                    LookAroundView(tappedLocation: $selectedSite.wrappedValue?.location,
                                   showLookAroundView: $showLookAroundView)
                    .frame(width: 250, height: 150)
                    .cornerRadius(10)
                    .position(lookAroundViewLocation)
                    .gesture(dragGesture)
                    .opacity(showLookAroundView ? 1 : 0)
                    
                    
                }.alert(isPresented: $hovered) {
                    Alert(
                        title: Text(selectedSite?.propertyName ?? ""),
                        message: Text(selectedSite?.areaOfSignificance ?? ""),
                        primaryButton: .default(Text("OK")),
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .overlay(
            // Sidebar
            SidebarView(showSidebar: $showSidebar)
                .offset(x : showSidebar ? 0 : -400, y : 50)
                .animation(.easeInOut(duration: 0.3))
                .environmentObject(siteVM)
            
        )
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                self.lookAroundViewLocation = value.location
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
