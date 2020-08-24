//
//  ViewController.swift
//  Filterer
//
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var filtersCollectionView: UICollectionView!
    let filterNames: [String] = ["RedTone", "BlueTone", "GreenTone", "SepiaTone", "MonoTone"]
    
    public var filteredImage: UIImage?
    var originalImage: UIImage?
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var originalImageView: UIImageView!
    
    @IBOutlet weak var editSlider: UISlider!
    
    @IBOutlet var filterEditMenu: UIView!
    @IBOutlet var bottomMenu: UIView!
    @IBOutlet var originalView: UIView!
    @IBOutlet var filtersMenu: UIView!
    
    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet var compareButton: UIButton!
    
    var usedMenuButton: Button?
    var usedFilterCell: FilterCell?
    
    var isFiltered: Bool = false {
        didSet {
            if isFiltered == true {
                enableCompareButton()
                filteredImage = imageView.image
                editButton.isEnabled = true
            } else {
                disableCompareButton()
                imageView.image = originalImage
                editButton.isEnabled = false
                usedFilterCell = nil
                editSlider.value = 0.8
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterEditMenu.translatesAutoresizingMaskIntoConstraints = false
        
        originalView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        filtersMenu.translatesAutoresizingMaskIntoConstraints = false
        
        originalImage = imageView.image
        
        originalImageView.backgroundColor = .black
        
        editButton.isEnabled = false
        
        filterButton.isEnabled = false
        
        disableCompareButton()
        
        filtersCollectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        filtersCollectionView.dataSource = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension ViewController {
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: UIButton) {
        if usedMenuButton != nil {
            usedMenuButton?.viewHidingFunc()
        }
        usedMenuButton = nil
        
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        
        present(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let albumPicker = UIImagePickerController()
        albumPicker.delegate = self
        albumPicker.sourceType = .photoLibrary
        
        present(albumPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            originalImage = image
            filterButton.isEnabled = true
            isFiltered = false
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController {
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if (sender.isSelected) {
            usedMenuButton?.viewHidingFunc()
            usedMenuButton = nil
        } else {
            if usedMenuButton != nil {
                usedMenuButton?.viewHidingFunc()
            }
            usedMenuButton = Button(button: filterButton, viewHidingFunc: hideFiltersMenu, viewShowingFunc: showFiltersMenu)
            usedMenuButton?.viewShowingFunc()
        }
    }
    
    func showFiltersMenu() {
        filterButton.isSelected = true
        view.addSubview(filtersMenu)
        
        let bottomConstraint = filtersMenu.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = filtersMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = filtersMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = filtersMenu.heightAnchor.constraint(equalToConstant: 60)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.filtersMenu.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.filtersMenu.alpha = 1.0
        }
    }

    func hideFiltersMenu() {
        filterButton.isSelected = false
        UIView.animate(withDuration: 0.4, animations: {
            self.filtersMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.filtersMenu.removeFromSuperview()
                }
        }
    }
}


// Filter methods
extension ViewController {
    public func filter(filterName: String,  intensity: Float = 0.8) {
        let image = setFilter(imageView.image!, filterName: filterName, intensity: intensity)
        imageView.image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: imageView.image!.imageOrientation)
        isFiltered = true
    }
    
    public func filter(color: CIColor, intensity: Float = 0.8) {
        let image = setFilter(imageView.image!, color: color, intensity: intensity)
        imageView.image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: imageView.image!.imageOrientation)
        isFiltered = true
    }
    
    func setFilter(_ image: UIImage, filterName: String,  intensity: Float = 0.8) -> UIImage {
        let context = CIContext()
         
        let filter = CIFilter(name: filterName)!
        let image = CIImage(image: image)
        filter.setValue(image, forKey: kCIInputImageKey)
        if filter.inputKeys.contains(kCIInputIntensityKey) {
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
        }
        let result = filter.outputImage!
        let cgImage = context.createCGImage(result, from: result.extent)
        
        let filteredImage = UIImage(cgImage: cgImage!)
        
        return filteredImage
    }
    
    func setFilter(_ image: UIImage, color: CIColor, intensity: Float = 0.8) -> UIImage {
        let context = CIContext()
         
        let filter = CIFilter(name: "CIColorMonochrome")!
        let image = CIImage(image: image)
        if filter.inputKeys.contains(kCIInputIntensityKey) {
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
        }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(color, forKey: kCIInputColorKey)
        let result = filter.outputImage!
        let cgImage = context.createCGImage(result, from: result.extent)
        
        let filteredImage = UIImage(cgImage: cgImage!)
        
        return filteredImage
    }
}

// Edit Button
extension ViewController {
    @IBAction func onEditButton(_ sender: UIButton) {
        if (sender.isSelected) {
            usedMenuButton?.viewHidingFunc()
            usedMenuButton = nil
        } else {
            if usedMenuButton != nil {
                usedMenuButton?.viewHidingFunc()
            }
            usedMenuButton = Button(button: editButton, viewHidingFunc: hideEditMenu, viewShowingFunc: showEditMenu)
            showEditMenu()
        }
    }
    
    func hideEditMenu() {
        editButton.isSelected = false
        UIView.animate(withDuration: 0.4, animations: {
            self.filterEditMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.filterEditMenu.removeFromSuperview()
                }
        }
    }
    
    func showEditMenu() {
        editButton.isSelected = true
        view.addSubview(filterEditMenu)
        
        let bottomConstraint = filterEditMenu.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = filterEditMenu.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = filterEditMenu.rightAnchor.constraint(equalTo: view.rightAnchor)
        let heightConstraint = filterEditMenu.heightAnchor.constraint(equalToConstant: 44)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.filterEditMenu.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.filterEditMenu.alpha = 1.0
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        imageView.image = originalImage
        var color: CIColor?
        var filterName: String?
        switch(usedFilterCell?.filterName) {
            case "CISepiaTone": filterName = "CISepiaTone"
        default: color = usedFilterCell?.filterColor
        }
        if color != nil {
            filter(color: color!, intensity: sender.value)
        } else {
            filter(filterName: filterName!, intensity: sender.value)
        }
    }
}

// Compare button
extension ViewController {
    func enableCompareButton() {
        compareButton.isEnabled = true
    }
    
    func disableCompareButton() {
        if compareButton.isEnabled == true {
            compareButton.isSelected = false
            compareButton.isEnabled = false
        }
    }
    
    @IBAction func onCompare(_ sender: UIButton) {
        if (sender.isSelected) {
            usedMenuButton?.viewHidingFunc()
            usedMenuButton?.button.isSelected = false
            usedMenuButton = nil
        } else {
            if usedMenuButton != nil {
                usedMenuButton?.viewHidingFunc()
            }
            self.compareButton.isSelected = true
            usedMenuButton = Button(button: compareButton, viewHidingFunc: hideOriginalImage, viewShowingFunc: showOriginalImage)
            usedMenuButton?.viewShowingFunc()
            usedMenuButton?.button.isSelected = true
        }
    }
}


// Long Pressure
extension ViewController {
    func showOriginalImage() {
        self.filterButton.isEnabled = false
        self.editButton.isEnabled = false
        originalImageView.image = originalImage
        view.addSubview(originalView)
        let bottomConstraint = originalView.bottomAnchor.constraint(equalTo: bottomMenu.topAnchor)
        let leftConstraint = originalView.leftAnchor.constraint(equalTo: view.leftAnchor)
        let rightConstraint = originalView.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        let heightConstraint = originalView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.originalView?.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.originalView?.alpha = 1.0
        }, completion: {
            completed in
            if completed {
                if !self.compareButton.isSelected {
                    if #available(iOS 13.0, *) {
                        self.compareButton.setImage(UIImage(systemName: "checkmark.rectangle"), for: .normal)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        })
    }
    
    func hideOriginalImage() {
        self.compareButton.isSelected = false
        self.filterButton.isEnabled = true
        self.editButton.isEnabled = true
        UIView.animate(withDuration: 0.4, animations: {
            self.originalView.alpha = 0
            }) { completed in
                if completed == true {
                    self.originalView.removeFromSuperview()
                    if #available(iOS 13.0, *) {
                        self.compareButton.setImage(UIImage(systemName: "xmark.rectangle"), for: .normal)
                    } else {
                        // Fallback on earlier versions
                    }
                }
        }
    }
    
    @IBAction func imageTapped(_ sender: UILongPressGestureRecognizer) {
        if isFiltered && !compareButton.isSelected {
            if sender.state == .began {
                showOriginalImage()
                compareButton.isUserInteractionEnabled = false
            }
            if sender.state == .ended {
                hideOriginalImage()
                compareButton.isUserInteractionEnabled = true
            }
        }
    }
}

extension ViewController {
    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        if usedMenuButton != nil {
            usedMenuButton?.viewHidingFunc()
        }
        usedMenuButton = nil
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}

struct Button {
    let button: UIButton
    
    let viewHidingFunc: () -> Void
    
    let viewShowingFunc: () -> Void
}


// CollectionViewDataSource && Delegate

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate,
                                            UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filtersCollectionView.dequeueReusableCell(withReuseIdentifier:
            "FilterCell", for: indexPath) as! FilterCell
        let filterName = filterNames[indexPath.item]
        cell.setupCell(self, filterName: filterName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 10, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
