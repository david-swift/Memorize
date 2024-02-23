// swift-tools-version: 5.8
//
//  Package.swift
//  Flashcards
//

import PackageDescription

let package = Package(
    name: "Flashcards",
    dependencies: [
        .package(url: "https://github.com/AparokshaUI/Adwaita", from: "0.2.1")
    ],
    targets: [
        .executableTarget(
            name: "Flashcards",
            dependencies: [
                .product(name: "Adwaita", package: "Adwaita")
            ],
            path: "Sources"
        )
    ]
)
