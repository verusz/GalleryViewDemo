//
//  ComplaintGallaryView.swift
//  Tuhu
//
//  Created by 朱继卿 on 2017/12/8.
//  Copyright © 2017年 Tuhu. All rights reserved.
//

import UIKit
import TZImagePickerController

func + (lhs: Int, rhs: Double) -> Double {return Double(lhs) + rhs}
func / (lhs: Double, rhs: Int) -> Double {return lhs / Double(rhs)}


class GalleryViewLayout: NSObject {
    var lineNum = 2 //行数
    var columnNum = 5 //列数
    var imagesNum = 0 //总数
    
    convenience init (_ lineNum: Int, _ columnNum: Int ) {
        self.init()
        
        self.lineNum = lineNum
        self.columnNum = columnNum
        self.imagesNum = lineNum * columnNum
    }
    
    override init() {
        super.init()
    }
    
}

class GalleryView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var screenSize: CGSize { return UIScreen.main.bounds.size }
    
    var showPhotoSelectionHandler: ((Bool, String) -> Void)? // 第一个参数若为true，则在galleryView已有图片的情况下不需要自动提醒上传照片。第二个参数则为actionSheet的提示信息
    
    fileprivate var galleryLayout: GalleryViewLayout!  //galleryView的布局设置
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var imagesArray: [UIImage] = Array()
    
    fileprivate let kCellReuseIdentifier = "GalleryCollectionViewCell"
    
    lazy var controller: UIViewController = {
        return UIViewController.currentViewController()
        }()!
    
    @objc dynamic var currentLine = 1
    
    fileprivate let actionSheet: UIAlertController = UIAlertController(title: "", message: "您还可以上传10张照片", preferredStyle: .actionSheet)
    
    //MARK:Public Method
    class func loadNibView(galleryLayout layout: GalleryViewLayout) -> GalleryView {
        if let nibView = Bundle.main.loadNibNamed("GalleryView", owner: self, options: nil)?.first as? GalleryView {
            nibView.initialize(layout)
            return nibView
        } else {
            return GalleryView()
        }
    }
    
    func photos() -> [UIImage] {
        return imagesArray
    }
    
    //MARK:Private Method
    fileprivate func initialize(_ galleryLayout: GalleryViewLayout) {
        self.galleryLayout = galleryLayout
        
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: (screenSize.width - 30) / galleryLayout.columnNum, height: (screenSize.width - 30) / galleryLayout.columnNum)
        layout.minimumLineSpacing = CGFloat.leastNormalMagnitude
        layout.minimumInteritemSpacing = CGFloat.leastNormalMagnitude
        
        collectionView.register(UINib(nibName: kCellReuseIdentifier, bundle: Bundle.main), forCellWithReuseIdentifier: kCellReuseIdentifier)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        
        showPhotoSelectionHandler = { [weak self] condition, text in
            guard let weakSelf = self else {
                return
            }
            // 处理选择以及拍摄照片事件,同时判断如果有已有照片是否需要继续展示
            if condition && (weakSelf.imagesArray.count > 0) {
                return
            }
            if text.count > 0 {
                weakSelf.actionSheet.message = text
            } else {
                weakSelf.actionSheet.message = "您还可以上传\(weakSelf.galleryLayout.imagesNum - weakSelf.imagesArray.count)张照片"
            }
            weakSelf.controller.present(weakSelf.actionSheet, animated: true, completion: nil)
        }
        
        initActionSheet()
    }
    
    fileprivate func initActionSheet() {
        let imageLibraryAction = UIAlertAction.init(title: "打开相册", style: .`default`) { [weak self] (_) in
            self?.showImageBroswer()
        }
        
        let takePhotoAction = UIAlertAction.init(title: "照相机", style: .`default`) { [weak self] (_) in
            self?.initPickController()
        }
        actionSheet.addAction(imageLibraryAction)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count == galleryLayout.imagesNum ? imagesArray.count : imagesArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseIdentifier, for: indexPath) as! GalleryCollectionViewCell
        if indexPath.row == imagesArray.count && imagesArray.count < galleryLayout.imagesNum { //判断是否存在添加图片按钮
            cell.couldAddPic = true
        } else {
            cell.couldAddPic = false
        }
        if cell.couldAddPic {
            return cell
        }
        cell.imageView.image = imagesArray[indexPath.row]
        cell.deleteAction = { [weak self] in
            self?.imagesArray.remove(at: indexPath.row)
            self?.reload()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GalleryCollectionViewCell
        if cell.couldAddPic {
            showPhotoSelectionHandler!(false, "")
            if indexPath.row == galleryLayout.imagesNum - 1 {//满足第10个图片为添加按钮
                cell.removeFromSuperview()//删除最后一个cell
            }
        }
    }
    
    fileprivate func reload(_ images: [UIImage] = Array()) {
        //        let lastLine = ceil(Double(images.count) / galleryLayout.columnNum)
        if images.count > 0 {
            imagesArray.append(contentsOf: images)
        }
        currentLine = Int(ceil((imagesArray.count + 1.0) / galleryLayout.columnNum))
        
        //        needAddLine = currentLine > lastLine //需要添加行数的判断条件
        //        needReduceLine = currentLine < lastLine //需要减少行数的判断条件
        collectionView.reloadData()
    }
}

extension GalleryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate { //打开照相机
    
    fileprivate func initPickController() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerImage = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                pickerImage.sourceType = .camera
                pickerImage.mediaTypes = UIImagePickerController.availableMediaTypes(for: pickerImage.sourceType)!
            }
            pickerImage.delegate = self
            pickerImage.allowsEditing = false
            controller.present(pickerImage, animated: true, completion: nil)
        } else {
            print("未找到拍照设备")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
        // 返回图片
        self.reload([image])
    }
}

extension GalleryView: TZImagePickerControllerDelegate { //打开相册
    fileprivate func showImageBroswer() {
        let tzImagePicker = TZImagePickerController(maxImagesCount: galleryLayout.imagesNum - imagesArray.count, delegate: self)!
        tzImagePicker.isSelectOriginalPhoto = true
        tzImagePicker.autoDismiss = false
        tzImagePicker.navigationBar.isTranslucent = false
        tzImagePicker.navigationBar.barTintColor = UIColor(223, 51, 72)
        controller.present(tzImagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        self.reload(photos)
        picker.dismiss(animated: true)
    }
    
    func tz_imagePickerControllerDidCancel(_ picker: TZImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


extension UIViewController {
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return currentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
}
