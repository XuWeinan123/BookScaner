//
//  BookSheetCell.swift
//  BookScaner
//
//  Created by 徐炜楠 on 2018/5/18.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit

class BookSheetCell: UICollectionViewCell {
    @IBOutlet var bookPic1: UIImageView!
    @IBOutlet var bookPic2: UIImageView!
    @IBOutlet var bookPic3: UIImageView!
    @IBOutlet var bookPic4: UIImageView!
    @IBOutlet var bookPic5: UIImageView!
    override func awakeFromNib() {
        bookPic1.layer.cornerRadius = 3
        bookPic2.layer.cornerRadius = 3
        bookPic3.layer.cornerRadius = 3
        bookPic4.layer.cornerRadius = 3
        bookPic5.layer.cornerRadius = 3
    }
}
