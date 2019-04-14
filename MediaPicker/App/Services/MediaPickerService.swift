//
//  FileUploadService.swift
//  MediaPicker
//
//  Created by John Roque Jorillo on 14/04/2019.
//  Copyright © 2019 John Roque Jorillo. All rights reserved.
//

import AVKit
import Foundation
import MobileCoreServices
import QuickLook
import UIKit

protocol MediaPickerServicing {
    
    func showMediaSelectionAlert(inViewController viewController: UIViewController)
    
}

protocol MediaPickerServiceable: AnyObject {
    
    func uploaderAddedFileForUpload(withURL url: URL, withThumbnail thumbnail: UIImage?)
    
    func uploaderAlertCancelled()
    
}

class MediaPickerService: NSObject, MediaPickerServicing {
    
    struct Config {
        
        enum SupportedSource {
            case camera
            case gallery
        }
        
        let placeholder: UIImage
        let supportedSources: [SupportedSource]
        
    }
    
    init(serviceable: MediaPickerServiceable, config: Config) {
        self.serviceable = serviceable
        self.config = config
    }
    
    func showMediaSelectionAlert(inViewController viewController: UIViewController) {
        
        self.viewController = viewController
        
        let mediaPicker = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        config.supportedSources.forEach { (sources) in
            switch sources {
            case .camera:
                let fromCamera = UIAlertAction(title: "Camera", style: .default, handler: didSelectFromCamera(_:))
                mediaPicker.addAction(fromCamera)
            case .gallery:
                let fromGallery = UIAlertAction(title: "Gallery", style: .default, handler: didSelectFromGallery(_:))
                mediaPicker.addAction(fromGallery)
            }
        }
        
        let didCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: didCancel(_:))
        mediaPicker.addAction(didCancel)
        viewController.present(mediaPicker, animated: true, completion: nil)
        
    }
    
    private weak var serviceable: MediaPickerServiceable?
    var config: Config
    
    var viewController: UIViewController?
    
}

extension MediaPickerService {
    
    private func didSelectFromCamera(_ action: UIAlertAction) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        viewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    private func didSelectFromGallery(_ action: UIAlertAction) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        viewController?.present(imagePicker, animated: true, completion: nil)
    }
    
    private func didCancel(_ action: UIAlertAction) {
        
    }
    
}

extension MediaPickerService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            guard let mediaType = info[.mediaType] else { return }
            switch mediaType as! CFString {
            case kUTTypeImage:
                self.handle(imageWithInfo: info)
            case kUTTypeMovie:
                self.handle(movieWithInfo: info)
            default:
                // TODO: - Handle Error Here
                break
            }
        }
        
    }
    
    func handle(movieWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let movieURL = info[.mediaURL] as? URL else { fatalError() }
        let asset: AVAsset = AVAsset(url: movieURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset);
        imageGenerator.appliesPreferredTrackTransform = true
        let thumbnail: UIImage? = {
            guard let cgImage = try? imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil) else { return nil }
            return UIImage(cgImage: cgImage)
        }()
        
        self.serviceable?.uploaderAddedFileForUpload(withURL: movieURL, withThumbnail: thumbnail)
    }
    
    func handle(imageWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageURL = info[.imageURL] as? URL {
            
            guard let thumbnail = info[.originalImage] as? UIImage else { fatalError() }
      
            self.serviceable?.uploaderAddedFileForUpload(withURL: imageURL, withThumbnail: thumbnail)
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
