//
//  Interactor.swift
//  O2O Beer
//
//  Created by Gonzalo Fuentes on 30/9/22.
//

import Foundation

enum Errors: Error {
    case genericError
    case notFoundError
    case serverError
    case tooManyRequestsError
}

protocol Interactor {
    var presenter: Presenter? { get set }
    
    func getBeers(urlString: String)
}

class BeerInteractor: Interactor {
    var presenter: Presenter?
    
    // MARK: Load beers from provided URL
    func getBeers(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        print("Calling " + urlString)
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            // MARK: Check if errors
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    print("Beers request returned code ", httpResponse.statusCode)
                case 404:
                    self.presenter?.interactorFinishedFetchingBeers(with: .failure(Errors.notFoundError))
                    return
                case 500:
                    self.presenter?.interactorFinishedFetchingBeers(with: .failure(Errors.serverError))
                    return
                case 429:
                    self.presenter?.interactorFinishedFetchingBeers(with: .failure(Errors.tooManyRequestsError))
                    return
                default:
                    self.presenter?.interactorFinishedFetchingBeers(with: .failure(Errors.genericError))
                    return
                }
            }
            guard let data = data, error == nil else {
                self.presenter?.interactorFinishedFetchingBeers(with: .failure(Errors.genericError))
                return
            }
            
            do {
                let beers = try JSONDecoder().decode([Beer].self, from: data)
                self.presenter?.interactorFinishedFetchingBeers(with: .success(beers))
            } catch {
                self.presenter?.interactorFinishedFetchingBeers(with: .failure(error))
            }
        }
        
        session.resume()
    }
}
