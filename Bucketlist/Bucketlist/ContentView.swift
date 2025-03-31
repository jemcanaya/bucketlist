import SwiftUI
import MapKit

struct ContentView: View {
    
    // All the properties in @State is already relocated in the ViewModel class
    @State private var viewModel = ViewModel()
    
    let mapStyles : [String] = ["Standard", "Imagery", "Hybrid"]
    @State private var selectedMapStyle = "Standard"
    
    let equivalentMapStyles = { (mapStyle: String) -> MapStyle in
        switch mapStyle {
        case "Standard":
                .standard
        case "Imagery":
                .imagery
        case "Hybrid":
                .hybrid
        default:
                .standard
        }
    }
    
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 12.8797, longitude: 121.7740),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    
    var body: some View {
        if viewModel.isUnlocked {
            ZStack {
                MapReader { proxy in
                    Map(initialPosition: startPosition) {
                        ForEach(viewModel.locations) { location in
                            Annotation(location.name, coordinate: location.coordinate) {
                                Button {
                                    //selectedPlace = location
                                } label: {
                                    Image(systemName: "star.circle")
                                        .resizable()
                                        .foregroundStyle(.red)
                                        .frame(width: 44, height: 44)
                                        .background(.white)
                                        .clipShape(.circle)
                                        .onLongPressGesture(minimumDuration: 0.3, perform: {
                                            viewModel.selectedPlace = location
                                        })
                                }
                                
                            }
                        }
                    }
                    .mapStyle(equivalentMapStyles(selectedMapStyle))
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(at: coordinate)
                            print("New location appended")
                        }
                        
                    }
                    .sheet(item: $viewModel.selectedPlace) { place in
                        EditView(location: place) {
                            viewModel.update(location: $0)
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Picker("Map Style", systemImage: "map.fill", selection: $selectedMapStyle) {
                            ForEach(mapStyles, id: \.self) {
                                Text($0)
                            }
                        }
                        .foregroundStyle(.blue)
                        .background(.white)
                        .clipShape(.capsule)
                        .padding()
                    }
                }
                
            }
            
        } else {
            Button("Unlock Places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
                .alert("Authentication Failed", isPresented: $viewModel.biometricFailed) {
                    Button("OK") { }
                } message: {
                    Text("Failed to authenticate. Please try again.")
                }
        }
        
    }
}


#Preview {
    ContentView()
}
