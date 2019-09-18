//
//  FEPhotoOverViewPullUpView.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/8/10.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

class FETableView: UITableView {
    var minInsert : CGFloat = 99999.0
}

extension FETableView: UIGestureRecognizerDelegate {
    
    

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if (otherGestureRecognizer is FEPhotoPanGestureRecognizer) {
//            return true
//        }
        return false
    }
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        if (gestureRecognizer.view is FETableView) {
//            return true
//        }
//        return false
//    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if (gestureRecognizer.view is FETableView) {
//            return true
//        }
//        print(self.contentOffset.y)
//        print(gestureRecognizer.location(in: self).y)
        if (gestureRecognizer.location(in: self).y < 0) {
            return false
        }
        return true
    }
}

class FEPhotoOverViewPullUpView: UIView,UITableViewDelegate,UITableViewDataSource {
    

    var tableView = FETableView() {
        didSet{
           
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tableView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        self.addSubview(self.tableView)
        self.tableView.backgroundColor = UIColor.red
    }
    override var frame: CGRect {
        didSet {
            self.tableView.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height)
        }
    }
    
    func changeContenInsert(insert:CGFloat) {
        self.tableView.contentInset = UIEdgeInsets.init(top: insert, left: 0, bottom: 0, right: 0)
        self.tableView.contentOffset.y = -insert
        if self.tableView.minInsert >= -insert {
            self.tableView.minInsert = -insert
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "1")
        cell.textLabel?.text = String.init(format: "%d", indexPath.row)
        return cell
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
