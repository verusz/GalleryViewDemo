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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height

    var picturesViewHeight: CGFloat = 74.0
    fileprivate let disposeBag = DisposeBag()
    let mainTableView = UITableView()
    
    lazy var picturesView: ComplaintGalleryView = { //初始化上传凭证部分
        let view = ComplaintGalleryView.loadNibView()
        view.frame = CGRect(x: 15, y: 0, width: screenWidth - 30, height: screenHeight)
        (view.rx.observe(Bool.self, "moreThanFivePics")).skip(1).subscribe(onNext: { [weak self] (_) in
            //监听是否需要改变pictureView的高度
            let previousHeight = self?.picturesViewHeight
            self?.picturesViewHeight = view.moreThanFivePics ? 74 * 2 : 74
//            if previousHeight != self?.picturesViewHeight {
//                UIView.performWithoutAnimation {
//                    self?.mainTableView.reloadData() //重新加载上传图片部分
//                }
//            }
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.addSubview(picturesView)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return picturesViewHeight
    }
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

