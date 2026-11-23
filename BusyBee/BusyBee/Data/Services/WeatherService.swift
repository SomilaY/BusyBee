import Foundation

private enum APIKEY {
    static let key = "925ac7cd1d401c1dc7f6fa82a1254016"
}

enum WeatherError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Weather API URL."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from weather server."
        case .decodingError:
            return "Failed to decode weather data."
        }
    }
}

final class WeatherService {
    
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    func getWeather(for city: String) async throws -> WeatherResponse {
        guard let url = URL(string: "\(baseURL)?q=\(city)&appid=\(APIKEY.key)&units=metric") else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw WeatherError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(WeatherResponse.self, from: data)
        } catch {
            throw WeatherError.decodingError
        }
    }
    
    func getWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        guard let url = URL(string: "\(baseURL)?lat=\(lat)&lon=\(lon)&appid=\(APIKEY.key)&units=metric") else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw WeatherError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(WeatherResponse.self, from: data)
        } catch {
            throw WeatherError.decodingError
        }
    }
}
