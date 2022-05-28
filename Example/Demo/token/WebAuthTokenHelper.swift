import Foundation
import CommonCrypto

struct WebAuthTokenHelper {
    public static func generateAuthToken() -> String {
        let epochTime = Int(Date().timeIntervalSince1970)

        let currTimeFrame: String = String((epochTime/10)*10)
        let secretChunks = Configuration.default.tokenKey.chunked(Configuration.default.tokenKey.count/8)

        let frameHash = currTimeFrame.sha512Base64()
        let frameChunks = frameHash.chunked(frameHash.count/8)
        let joinedChunks = zip(secretChunks, frameChunks).reduce(into: []) { (partialResult: inout [String], tuple: (String, String)) in
                    partialResult += [tuple.0, tuple.1]
                }.joined(separator: "")

        return joinedChunks.sha512Base64()
    }
}


fileprivate extension String {
    func chunked(_ chunkLength: Int) -> [String] {
        var chunks: [String] = []
        let size = self.count/chunkLength
        for i in 0..<size {
            let beginIndex = index(startIndex, offsetBy: i*chunkLength)
            chunks.append(String(self[beginIndex..<index(beginIndex, offsetBy: chunkLength)]))
        }

        return chunks
    }

    func sha512Base64() -> String {
        guard let data = data(using: String.Encoding.utf8) else {
            return ""
        }

        var digest = Data(count: Int(CC_SHA512_DIGEST_LENGTH))
        _ = digest.withUnsafeMutableBytes { digestBytes -> UInt8 in
            data.withUnsafeBytes { messageBytes -> UInt8 in
                if let mb = messageBytes.baseAddress, let db = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let length = CC_LONG(data.count)
                    CC_SHA512(mb, length, db)
                }
                return 0
            }
        }
        return digest.base64EncodedString()
    }
}
