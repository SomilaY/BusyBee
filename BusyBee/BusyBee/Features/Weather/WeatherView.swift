import SwiftUI

struct WeatherView: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @StateObject private var locationManager = LocationManager()
    
    let fallbackCity = "Johannesburg"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weatherViewModel.weather?.name ?? fallbackCity)
                        .font(.title3).bold()
                        .foregroundStyle(Color("containerText"))
                    
                    Text(weatherViewModel.conditionText)
                        .font(.subheadline)
                        .foregroundStyle(Color("containerText").opacity(0.8))
                }
                
                Spacer()
                
                Text(weatherViewModel.temperatureText)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color("containerText"))
            }
            
            WeatherSYSCard(sunrise: weatherViewModel.sunriseText, sunset: weatherViewModel.sunsetText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: weatherViewModel.backgroundGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 1), value: weatherViewModel.backgroundGradientColors)
        )
        .cornerRadius(12)
        .padding(.horizontal)
        .task {
            locationManager.checkLocationAuthorization()
        }
        .onChange(of: locationManager.lastKnownLocation?.latitude) { _, _ in
            if let coordinate = locationManager.lastKnownLocation {
                weatherViewModel.fetchWeather(lat: coordinate.latitude, lon: coordinate.longitude)
            } else {
                weatherViewModel.fetchWeather(city: fallbackCity)
            }
        }
    }
}

struct WeatherSYSCard: View {
    let sunrise: String
    let sunset: String
    
    var body: some View {
        HStack(spacing: 16) {
            WeatherSysItem(image: "sunrise.fill", title: "Sunrise", time: sunrise)
            Spacer()
            WeatherSysItem(image: "sunset.fill", title: "Sunset", time: sunset)
        }
    }
}

struct WeatherSysItem: View {
    let image: String
    let title: String
    let time: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: image)
                .font(.title3)
                .foregroundStyle(Color("containerText"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("containerText").opacity(0.8))
                
                Text(time)
                    .font(.caption.bold())
                    .foregroundStyle(Color("containerText"))
            }
        }
    }
}

#Preview {
    WeatherView(weatherViewModel: WeatherViewModel())
}
