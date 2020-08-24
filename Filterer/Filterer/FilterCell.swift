//
//  FilterCell.swift
//  Filterer
//
//  Created by Usman Turkaev on 23.08.2020.
//  Copyright © 2020 UofT. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    var filterName: String?
    
    var viewController: ViewController?
    
    var filterColor: CIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gesture = UITapGestureRecognizer(target: self,
                                            action: #selector(gestureAction))
        addGestureRecognizer(gesture)
    }

    @objc func gestureAction(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if viewController?.usedFilterCell == self {
                viewController?.isFiltered = false
            } else {
                if viewController!.isFiltered { viewController?.isFiltered = false }
                viewController?.usedFilterCell = self
                if filterColor != nil {
                    viewController?.filter(color: filterColor!)
                } else {
                    viewController?.filter(filterName: filterName!)
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        filterColor = nil
        filterName = nil
    }
    
    func setupCell(_ controller: ViewController, filterName: String) {
        imageView.image = UIImage(named: filterName)
        viewController = controller
        switch(filterName) {
        case "RedTone": filterColor = CIColor(red: 1, green: 0, blue: 0)
        case "BlueTone": filterColor = CIColor(red: 0, green: 0, blue: 1)
        case "GreenTone": filterColor = CIColor(red: 0, green: 1, blue: 0)
        case "MonoTone": filterColor = CIColor(red: 1, green: 1, blue: 1)
        case "SepiaTone": self.filterName = "CISepiaTone"
        default: self.filterName = nil
        }
    }
}
