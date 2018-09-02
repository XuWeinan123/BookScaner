//
//  BookListCell.swift
//  BookScaner
//
//  Created by 徐炜楠 on 2018/5/11.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit

class BookListCell: UITableViewCell {

    @IBOutlet var bookPic: UIImageView!
    @IBOutlet var bookName: UILabel!
    @IBOutlet var bookAuthorPublisher: UILabel!
    @IBOutlet var bookISBN: UILabel!
    @IBOutlet var cellBackgroud: UIView!
    
    var picStr = ""
    var bookNameStr = ""
    var bookAuthorPublisherStr = ""
    var bookISBNStr = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        //优化圆角
        cellBackgroud.layer.cornerRadius = 10.0
        bookPic.layer.cornerRadius = 3.0
        bookPic.imageFromURL(picStr, placeholder: UIImage(named: "默认图片")!)
        bookName.text = bookNameStr
        bookAuthorPublisher.text = bookAuthorPublisherStr
        bookISBN.text = bookISBNStr
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
