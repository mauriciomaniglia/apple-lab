//
//  Landmark.swift
//  Landmarks
//
//  Created by Mauricio Maniglia on 07/07/22.
//

import Foundation

struct Landmark: Hashable, Codable {
    var id: Int
    var name: String
    var park: String
    var state: String
    var description: String
}
