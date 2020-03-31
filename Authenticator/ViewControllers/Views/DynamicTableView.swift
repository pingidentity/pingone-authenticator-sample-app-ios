//
//  DynamicTableView.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit

class DynamicTableView: UITableView {

    let cellHeight: CGFloat = 74.0
    let footer: CGFloat = 20.0
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        let numberOfCells = CGFloat(self.numberOfRows(inSection: 0))
        return CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(numberOfCells * cellHeight) + footer)
    }

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
}
