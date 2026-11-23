// xcode: set sdk=iOS

import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack {
            if let weatherData = viewModel.weather {
                Text("Temperature: \(weatherData.temperature)°C")
                Text("Condition: \(weatherData.condition)")
            } else {
                Text("Loading weather data...")
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchWeather()
        }
    }
}
