//
//  ViewController.swift
//  RZLocalizedString
//
//  Created by rztime on 2022/5/17.
//

import UIKit

class ViewController: UIViewController {
    let tableView = UITableView.init(frame: .zero, style: .plain)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        let local = RZLocalizedString.shared
        if local.followSystem {
            self.title = "语言跟随系统"
        } else {
            self.title = "语言自定义：\(local.customLanguages)"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        tableView.frame = self.view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = .init(title: "设置语言", style: .plain, target: self, action: #selector(settingLanguage))
    }
    @objc func settingLanguage() {
        let vc = SetingLaguageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? .init(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = RZLocalizedString.string(for: "failure")
        cell.detailTextLabel?.text = RZLocalizedString.string(for: "failure", language: "ru")
        return cell
    }
}

