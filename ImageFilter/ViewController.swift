//
//  ViewController.swift
//  ImageFilter
//
//  Created by Ilya Kokorin on 09.10.2024.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "YACIFP"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
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
    
    @IBAction func changeFilterButtonTapped(_ sender: UIButton) {
        changeFilter(sender)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        applyProcessing()
    }
    
    @IBAction func changeFilter(_ sender: Any) {
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

    func setFilter(action: UIAlertAction) {
        // Make sure we have a valid image before continuing!
           guard currentImage != nil else { return }

           // Safely read the alert action's title
           guard let actionTitle = action.title else { return }
           
           // Print the action title to verify the filter name
           print("Selected filter: \(actionTitle)")

           // Set the current filter to the selected filter
           currentFilter = CIFilter(name: actionTitle)

           // Check if the filter was created successfully
           if currentFilter == nil {
               print("Failed to create filter: \(actionTitle)")
               return
           } else {
               print("Successfully created filter: \(currentFilter.name)")
           }

           // Set the input image for the filter
           let beginImage = CIImage(image: currentImage)
           currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

           // Apply processing to update the image view
           applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys

            if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
            if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey) }
            if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey) }
            if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }

            if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                self.imageView.image = processedImage
            }
    }
}

