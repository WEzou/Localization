//
//  ViewController.swift
//  Localizable
//
//  Created by youxin on 2020/2/27.
//  Copyright © 2020 youxin. All rights reserved.
//

import UIKit
import Photos

/* 国际化
 * 1. 国际化的步骤 （InfoPlist Localizable Main）
 * 2. 脚本自动化
 * 3. 应用内切换语言
 * 4. Excel转化   [https://github.com/lefex/TCZLocalizableTool]
 */

#warning("# 使用Localize前，先调用 BundleEx.onLanguage()")

class ViewController: UIViewController {
            
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(open))
        imageView.addGestureRecognizer(tap)
        
        let button = UIButton()
        let frame = CGRect(x: 0, y: 0, width: 127, height: 60)
        button.frame = frame
        button.center = self.view.center
        button.backgroundColor = .orange
        button.setTitle("Switch".localized(), for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(setLanguage), for: .touchUpInside)
        self.view.addSubview(button)
        
        let language = Bundle.main.localizedString(forKey: "Language", value: nil, table: nil)
        print("language = \(language)")
    }
    
    @objc private func open() {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    let pickerCtl = UIImagePickerController()
                    self.present(pickerCtl, animated: true) {}
                }
            })
        } else {
            
        }
    }
    
    @objc private func setLanguage() {
                
        let languages = Localize.availableLanguages()
        let index = Int.random(in: 1..<3)
        Localize.setCurrentLanguage(languages[index])
        
        let story = UIStoryboard(name: "Main", bundle: BundleEx.main)
        let viewCtrl = story.instantiateViewController(withIdentifier: "RootVC")
        DispatchQueue.main.async {
            if #available(iOS 13.0, *) {
                let windows = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
                guard windows != nil else {
                    return
                }
                windows?.rootViewController = viewCtrl
                
            } else {
                UIApplication.shared.keyWindow?.rootViewController = viewCtrl
            }
        }
    }
}

