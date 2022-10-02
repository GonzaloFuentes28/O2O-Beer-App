//
//  Extension.swift
//  O2O Beer
//
//  Created by Gonzalo Fuentes on 30/9/22.
//

import Foundation
import UIKit

// MARK: Create extension to create UIColor from HEX
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

// MARK: Create Custom ImageView to load from url
class CustomImageView: UIImageView {
    func loadFromURL(string: String){
        guard let imageURL = URL(string: string) else { return }
        print("Downloaded image from " + string)
        
        let session = URLSession(configuration: .default)
        
        let downloadPicTask = session.dataTask(with: imageURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading the image: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded beer image with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        DispatchQueue.main.async {
                            self.image = UIImage(data: imageData)
                        }
                        // Do something with your image.
                    } else {
                        print("Error creating image")
                    }
                } else {
                    print("Error getting response code")
                }
            }
        }
        
        downloadPicTask.resume()
            
    }
}
