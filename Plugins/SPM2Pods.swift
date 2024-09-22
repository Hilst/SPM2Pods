//
//  SPM2Pods.swift
//  SPM2Pods
//
//  Created by Felipe Hilst on 22/09/24.
//
import Foundation
import PackagePlugin

@main
struct SPM2Pods: BuildToolPlugin {
	func createBuildCommands(context: PackagePlugin.PluginContext, target: any PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
		return [
			.buildCommand(displayName: "SPM2Pods",
							 executable: try context.tool(named: "PodspecGen").url,
							 arguments: [
								"-p",
								context.package.directoryURL.absoluteString,
								"-t",
								target.name
							 ],
							 environment: [:])
		]
	}
}
