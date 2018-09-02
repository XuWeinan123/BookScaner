//
//  ResultVC.swift
//  BookScaner
//
//  Created by 徐炜楠 on 2018/5/11.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyXMLParser
import AVOSCloud

class ResultVC: UIViewController {
    var codeInfo = ""

    @IBOutlet var bookPic: UIImageView!
    @IBOutlet var bookName: UILabel!
    @IBOutlet var bookAuthor: UILabel!
    @IBOutlet var bookPrice: UILabel!
    @IBOutlet var bookBio: UITextView!
    @IBOutlet var addButton: UIButton!
    
    var bookTitle:String?
    var author = "暂无作者"
    var summary = "暂无简介"
    var pages = "N/A"
    var price = "暂无价格"
    var publisher = "暂无出版商"
    var binding = "无包装"
    var pubdate = "无日期"
    var pic = "https://ws2.sinaimg.cn/large/006tKfTcgy1fr7iiksgggj30a90e8dhg.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = codeInfo
        addButton.layer.cornerRadius = 4.0
        bookBio.layer.cornerRadius = 4.0
        print(codeInfo)
        Alamofire.request("http://api.douban.com/book/subject/isbn/\(codeInfo)").response { (response) in
            if let data = response.data{
                let xml = XML.parse(data)
                var xmlItems = xml["entry"].all
                guard xmlItems != nil else {
                    self.noticeInfo("查询失败", autoClear: true, autoClearTime: 3)
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                var string = xmlItems?.count
                self.bookTitle = xmlItems?.first?.childElements[1].text
                //判断作者
                var authorNode = xml["entry","author"].all?.first
                if let authorNode = authorNode{
                    self.author = authorNode.childElements[0].text!
                }
                var picNodes = xml["entry","link"].all
                if let picNodes = picNodes{
                    self.pic = picNodes[2].attributes["href"]!
                }
                var summaryNode = xml["entry","summary"].all?.first
                if let summaryNode = summaryNode{
                    self.summary = summaryNode.text!
                }
                var attributeNodes = xml["entry","db:attribute"].all
                print(attributeNodes?.count)
                for node in attributeNodes!{
                    if node.attributes["name"] == "pages"{
                        self.pages = node.text!
                    }else if node.attributes["name"] == "price"{
                        self.price = node.text!
                    }else if node.attributes["name"] == "publisher"{
                        self.publisher = node.text!
                    }else if node.attributes["name"] == "binding"{
                        self.binding = node.text!
                    }else if node.attributes["name"] == "puddate"{
                        self.pubdate = node.text!
                    }
                }
                
                print(self.bookTitle)
                print(self.author)
                print(self.pic)
                print(self.summary)
                print(self.pages)
                print(self.price)
                print(self.publisher)
                print(self.binding)
                print(self.pubdate)
                
                self.bookName.text = self.bookTitle
                self.bookPrice.text = self.price
                self.bookAuthor.text = self.author
                self.bookBio.text = self.summary
                self.bookPic.imageFromURL(self.pic, placeholder: UIImage(named: "默认图片")!)
                
                self.addButton.isEnabled = true
            }
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func addAction(_ sender: UIButton) {
        self.pleaseWait()
        let tempObject = AVObject(className: "BookInfo")
        tempObject["bookTitle"] = bookTitle
        tempObject["author"] = author
        tempObject["summary"] = summary
        tempObject["pages"] = pages
        tempObject["price"] = price
        tempObject["publisher"] = publisher
        tempObject["binding"] = binding
        tempObject["pubdate"] = pubdate
        tempObject["pic"] = pic
        tempObject.saveInBackground { (success, error) in
            if success{
                print("上传成功")
                self.navigationController?.popViewController(animated: true)
                self.clearAllNotice()
                self.noticeInfo("添加成功", autoClear: true, autoClearTime: 3)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.bookBio.setContentOffset(CGPoint.zero, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
