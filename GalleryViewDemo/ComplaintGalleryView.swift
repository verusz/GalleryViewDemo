//
//  ComplaintGallaryView.swift
//  Tuhu
//
//  Created by 朱继卿 on 2017/12/8.
//  Copyright © 2017年 Tuhu. All rights reserved.
//

import UIKit
import TZImagePickerController

class ComplaintGalleryView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    var showPhotoSelectionHandler: ((Bool, String) -> Void)?
    
    let screenWidth = UIScreen.main.bounds.size.width

    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate var imagesArray: [UIImage] = Array()

    fileprivate let kCellReuseIdentifier = "GalleryCollectionViewCell"

    lazy var controller: UIViewController = {
        return UIViewController.currentViewController()
        }()!

    @objc dynamic var moreThanFivePics = false

    fileprivate let actionSheet: UIAlertController = UIAlertController(title: "", message: "您还可以上传10张照片", preferredStyle: .actionSheet)

    //Mark:Public Method
    class func loadNibView() -> ComplaintGalleryView {
        if let nibView = Bundle.main.loadNibNamed("ComplaintGalleryView", owner: self, options: nil)?.first as? ComplaintGalleryView {
            nibView.initialize()
            return nibView
        } else {
            return ComplaintGalleryView()
        }
    }

    func photos() -> [UIImage] {
        return imagesArray
    }

    //Mark:Private Method
    fileprivate func initialize() {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: (screenWidth - 30) / 5.0, height: (screenWidth - 30) / 5.0)
        layout.minimumLineSpacing = CGFloat.leastNormalMagnitude
        layout.minimumInteritemSpacing = CGFloat.leastNormalMagnitude

        collectionView.register(UINib(nibName: kCellReuseIdentifier, bundle: Bundle.main), forCellWithReuseIdentifier: kCellReuseIdentifier)
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self

        showPhotoSelectionHandler = { [weak self] condition, text in
            // 处理选择以及拍摄照片事件,同时判断如果有已有照片是否需要继续展示
            if condition && ((self?.imagesArray.count)! > 0) {
                return
            }
            if text.count > 0 {
                self?.actionSheet.message = text
            } else {
                self?.actionSheet.message = "您还可以上传\(10 - (self?.imagesArray.count)!)张照片"
            }
            self?.controller.present((self?.actionSheet)!, animated: true, completion: nil)
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
        return imagesArray.count == 10 ? imagesArray.count : imagesArray.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellReuseIdentifier, for: indexPath) as! GalleryCollectionViewCell
        if indexPath.row == imagesArray.count && imagesArray.count < 10 { //判断是否存在添加图片按钮
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
            if indexPath.row == 9 {//满足第10个图片为添加按钮
                cell.removeFromSuperview()//删除最后一个cell
            }

        }
    }

    fileprivate func reload(_ images: [UIImage] = Array()) {
        if images.count > 0 {
            imagesArray.append(contentsOf: images)
        }
        moreThanFivePics = imagesArray.count < 5 ? false : true
        collectionView.reloadData()
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

extension ComplaintGalleryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate { //打开照相机

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

extension ComplaintGalleryView: TZImagePickerControllerDelegate { //打开相册

    fileprivate func showImageBroswer() {
        let tzImagePicker = TZImagePickerController(maxImagesCount: 10 - imagesArray.count, delegate: self)!
        tzImagePicker.isSelectOriginalPhoto = true
        tzImagePicker.autoDismiss = false
        tzImagePicker.navigationBar.isTranslucent = false
//        tzImagePicker.navigationBar.barTintColor =  AppThemeConstant.defaultNavigationBarTintColor
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
