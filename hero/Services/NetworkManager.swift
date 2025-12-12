//
//  NetworkManager.swift
//  hero
//
//  Created by Абылайхан Бегимкулов on 12.12.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case requestFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://akabab.github.io/superhero-api/api/all.json"
    private var allSuperheroes: [Superhero] = []
    
    private init() {}
    
    func fetchAllSuperheroes() async throws -> [Superhero] {
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let superheroes = try decoder.decode([Superhero].self, from: data)
            self.allSuperheroes = superheroes
            return superheroes
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw NetworkError.decodingError
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    func getRandomSuperhero() async throws -> Superhero {
        if allSuperheroes.isEmpty {
            allSuperheroes = try await fetchAllSuperheroes()
        }
        
        guard let randomHero = allSuperheroes.randomElement() else {
            throw NetworkError.noData
        }
        
        return randomHero
    }
}
