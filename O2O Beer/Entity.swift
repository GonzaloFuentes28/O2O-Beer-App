//
//  Entity.swift
//  O2O Beer
//
//  Created by Gonzalo Fuentes on 30/9/22.
//

import Foundation

// MARK: Define beer model
struct Beer: Codable {
    let name: String
    let image_url: String?
    let description: String
}
