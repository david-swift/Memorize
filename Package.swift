// swift-tools-version: 5.8
//
//  Package.swift
//  Memorize
//

import PackageDescription

let package = Package(
    name: "Flashcards",
    dependencies: [
        .package(url: "https://github.com/AparokshaUI/Adwaita", branch: "main"),
        .package(url: "https://github.com/AparokshaUI/Localized", from: "0.2.2"),
        .package(url: "https://github.com/truizlop/FuzzyFind", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "Flashcards",
            dependencies: [
                .product(name: "Adwaita", package: "Adwaita"),
                .product(name: "Localized", package: "Localized"),
                .product(name: "FuzzyFind", package: "FuzzyFind")
            ],
            path: "Sources",
            resources: [.process("Model/Localized.yml")],
            plugins: [.plugin(name: "GenerateLocalized", package: "Localized")]
        )
    ]
)
