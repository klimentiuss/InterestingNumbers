//
//  NetworkManager.swift
//  InterestingNumbers
//
//  Created by Daniil Klimenko on 19.06.2022.
//

import Foundation

class NetworkManager {
    
  
    
    static let shared = NetworkManager()
    
    private init() {}
    
    
    
    func fetchData(from url: String?, with complition: @escaping (NumberFacts) -> Void) {
        guard let stringURL = url else { return }
        guard let url = URL(string: stringURL) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let numbersAndFucts = try JSONDecoder().decode(NumberFacts.self, from: data)
                
                DispatchQueue.main.async {
                    complition(numbersAndFucts)
                }
            } catch let error {
                print(error)
            }
            
        }.resume()
    }
    
}
