//
//  MapChapterSelectionView.swift
//  MazeGaze
//
//  Created by Ali Haidar on 26/05/24.
//

import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocation?
    private var locationManager: CLLocationManager

    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error)")
    }
}

struct MapChapterSelectionView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var userPos: MapCameraPosition = .userLocation(fallback: .automatic)
    @State var navigateToLevel: Bool = false
    @State var navigateToLevel2: Bool = false
    
    let PiazzaMozia = CLLocationCoordinate2D(latitude: -6.290518564193445, longitude: 106.62767753509547)
    let apple = CLLocationCoordinate2D(latitude: -6.3020087056735505, longitude: 106.65257292477594)
    let ice = CLLocationCoordinate2D(latitude: -6.30019624889913, longitude:  106.63639805175998)
    let aeon = CLLocationCoordinate2D(latitude: -6.305223934660311, longitude: 106.64335164011995)

    var body: some View {
        NavigationStack {
            ZStack {
                
                Map(position: $userPos) {
                    UserAnnotation()
                    
                    Annotation("AEON", coordinate: aeon) {
                        if isWithinDistance(of: aeon) {
                            CustomMarkerView(level: "Level 4", distance: distance(from: aeon)) {
                                navigateToLevel = true
                                ButtonSound.playMusic(selectedSound: "map_sound")
                            }
                        }
                    }
                    
                    Annotation("ICE", coordinate: ice) {
                        if isWithinDistance(of: ice) {
                            CustomMarkerView(level: "Level 3", distance: distance(from: ice)) {
                                navigateToLevel2 = true
                                ButtonSound.playMusic(selectedSound: "map_sound")
                            }
                        }
                    }
                    
                    Annotation("Piazza", coordinate: PiazzaMozia) {
                        if isWithinDistance(of: PiazzaMozia) {
                            CustomMarkerView(level: "Level 2", distance: distance(from: PiazzaMozia)) {
                                navigateToLevel2 = true
                                ButtonSound.playMusic(selectedSound: "map_sound")
                            }
                        }
                    }
                    
                    Annotation("Apple", coordinate: apple) {
                        if isWithinDistance(of: apple) {
                            CustomMarkerView(level: "Level 1", distance: distance(from: apple))  {
                                navigateToLevel2 = true
                                ButtonSound.playMusic(selectedSound: "map_sound")
                            }
                        }
                    }
                }
                .mapStyle(.standard())
                .mapControls {
                    MapUserLocationButton()
                }
                
                VStack {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("You can only play each level if you are within 500 meters of your current location!")
                            .font(.title)
                       
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25.0).foregroundStyle(.thinMaterial))
                    Spacer()
                }.padding()
                    
                
            }
            .sheet(isPresented: $navigateToLevel) {
                LevelSelectionSheet(levelImage: "1", levelTitle: "Level One", navigateToLevel2: $navigateToLevel2)
            }
            .navigationDestination(isPresented: $navigateToLevel2) {
                Level1View()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func isWithinDistance(of coordinate: CLLocationCoordinate2D) -> Bool {
        guard let userLocation = locationManager.userLocation else { return false }
        let annotationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = userLocation.distance(from: annotationLocation)
        return distance <= 500000
    }
    
    private func distance(from coordinate: CLLocationCoordinate2D) -> String {
            guard let userLocation = locationManager.userLocation else { return "Unknown" }
            let annotationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distance = userLocation.distance(from: annotationLocation)
            return String(format: "%.2f km", distance / 1000)
        }
}

struct CustomMarkerView: View {
    let level: String
    let distance: String
    let action: () -> Void

    var body: some View {
        VStack {
               
            VStack {
                Text(level)
                    .bold()
                .font(.title)
                Text("Distance: \(distance)")
                                    .font(.subheadline)
            }
        }.onTapGesture {
            if Double(distance.replacingOccurrences(of: " km", with: "")) ?? 0 <= 0.5 {
                action()

            } else{
                ButtonSound.playMusic(selectedSound: "fail")
            }
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 25).foregroundStyle(.ultraThickMaterial))
    }
}

struct LevelSelectionSheet: View {
    let levelImage: String
    let levelTitle: String
    @Binding var navigateToLevel2: Bool

    var body: some View {
        VStack {
            ZStack {
                Image(levelImage)
                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                Text(levelTitle)
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .shadow(radius: 10)
            }
            
            
            Button {
                // Handle play button action
                navigateToLevel2 = true
            } label: {
                HStack {
                    Spacer()
                    Text("Play")
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding()
                    Spacer()
                }
                .background(RoundedRectangle(cornerRadius: 25.0).foregroundStyle(Color(hex: "#E65355")))
            }
            .padding(.horizontal, 40)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .padding(25)
    }
}

#Preview {
    MapChapterSelectionView()
}

