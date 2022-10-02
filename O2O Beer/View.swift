//
//  View.swift
//  O2O Beer
//
//  Created by Gonzalo Fuentes on 30/9/22.
//

import Foundation
import UIKit

protocol View {
    var presenter: Presenter? { get set }
    
    func update(with result: [Beer])
    func update(with error: String)
}

class BeerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, View {
    var presenter: Presenter?
    var beers: [Beer] = []
    let searchBar: UISearchBar = UISearchBar()
    
    // MARK: UI Setup
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITableViewCell.appearance().selectionStyle = .none
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        // MARK: Setup navigation bar
        navigationItem.title = "Beer App"
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(hex: "#F6C101FF")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // MARK: Setup search bar
        navigationController?.navigationBar.tintColor = .white
        toggleSearchBarButton(show: true)
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.searchTextField.textColor = .white
        searchBar.placeholder = "Start typing food name..."
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    //MARK: Serach bar methods
    @objc func showSearchBar() {
        toggleSearchBar(show: true)
        searchBar.becomeFirstResponder()
        
    }
    
    func toggleSearchBarButton(show: Bool){
        navigationItem.rightBarButtonItem = show ? UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar)) : nil
        
    }
    
    func toggleSearchBar(show: Bool){
        toggleSearchBarButton(show: !show)
        searchBar.showsCancelButton = show
        navigationItem.titleView = show ? searchBar : nil
    }
    
    //MARK: Data methods
    func update(with beers: [Beer]) {
        print("Got beers")
        DispatchQueue.main.async {
            self.beers = beers
            self.tableView.reloadData()
        }
    }
    
    func update(with error: String) {
        print(error)
    }
    
    // MARK: Table data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = beers[indexPath.row].name
        content.image = UIImage(named: "BeerIcon")
        cell.contentConfiguration = content
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beerSelected: Beer = beers[indexPath.row]
        presenter?.selectedBeer(beer: beerSelected)
    }
}

// MARK: Search bar delegate
extension BeerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            presenter?.callInteractorDefaultBeers()
        } else {
            let url = "https://api.punkapi.com/v2/beers?food=" + searchText
            presenter?.callInteractorToRefetchBeers(url: url)
            
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            presenter?.callInteractorDefaultBeers()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter?.callInteractorDefaultBeers()
        toggleSearchBar(show: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

// MARK: Creating Beer Detail View
class BeerDetailView: UIViewController {
    var beer: Beer?
    let nameLabel: UILabel = UILabel()
    let beerDescription: UITextView = UITextView()
    let image: CustomImageView = CustomImageView()
    
    var layoutGuide: UILayoutGuide!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        layoutGuide = view.layoutMarginsGuide
        
        setupImage()
        setupName()
        setupDescription()
    }
    
    
    // MARK: Setting beer image
    func setupImage() {
        view.addSubview(image)
        
        if (beer?.image_url != nil) {
            image.loadFromURL(string: (beer?.image_url)!)
        } else {
            // MARK: Setting default image
            image.image = UIImage(named: "NoBeerImage")
        }
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.topAnchor.constraint(equalTo: view.topAnchor, constant: 75).isActive = true
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        image.widthAnchor.constraint(equalTo: layoutGuide.widthAnchor, multiplier: 0.7).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor).isActive = true
    }
    
    // MARK: Setting beer name
    func setupName() {
        view.addSubview(nameLabel)
        
        nameLabel.text = beer?.name
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 25).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: layoutGuide.widthAnchor, multiplier: 0.9).isActive = true
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        nameLabel.adjustsFontSizeToFitWidth = true
    }
    
    // MARK: Setting beer description
    func setupDescription() {
        view.addSubview(beerDescription)
        
        beerDescription.text = beer?.description
        
        beerDescription.translatesAutoresizingMaskIntoConstraints = false
        beerDescription.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 25).isActive = true
        beerDescription.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: 75).isActive = true
        beerDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        beerDescription.widthAnchor.constraint(equalTo: layoutGuide.widthAnchor, multiplier: 0.9).isActive = true
        beerDescription.textContainer.lineBreakMode = .byTruncatingTail
        beerDescription.backgroundColor = view.backgroundColor
        beerDescription.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
}

