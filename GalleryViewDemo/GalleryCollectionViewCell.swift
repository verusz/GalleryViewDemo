//
//  galleryCollectionViewCell.swift
//  Tuhu
//
//  Created by 朱继卿 on 2017/12/8.
//  Copyright © 2017年 Tuhu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GalleryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    fileprivate var disposeBag = DisposeBag()

    var deleteAction: (() -> Void)?
    
    var couldAddPic: Bool! {
        didSet {
            if couldAddPic {
                self.imageView.image = UIImage(named: "aftersale_camera")
                 imageView.layer.borderWidth = 0
                deleteButton.isHidden = true
            } else {
                deleteButton.isHidden = false
                imageView.layer.borderWidth = 0.5
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.borderColor = UIColor(hex: 0xe6e6e6).cgColor
        imageView.layer.borderWidth = 0.5
        
        deleteButton.rx.tap.subscribe(onNext: { [weak self] in
            guard (self?.deleteAction) != nil else {
                return
            }
            self?.deleteAction!()
        }).disposed(by: disposeBag)
    }

}
