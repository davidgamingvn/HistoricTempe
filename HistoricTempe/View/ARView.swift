import SwiftUI
import CoreLocation
import GoogleMaps

struct ARView: View {
    let historicalSite: HistoricalSite
    
    var body: some View {
        VStack {
            Text(historicalSite.propertyName)
                .font(.headline)
                .padding()
            
            GoogleStreetView(coordinate: CLLocationCoordinate2D(latitude: historicalSite.location.latitude, longitude: historicalSite.location.longitude))
                .overlay(content: {
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                // Place a marker when the view appears
                                addMarker(geometry: geometry)
                            }
                    }
                })
        }
    }
    
    func addMarker(geometry: GeometryProxy) {
        let markerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        markerView.backgroundColor = .clear
        let markerLabel = UILabel(frame: markerView.bounds)
        markerLabel.text = historicalSite.propertyName
        markerLabel.font = .systemFont(ofSize: 12)
        markerLabel.textAlignment = .center
        markerLabel.numberOfLines = 2
        markerView.addSubview(markerLabel)
        
        // Convert the coordinate to point on the view
        let coordinatePoint = CLLocationCoordinate2D(latitude: historicalSite.location.latitude, longitude: historicalSite.location.longitude)
       
        let marker = GMSMarker()
        marker.position = coordinatePoint
        marker.iconView = markerView
        
        // Add marker to the map
        marker.map = GMSMapView()
    }
}

struct GoogleStreetView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> GMSPanoramaView {
        let panoramaView = GMSPanoramaView(frame: .zero)
        panoramaView.moveNearCoordinate(coordinate)
        return panoramaView
    }
    
    func updateUIView(_ uiView: GMSPanoramaView, context: Context) {
        uiView.moveNearCoordinate(coordinate)
    }
}

struct ARView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleSite = HistoricalSite(internalID: "12345", areaOfSignificance: "Phoenix", category: "Property", otherNames: "", propertyName: "State Capitol", statusDate: Date(), streetAndNumber: "1700 W Washington St", location: Location(latitude: 33.448377, longitude: -112.164237))
        return ARView(historicalSite: sampleSite)
    }
}
