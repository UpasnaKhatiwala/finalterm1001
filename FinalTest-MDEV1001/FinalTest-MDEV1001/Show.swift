//
//  Show.swift
//  FinalTest-MDEV1001
//
//  Created by Upasna Khatiwala on 2023-08-17.
//

import Foundation

struct Show: Codable {
    var documentID: String?
    var cast: [String]
    var composers: [String]
    var creators: [String]
    var description: String
    var episodes: Int32
    var genres: [String]
    var imageURL: String
    var language: String
    var network: String
    var originalRelease: String
    var seasons: Int32
    var title: String
}
