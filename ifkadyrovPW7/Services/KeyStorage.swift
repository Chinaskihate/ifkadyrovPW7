//
//  KeyStorage.swift
//  ifkadyrovPW7
//
//  Created by user211270 on 1/28/22.
//

import Foundation

final class KeyStorage {
    static let storage = KeyStorage()
    private let key : String;
    private init() {
        key = "pk.eyJ1IjoibWFya3dhbnRzdG9rZW4iLCJhIjoiY2t5eW9kNmxvMDJncDJwbzBneHBocHp2eiJ9.NI9k1RcK7ackDUanHqcxQQ";
    }
    
    func getKey() -> String {
        return key;
    }
}
