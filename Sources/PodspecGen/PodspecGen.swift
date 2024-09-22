//
//  PodspecGen.swift
//  SPM2Pods
//
//  Created by Felipe Hilst on 22/09/24.
//
import Foundation

// Read and model Package.swift
import PackageModel
import PackageLoading
import Basics

/*
Pod::Spec.new do |spec|
  spec.name         = 'Reachability'
  spec.version      = '3.1.0'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://github.com/tonymillion/Reachability'
  spec.authors      = { 'Tony Million' => 'tonymillion@gmail.com' }
  spec.summary      = 'ARC and GCD Compatible Reachability Class for iOS and OS X.'
  spec.source       = { :git => 'https://github.com/tonymillion/Reachability.git', :tag => 'v3.1.0' }
  spec.source_files = 'Reachability.{h,m}'
  spec.framework    = 'SystemConfiguration'
end
*/

enum PodspecGenError: Error {
	case input
}

@main
struct PodspecGen {
	static func main() async {
		print("Começou")
		guard let input = inputs(),
			  let package = input["p"],
			  let packageURL = URL(string: package),
			  let targetName = input["t"] else {
			print("ERROR on inputs")
			return
		}
		print("Inputs: \(packageURL), \(targetName)")

		let path = "/\(packageURL.pathComponents.dropFirst().joined(separator: "/"))"

		guard let m = await manifest(path: path, target: targetName) else {
			print("ERROR on manifest")
			return
		}
		m.products.forEach { print("product: \($0)") }
	}

	static func inputs() -> [String: String]? {
		var arguments = CommandLine.arguments
		arguments.removeFirst(1)
		var inputs = [String: String]()
		for i in stride(from: 0, to: arguments.count, by: 2) {
			guard i + 1 < arguments.count else { return nil }
			inputs[arguments[i].replacingOccurrences(of: "-", with: "")] = arguments[i + 1]
		}
		return inputs
	}

	static func manifest(
		path: String,
		target: String
	) async -> Manifest? {
		guard let absolute = try? Basics.AbsolutePath(validating: path) else {
			print("ERRROR on absolute for path: \(path)")
			return nil
		}
		let fs = Basics.localFileSystem

		guard let toolchain = try? UserToolchain(swiftSDK: .hostSwiftSDK()) else {
			print("ERRROR on toolchain")
			return nil
		}

		let loader = ManifestLoader(toolchain: toolchain)

		let identityResolver = DefaultIdentityResolver()
		let dependencyMapper = DefaultDependencyMapper(identityResolver: identityResolver)

		return try? await loader.load(packagePath: absolute,
									 packageIdentity: .plain(target),
									 packageKind: .root(absolute),
									 packageLocation: path,
									 packageVersion: nil,
									 currentToolsVersion: ToolsVersion.current,
									 identityResolver: identityResolver,
									 dependencyMapper: dependencyMapper,
									 fileSystem: fs,
									 observabilityScope: ObservabilitySystem.NOOP,
									 delegateQueue: DispatchQueue.global(),
									 callbackQueue: DispatchQueue.main)
	}
}
