
//
//  StorageManager.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/29/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    // image/maruf-dhaka2010-gmail-com
    public typealias uploadProfilePictureCompletetion = (Result<String, Error>) -> Void
    //Upload Picture to Firebase data base return completion with URL String
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping uploadProfilePictureCompletetion){
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        let storageRef = storage.child("images/\(fileName)")
        storageRef.putData(data, metadata: uploadMetadata) { (downloadMetadata, error) in
            guard error == nil else{
                print("Failed to upload data to firebase for picture: \(String(describing: error?.localizedDescription))")
                completion(.failure(StorageError.fileUploadError))
                return
            }
            guard let myMetadata = downloadMetadata else {return}
            print("Put is complete and I got this back: \(myMetadata)")
            storageRef.downloadURL { (url, error) in
                guard let url = url else{
                    print("Failed to get download URL: \(String(describing: error?.localizedDescription))")
                    completion(.failure(StorageError.failedToDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("Download Url return: \(urlString)")
                completion(.success(urlString))
            }
            print("Put is complete I got this back \(String(describing: downloadMetadata))")
        }
    }
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping uploadProfilePictureCompletetion){
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/png"
        let storageRef = storage.child("message_image/\(fileName)")
        storageRef.putData(data, metadata: uploadMetadata) { [weak self] (downloadMetadata, error) in
            guard error == nil else{
                print("Failed to upload data to firebase for picture: \(String(describing: error?.localizedDescription))")
                completion(.failure(StorageError.fileUploadError))
                return
            }
            guard let myMetadata = downloadMetadata else {return}
            print("Put is complete and I got this back: \(myMetadata)")
            storageRef.downloadURL { (url, error) in
                guard let url = url else{
                    print("Failed to get download URL: \(String(describing: error?.localizedDescription))")
                    completion(.failure(StorageError.failedToDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("Download Url return: \(urlString)")
                completion(.success(urlString))
            }
            print("Put is complete I got this back \(String(describing: downloadMetadata))")
        }
    }
    public func uploadMessageVideo(with videoUrl: URL, fileName: String, completion: @escaping uploadProfilePictureCompletetion){
//        let uploadMetadata = StorageMetadata.init()
//        uploadMetadata.contentType = "image/png"
        let storageRef = storage.child("message_video/\(fileName)")
        storageRef.putFile(from: videoUrl, metadata: nil, completion: { downloadMetadata, error in
            guard error == nil else{
                print("Failed to upload Url to firebase for Video: \(String(describing: error?.localizedDescription))")
                completion(.failure(StorageError.fileUploadError))
                return
            }
            guard let myMetadata = downloadMetadata else {return}
            print("PutFile is complete and I got this back: \(myMetadata)")
            storageRef.downloadURL { (url, error) in
                guard let url = url else{
                    print("Failed to get download Video URL: \(String(describing: error?.localizedDescription))")
                    completion(.failure(StorageError.failedToDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                print("Download Video Url return: \(urlString)")
                completion(.success(urlString))
            }
            print("Put File is complete I got this back \(String(describing: downloadMetadata))")
        })
        
    }
    public func downloadProfilePicture(with path: String, completion: @escaping (Result<URL, Error>) -> Void){
        let reference = storage.child(path)
//        print("Path for download picture: ", path)
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageError.failedToDownloadURL))
                return
            }
            completion(.success(url))
        })
    }
    
    public enum StorageError: Error{
           case fileUploadError
           case failedToDownloadURL
       }
}
