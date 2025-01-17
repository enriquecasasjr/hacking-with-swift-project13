//
//  ViewController.swift
//  Project13
//
//  Created by Enrique Casas on 11/3/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var radius: UISlider!
    
    var currentImage: UIImage!
    
    var context: CIContext!
    @objc dynamic var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        //currentFilter.addObserver(self, forKeyPath: #keyPath(currentFilter.name), options: .new, context: nil)
    }

    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func save(_ sender: UIButton) {
        guard let image = imageView.image else {
            let ac = UIAlertController(title: "No image selected", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
            return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        
        applyProcessing()
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
//    func applyProcessing() {
//        let inputKeys = currentFilter.inputKeys
//
//        if inputKeys.contains(kCIInputIntensityKey) {
//            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
//        }
//        if inputKeys.contains(kCIInputRadiusKey) {
//            currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
//        }
//        if inputKeys.contains(kCIInputScaleKey) {
//            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
//        }
//        if inputKeys.contains(kCIInputCenterKey) {
//            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
//        }
//
//        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
//            let processedImage = UIImage(cgImage: cgimg)
//            self.imageView.image = processedImage
//        }
//    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)
        }
        
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            
            let processedImage = UIImage(cgImage: cgimg)
            self.imageView.alpha = 0
            self.imageView.image = processedImage
            
            
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                self.imageView.alpha = 1
            })
        }
    }
    
//    func applyRadiusProcessing() {
//        let inputKeys = currentFilter.inputKeys
//
//        if inputKeys.contains(kCIInputRadiusKey) {
//            currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey)
//        }
//
//        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
//            let processedImage = UIImage(cgImage: cgimg)
//            self.imageView.image = processedImage
//        }
//    }
    
    func setFilter(action: UIAlertAction) {
        // make sure we have a valid image before continuing
        guard currentImage != nil else { return }
        
        //safely read the alert action's title
        guard let actionTitle = action.title else { return }
        
        filterButton.setTitle(action.title, for: .normal)
        
        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "name" {
//            filterButton.setTitle(currentFilter.name, for: .normal)
//        }
//    }
}

