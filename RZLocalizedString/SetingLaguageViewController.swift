//
//  SetingLaguageViewController.swift
//  RZLocalizedString
//
//  Created by rztime on 2022/5/17.
//

import UIKit

class SetingLaguageViewController: UIViewController {

    var switchBtn: UISwitch = .init()
    
    var customBtn: UIButton = .init(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        let label = UILabel()
        label.text = "跟随系统"
        
        let label1 = UILabel()
        label1.text = "自定义"
        
        self.view.addSubview(label)
        self.view.addSubview(label1)
        self.view.addSubview(switchBtn)
        self.view.addSubview(customBtn)
        
        label.frame = .init(x: 30, y: 200, width: 100, height: 44)
        label1.frame = .init(x: 30, y: 300, width: 100, height: 44)
        switchBtn.frame = .init(x: 230, y: 200, width: 100, height: 44)
        customBtn.frame = .init(x: 230, y: 300, width: 100, height: 44)
        customBtn.backgroundColor = .red
        customBtn.setTitleColor(.white, for: .normal)
        update()
        
        switchBtn.addTarget(self, action: #selector(switchAction), for: .valueChanged)
        customBtn.addTarget(self, action: #selector(customAction), for: .touchUpInside)
    }
    
    @objc func switchAction() {
        /// 设置是否跟随系统
        RZLocalizedString.shared.followSystem = !RZLocalizedString.shared.followSystem
        update()
    }
    /// 设置自定义语言
    @objc func customAction() {
        let language = RZLocalizedString.shared.appLanguages
        let vc = UIAlertController.init(title: "自定义", message: nil, preferredStyle: .actionSheet)
        language.enumerated().forEach { [weak self] value in
            let action = UIAlertAction.init(title: value.element, style: .default) { [weak self] _ in
                let lg = language[value.offset]
                RZLocalizedString.shared.customLanguages = [lg]
                RZLocalizedString.shared.followSystem = false
                self?.update()
            }
            vc.addAction(action)
        }
        self.present(vc, animated: true)
    }
    func update() {
        switchBtn.isOn = RZLocalizedString.shared.followSystem
        let t = RZLocalizedString.shared.customLanguages
        customBtn.setTitle("\(t)", for: .normal)
        customBtn.isEnabled = !RZLocalizedString.shared.followSystem
        customBtn.alpha = customBtn.isEnabled ? 1 : 0.2
    }
}
