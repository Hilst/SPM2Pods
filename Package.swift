// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let pckName = "SPM2Pods"
let tName = "TestExecutable"
let gen = "PodspecGen"

let package = Package(
	name: pckName,
	platforms: [ .iOS(.v13), .macOS(.v13) ],
	products: [
		.executable(name: tName, targets: [tName]),
		.plugin(name: pckName, targets: [pckName]),
		.executable(name: gen, targets: [gen])
	],
	dependencies: [
		.package(url: "https://github.com/swiftlang/swift-package-manager", branch: "main")
	],
    targets: [
		.plugin(
			name: pckName,
			capability: .buildTool(),
			dependencies: [.targetItem(name: gen, condition: .none)]
		),
		.executableTarget(
			name: tName,
			plugins: [.plugin(name: pckName)]),
		.executableTarget(name: gen,
						  dependencies: [
							.productItem(name: "SwiftPMDataModel", package: "swift-package-manager", moduleAliases: nil, condition: .none),
						  ]),
    ]
)
