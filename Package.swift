// swift-tools-version: 5.8
//
//  Package.swift
//  Memorize
//

import PackageDescription

let package = Package(
    name: "Flashcards",
    dependencies: [
        .package(url: "https://github.com/AparokshaUI/Adwaita", from: "0.2.5"),
        .package(url: "https://github.com/AparokshaUI/Localized", from: "0.2.2")
    ],
    targets: [
        .executableTarget(
            name: "Flashcards",
            dependencies: [
                .product(name: "Adwaita", package: "Adwaita"),
                .product(name: "Localized", package: "Localized")
            ],
            path: "Sources",
            resources: [.process("Model/Localized.yml")],
            plugins: [.plugin(name: "GenerateLocalized", package: "Localized")]
        )
    ]
)
