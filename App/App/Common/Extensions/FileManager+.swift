//
//  FileManager+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/02/05.
//

import Foundation

public extension FileManager {
    func getFolderPath(for directory: FileManager.SearchPathDirectory,
                       in domain: FileManager.SearchPathDomainMask,
                       pathComponent: String? = nil) throws -> URL
    {
        var folderPath = try url(for: directory, in: domain, appropriateFor: nil, create: true)
        if let pathComponent = pathComponent {
            folderPath = folderPath.appendingPathComponent(pathComponent)
        }
        return folderPath
    }

    func getOrCreateFolderPath(for directory: FileManager.SearchPathDirectory,
                               in domain: FileManager.SearchPathDomainMask,
                               pathComponent: String? = nil) throws -> URL
    {
        let folderPath = try getFolderPath(for: directory, in: domain, pathComponent: pathComponent)
        var isDir: ObjCBool = true
        if !fileExists(atPath: folderPath.path, isDirectory: &isDir) {
            try createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
        }
        return folderPath
    }

    func deleteFolder(at pathComponent: String,
                      for directory: FileManager.SearchPathDirectory,
                      in domain: FileManager.SearchPathDomainMask) throws
    {
        let folderPath = try getFolderPath(for: directory, in: domain, pathComponent: pathComponent)
        var isDir: ObjCBool = true
        if fileExists(atPath: folderPath.path, isDirectory: &isDir) {
            try removeItem(at: folderPath)
        }
    }
}
