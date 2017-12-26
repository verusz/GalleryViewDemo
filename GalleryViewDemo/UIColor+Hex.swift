//
//  UIColor + Hex.swift
//  GalleryViewDemo
//
//  Created by 朱继卿 on 2017/12/26.
//  Copyright © 2017年 朱继卿. All rights reserved.
//

import UIKit
 extension UIColor {
        /**
         通过色值创建UIColor对象， alpha 值默认为 1
         
         - parameter hex: 色值数字，通常用十六进制数字表示  例如  0xFFFFFF
         
         - returns: 对应色值的UIColor对象
         */
        convenience init(hex: UInt32) {
            self.init(hex: hex, alpha: 1)
        }
        /**
         通过色值创建UIColor对象
         
         - parameter hex: 色值数字，通常用十六进制数字表示  例如  0xFFFFFF
         - parameter alpha:     颜色透明度
         
         - returns: 对应色值的UIColor对象
         */
        convenience init(hex: UInt32, alpha: CGFloat) {
            self.init(red: CGFloat((hex & 0xFF0000) >> 16)/255, green: CGFloat((hex & 0x00FF00) >> 8)/255, blue: CGFloat(hex & 0x0000FF)/255, alpha: alpha)
        }
        
        /**
         通过色值创建UIColor对象， alpha 值默认为 1
         
         - parameter hexString: 色值字符串，十六进制数字字符串表示  支持#前缀
         
         - returns: 对应色值的UIColor对象
         */
//        convenience init(hexString: String) {
//            self.init(hexString: hexString, alpha: 1)
//        }
    
        /**
         通过色值创建UIColor对象， alpha 值默认为 1
         
         - parameter hexString: 色值字符串，十六进制数字字符串表示  支持#前缀
         - parameter alpha:     颜色透明度
         
         - returns: 对应色值的UIColor对象
         */
//        convenience init(hexString: String, alpha: CGFloat) {
//            var temp = hexString.uppercased()
//            if temp.hasPrefix("#") {
//                temp = temp.replacingOccurrences(of: "#", with: "")
//            }
//            
//            switch temp.count {
//            case 6:
//                self.init(hex: UInt32(hexString.hexInteger), alpha: alpha)
//            case 3:
//                self.init(hex3: hexString.hexInteger, alpha: alpha)
//            default:
//                self.init(hex: 0x000000)
//            }
//        }
        
        private convenience init(hex3 hex: Int, alpha: CGFloat) {
            func duplicate4bits(_ i: Int) -> Int {
                return (i << 4) + i
            }
            self.init(red: CGFloat(duplicate4bits((hex & 0xF00) >> 8))/255,
                      green: CGFloat(duplicate4bits((hex & 0x0F0) >> 4))/255,
                      blue: CGFloat(duplicate4bits(hex & 0x00F))/255,
                      alpha: alpha)
        }
        
        /**
         通过RGB值创建UIColor对象，参数为Int型，取值范围0-255，alpha 值默认为 1
         
         - parameter r: 红色 0-255
         - parameter g: 绿色 0-255
         - parameter b: 蓝色 0-255
         
         - returns: 对应RGB值的UIColor对象
         */
        convenience init(_ r: Int, _ g: Int, _ b: Int) {
            self.init(r, g, b, 1.0)
        }
        
        /**
         通过RGB值创建UIColor对象，参数为Int型，取值范围0-255，alpha 值默认为 1
         
         - parameter r: 红色 0-255
         - parameter g: 绿色 0-255
         - parameter b: 蓝色 0-255
         - parameter a: 颜色透明度
         
         - returns: 对应RGB值的UIColor对象
         */
        convenience init(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat) {
            self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: a)
        }
}
