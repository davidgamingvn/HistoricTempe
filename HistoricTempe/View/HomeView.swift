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
    
    let tempePos = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.424564, longitude: -111.928001),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    
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
                        Text("David Nguyen")
                        
                    }.padding()
                })
                
                Text("Find your next historical site")
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
                Map(coordinateRegion: .constant(tempePos), annotationItems: siteVM.historicalSites) { site in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: site.location.latitude!, longitude: site.location.longitude!
                    ), content: {
                        VStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.title)
                                .foregroundColor(.red)
                            Button(action: {}) {
                                Text(site.propertyName )
                            }.disabled(true)
                                .buttonStyle(.borderedProminent)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    })
                }
                    .mapStyle(.standard)
                    .safeAreaInset(edge: .bottom, content: {
                        HStack(alignment: .center)
                        {
                            Button(action: {
                                
                            }) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(.blue)
                                    .cornerRadius(15)
                            }
                            
                            
                            Button(action: {
                                
                            }) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(.red)
                                    .cornerRadius(15)
                            }
                            
                        }
                        .padding()
                    }
                    )
                Spacer()
                
                NavigationLink(destination: ARView()) {
                    Text("Street View")
                        .foregroundStyle(.white)
                        .padding()
                        .background(.blue)
                        .cornerRadius(10)
                }.padding()
            }
        }
        .overlay(
            // Sidebar
            SidebarView(showSidebar: $showSidebar)
                .offset(x : showSidebar ? 0 : -400, y : -250)
                .animation(.easeInOut(duration: 0.3))
            
        )
    }
    
    
    struct SidebarView : View {
        @Binding var showSidebar : Bool
        
        var body : some View {
            ZStack(alignment: .topLeading) {
                
                VStack(alignment: .leading){
                    Text("Wishlist")
                        .font(.headline)
                        .padding(.leading)
                    
                    Divider()
                    
                    
                    Text("Favourites")
                        .font(.headline)
                        .padding(.leading)
                    
                    Divider()
                    
                    Text("Visited")
                        .font(.headline)
                        .padding(.leading)
                    
                    Button(action: {
                        showSidebar = false
                    }){
                        Image(systemName : "xmark")
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                }
                .padding()
                .background(showSidebar ? Color.white.opacity(1) : Color.white.opacity(0))
            }
            .transition(.move(edge: .leading))
            .padding(.top, 10)
        }
    }
}

#Preview {
    HomeView()
}
