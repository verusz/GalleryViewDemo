//
//  ViewController.swift
//  GalleryViewDemo
//
//  Created by 朱继卿 on 2017/12/26.
//  Copyright © 2017年 朱继卿. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

func / (lhs: CGFloat, rhs: Int) -> CGFloat {return lhs / CGFloat(rhs)}
func * (lhs: Int, rhs: CGFloat) -> CGFloat {return CGFloat(lhs) * rhs}


class ViewController: UIViewController {
    
    var screenSize: CGSize { return UIScreen.main.bounds.size }

    var picturesViewHeight: CGFloat = 300
    fileprivate let disposeBag = DisposeBag()
//    let mainTableView = UITableView()
    
    lazy var picturesView: GalleryView = { //初始化
        let layout = GalleryViewLayout(3, 5) //（行数，列数）
        let view = GalleryView.loadNibView(galleryLayout: layout)
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 5
        view.frame = CGRect(x: 15, y: 64, width: screenSize.width - 30, height: ((self.screenSize.width - 30) / layout.columnNum) + 5)
        (view.rx.observe(Int.self, "currentLine")).skip(1).subscribe(onNext: { [weak self] (currentLine) in
            guard let weakSelf = self else { return }
            //监听是否需要改变pictureView的高度
            let cellHeight = ((weakSelf.screenSize.width - 30) / layout.columnNum) + 5
            if  (weakSelf.picturesViewHeight != currentLine! * cellHeight) && (currentLine! <= layout.lineNum) {
                weakSelf.picturesViewHeight = currentLine! * cellHeight
                view.frame = CGRect(x: 15, y: 64, width: weakSelf.screenSize.width - 30, height: weakSelf.picturesViewHeight)
//                UIView.performWithoutAnimation {
//                    weakSelf.mainTableView.reloadSections(IndexSet.init(integer: 2), with: .automatic) //重新加载上传图片部分
//                }
            }
        }).disposed(by: disposeBag)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
//        mainTableView.frame = CGRect(x: 15, y: 0, wi .dth: screenWidth - 30,height: screenHeight)
        self.view.addSubview(picturesView)
//        mainTableView.dataSource = self
//        mainTableView.delegate = self
//        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
//        cell?.addSubview(picturesView)
//        return cell!
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return picturesViewHeight
//    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

