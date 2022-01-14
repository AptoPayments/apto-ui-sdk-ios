//
// FileDownloader.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 26/09/2019.
//

import Foundation

class FileDownloaderImpl: NSObject, FileDownloader {
    private var callback: Result<URL, NSError>.Callback?
    private let url: URL
    private let localFilename: String

    init(url: URL, localFilename: String) {
        self.url = url
        self.localFilename = localFilename
    }

    func download(callback: @escaping Result<URL, NSError>.Callback) {
        self.callback = callback
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = urlSession.downloadTask(with: url)
        task.resume()
    }

    static func clearCache() {
        guard let url = cacheDirectoryURL() else { return }
        do {
            try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []).forEach {
                if $0.pathExtension == "pdf" {
                    try? FileManager.default.removeItem(at: $0)
                }
            }
        } catch {}
    }
}

extension FileDownloaderImpl: URLSessionDownloadDelegate {
    func urlSession(_: URLSession, task _: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as NSError? {
            DispatchQueue.main.sync { [weak self] in
                self?.callback?(.failure(error))
            }
        }
    }

    func urlSession(_: URLSession, downloadTask _: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.sync { [weak self] in
            guard let self = self, let callback = self.callback else { return }
            guard let cacheDirectory = FileDownloaderImpl.cacheDirectoryURL() else {
                callback(.success(location))
                return
            }
            let localURL = cacheDirectory.appendingPathComponent(self.localFilename)
            try? FileManager.default.removeItem(at: localURL) // Remove previous file if exists
            do {
                try FileManager.default.moveItem(at: location, to: localURL)
                callback(.success(localURL))
            } catch {
                callback(.success(location))
            }
        }
    }

    private static func cacheDirectoryURL() -> URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last
    }
}
