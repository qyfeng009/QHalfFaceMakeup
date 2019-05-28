//
//  ViewController.swift
//  QHalfFaceMakeup
//
//  Created by 009 on 2018/2/2.
//  Copyright © 2018年 qyfeng. All rights reserved.
//

import UIKit

class TableView: UITableView, UITableViewDataSource, UITableViewDelegate {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .plain)
        delegate = self
        dataSource = self
        register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(format: "第 %d 个", indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickBtn(_ sender: Any) {
        let tbv = TableView(frame: self.view.frame, style: .plain)
        let halfFace = QHalfFaceMakeup(self, tbv)
        halfFace.adjustOS = 200
        halfFace.show()
    }

}

