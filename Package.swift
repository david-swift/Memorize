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
        .package(url: "https://github.com/AparokshaUI/Localized", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "Flashcards",
            dependencies: [
                .product(name: "Adwaita", package: "Adwaita"),
                .product(name: "Localized", package: "Localized")
            ],
            path: "Sources"
        )
    ]
)
