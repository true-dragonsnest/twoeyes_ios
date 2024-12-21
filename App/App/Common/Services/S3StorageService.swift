//
//  S3StorageService.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 5/11/24.
//

import Foundation
import AWSS3
import AWSCore

private let T = #fileID

public class S3StorageService {
    public struct Config {
        let accessKey: String
        let secretKey: String
        let endpoint: String
        public init(accessKey: String, secretKey: String, endpoint: String) {
            self.accessKey = accessKey
            self.secretKey = secretKey
            self.endpoint = endpoint
        }
    }
    private static var config: Config?
    public static func setup(_ config: Config) {
        Self.config = config
        _ = shared
    }
    
    public static let shared = S3StorageService()
    private init() {
    }
    
    public func setup() async throws {
        guard let config = Self.config else {
            throw AppError.notInited("no config".le(T))
        }
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: config.accessKey, secretKey: config.secretKey)
        guard let serviceConfig = AWSServiceConfiguration(region: .USEast1,
                                                          endpoint: .init(urlString: config.endpoint),
                                                          credentialsProvider: credentialsProvider) else {
            throw AppError.accessDenied("invalid service credential".le(T))
        }
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfig
        
        "S3 transfer utility setup done".ld(T)
    }
    
    public func upload(_ data: Data, 
                       bucket: String, 
                       filePath: String,
                       contentType: String) async throws {
        let transferUtility = AWSS3TransferUtility.default()
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")     // required for public read?
//        expression.progressBlock = { _, _ in }
        expression.progressBlock = { _, progress in
            "upload progress \(progress)".ld(T)
        }
        
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            transferUtility.uploadData(data,
                                       bucket: bucket,
                                       key: filePath,
                                       contentType: contentType,
                                       expression: expression) { task, error in
                if let error {
                    "upload failed : \(error)".le(T)
                    cont.resume(throwing: error)
                    return
                }
                
                "upload finished".ld(T)
                cont.resume()
            }.continueWith { t in
                "upload continue : \(o: t.error), \(o: t.result)".ld(T)
            }
        }
    }
    
    public func download(from bucket: String, filePath: String) async throws -> Data {
        let transferUtility = AWSS3TransferUtility.default()
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = { _, _ in }
//        expression.progressBlock = { _, progress in
//            "download progress \(progress)".ld(T)
//        }
        
        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Data, Error>) in
            transferUtility.downloadData(fromBucket: bucket, key: filePath, expression: expression) { task, url, data, error in
                "download comletion".ld(T)
                if let error {
                    "download failed : \(error)".le(T)
                    cont.resume(throwing: error)
                    return
                }
                guard let data else {
                    cont.resume(throwing: AppError.generalError("download wrong data".le(T)))
                    return
                }
                //"download finished".ld(T)
                cont.resume(returning: data)
            }.continueWith { t in
                "download continue : \(o: t.error), \(o: t.result)".ld(T)
            }
        }
    }
}
 
