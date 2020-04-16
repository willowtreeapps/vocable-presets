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
    public let categories: [PresetCategory]
    public let phrases: [PresetPhrase]

}

public struct PresetCategory: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case hidden
    }

    public let id: String
    public let hidden: Bool
    public var localizedName: [String: String] = [:]

}

public struct PresetPhrase: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case categoryIds
    }

    public let id: String
    public let categoryIds: [String]
    public var localizedUtterance: [String: String] = [:]

}

public struct TextPresets {

    private static var localBundle: Bundle {
        return Bundle(identifier: "com.willowtreeapps.VocablePresets")!
    }

    public static var presets: PresetData? {
        if let json = dataFromBundle() {
            do {

                let json = try JSONDecoder().decode(PresetData.self, from: json)

                let localizations = localBundle.localizations
                let transformedCategories = json.categories.map { category -> PresetCategory in
                    var preset = PresetCategory(id: category.id, hidden: category.hidden)
                    preset.localizedName = localizations.reduce([String: String]()) { (result, localization) in
                        var result = result
                        let value = NSLocalizedString(category.id, tableName: localization, bundle: localBundle, comment: "")
                        result[localization] = value
                        return result
                    }
                    return preset
                }

                let transformedPhrases = json.phrases.map { phrase -> PresetPhrase in
                    var preset = PresetPhrase(id: phrase.id, categoryIds: phrase.categoryIds)
                    preset.localizedUtterance = localizations.reduce([String: String]()) { (result, localization) in
                        var result = result
                        let value = NSLocalizedString(phrase.id, tableName: localization, bundle: localBundle, comment: "")
                        result[localization] = value
                        return result
                    }
                    return preset
                }
                let result = PresetData(schemaVersion: json.schemaVersion,
                                        categories: transformedCategories,
                                        phrases: transformedPhrases)
                return result
            } catch {
                assertionFailure("Error decoding PresetData: \(error)")
            }
        }

        return nil
    }

    private static func dataFromBundle() -> Data? {

        if let path = localBundle.path(forResource: "presets", ofType: "json") {
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
