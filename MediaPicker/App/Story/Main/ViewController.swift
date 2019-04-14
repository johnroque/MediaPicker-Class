//
//  ViewController.swift
//  MediaPicker
//
//  Created by John Roque Jorillo on 14/04/2019.
//  Copyright © 2019 John Roque Jorillo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
    }
    
    private func initViews() {
        initButtons()
    }
    
    private func initButtons() {
        selectImageButton.addTarget(self, action: #selector(showMediaPicker), for: .touchUpInside)
    }

    @objc private func showMediaPicker() {
        mediaPicker.showMediaSelectionAlert(inViewController: self)
    }
    
    // MARK: Private
    private lazy var mediaPicker: MediaPickerService = {
        let config = MediaPickerService.Config.init(placeholder: #imageLiteral(resourceName: "image-placeholder"), supportedSources: [.camera, .gallery])
        
        let mediaPicker = MediaPickerService(serviceable: self, config: config)
        return mediaPicker
    }()

}

extension ViewController: MediaPickerServiceable {
    func uploaderAddedFileForUpload(withURL url: URL, withThumbnail thumbnail: UIImage?) {
        
        selectedImageView.image = thumbnail
    }
    
    func uploaderAlertCancelled() {
        
    }
}

