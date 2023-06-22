//
//  FileManager.swift
//  FocusStart
//
//  Created by sergey on 06.02.2023.
//

import SwiftUI

final public class DocumentsModel {
    static let fileManager = FileManager.default
    static let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    static var cache: [String] {
        guard let url = documentsDirectory else {
            return []
        }
        do {
            return try fileManager.contentsOfDirectory(at: url,
                                                       includingPropertiesForKeys: [],
                                                       options: [
                                                        .skipsHiddenFiles,
                                                        .skipsPackageDescendants,
                                                        .skipsSubdirectoryDescendants
                                                       ]).filter(\.hasDirectoryPath).map { $0.lastPathComponent }
        } catch {
            print(error)
            return []
        }
    }
    static func createFolder(with name: String) {
        guard let url = documentsDirectory?.appendingPathComponent(name) else {
            return
        }
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            print(error)
            return
        }
    }
    static func write(data: Data, with fileName: String) {
        guard let url = documentsDirectory?
            .appendingPathComponent("cache", isDirectory: true)
            .appendingPathComponent(fileName)
        else {
            return
        }
        do {
            try data.write(to: url)
        } catch {
            print(error)
        }
    }
    static func read(from fileName: String) -> Data? {
        guard let url = documentsDirectory?
            .appendingPathComponent("cache", isDirectory: true)
            .appendingPathComponent(fileName)
        else {
            return nil
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            print(error)
        }
        
        return nil
    }
}
