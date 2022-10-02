//
//  Presenter.swift
//  O2O Beer
//
//  Created by Gonzalo Fuentes on 30/9/22.
//

import Foundation

protocol Presenter {
    var router: Router? { get set }
    var interactor: Interactor? { get set }
    var view: View? { get set }
    
    func interactorFinishedFetchingBeers(with result: Result<[Beer], Error>)
    func callInteractorToRefetchBeers(url: String)
    func callInteractorDefaultBeers()
    func selectedBeer(beer: Beer)
}

class BeerPresenter: Presenter {
    
    
    var router: Router?
    var interactor: Interactor? {
        didSet {
            interactor?.getBeers(urlString: "https://api.punkapi.com/v2/beers")
        }
    }
    var view: View?

    // MARK: Alert view that interactod finished fetching beers
    func interactorFinishedFetchingBeers(with result: Result<[Beer], Error>) {
        switch result {
        case .success(let beers):
            view?.update(with: beers)
        case .failure(let error):
            print(error)
            view?.update(with: "Error")
        }
    }
    
    // MARK: Load beers with specified url
    func callInteractorToRefetchBeers(url: String) {
        interactor?.getBeers(urlString: url)
    }
    
    // MARK: Load default beers
    func callInteractorDefaultBeers(){
        interactor?.getBeers(urlString: "https://api.punkapi.com/v2/beers")
    }
    
    // MARK: Ask router to present view
    func selectedBeer(beer: Beer) {
        let detailView = BeerDetailView()
        detailView.beer = beer
        router?.routeTo(destination: detailView)
    }
}
