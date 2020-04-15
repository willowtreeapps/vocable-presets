//
//  TextPresets.swift
//  Vocable-Presets
//
//  Created by Steve Foster on 4/13/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import Foundation

// Top level JSON object
public struct PresetData: Codable {

    public let schemaVersion: Int
    public var categories: [PresetCategory]
    public let phrases: [PresetPhrase]

}

public struct PresetCategory: Codable {

    public let id: String
    public var localizedName: [String: String]
    public let hidden: Bool

}

public struct PresetPhrase: Codable {

    public let id: String
    public let categoryIds: [String]
    public var localizedUtterance: [String: String]

}

public struct TextPresets {

    public static var presets: PresetData? {
        if let json = dataFromBundle() {
            do {

                let json = try JSONDecoder().decode(PresetData.self, from: json)

                for var category in json.categories {
                    category.localizedName = category.localizedName.mapValues { localization in
                        NSLocalizedString(category.id, tableName: localization, comment: "")
                    }
                }

                for var phrase in json.phrases {
                    phrase.localizedUtterance = phrase.localizedUtterance.mapValues { localization in
                        NSLocalizedString(phrase.id, tableName: localization, comment: "")
                    }
                }

                return json
            } catch {
                assertionFailure("Error decoding PresetData: \(error)")
            }
        }

        return nil
    }

    private static func dataFromBundle() -> Data? {

        guard let bundle = Bundle(identifier: "com.willowtreeapps.VocablePresets") else {
            return nil
        }

        if let path = bundle.path(forResource: "textpresets", ofType: "json") {
            do {
                return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            } catch {
                assertionFailure("🚨 Cannot parse \(path)")
                return nil
            }
        }

        return nil
    }

}
