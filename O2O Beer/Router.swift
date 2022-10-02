//
//  Router.swift
//  O2O Beer
//
//  Created by Gonzalo Fuentes on 30/9/22.
//

import Foundation
import UIKit

typealias EntryPoint = View & UIViewController

protocol Router {
    var entryPoint: EntryPoint? { get }
    static func start() -> Router
    
    func routeTo(destination: UIViewController)
}

class BeerRouter: Router {
    var entryPoint: EntryPoint?
    
    static func start() -> Router {
        let router = BeerRouter()
        
        // MARK: Create and assign VIP
        var view: View = BeerViewController()
        var interactor: Interactor = BeerInteractor()
        var presenter: Presenter = BeerPresenter()
        
        view.presenter = presenter
    
        interactor.presenter = presenter
        
        presenter.router = router
        presenter.view = view
        presenter.interactor = interactor
        
        // MARK: Assign app entry point
        router.entryPoint = view as? EntryPoint
        
        return router
    }
    
    func routeTo(destination: UIViewController) {
        self.entryPoint?.present(destination, animated: true)
    }
    
}
