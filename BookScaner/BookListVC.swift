//
//  BookListVC.swift
//  BookScaner
//
//  Created by 徐炜楠 on 2018/5/11.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import AVOSCloud

class BookListVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet var tableView: UITableView!
    let headTitle = ["图书名称","作者","出版商","出版日期","简介","包装信息","售价","封面"]
    var path = ""
    var objects:[Any]? = []
    var documentController:UIDocumentInteractionController!
    @IBOutlet var shareActionBtn: UIBarButtonItem!
    @IBOutlet var bookSheets: UIView!
    @IBOutlet var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var bookSheetTopConstraint: NSLayoutConstraint!
    @IBOutlet var bookSheetCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        bookSheetCollectionView.delegate = self
        bookSheetCollectionView.dataSource = self
        
        //初始化文档分享器
        let manager = FileManager.default
        let urlForDocument = manager.urls(for: .documentDirectory, in:.userDomainMask)
        let url = urlForDocument[0] as URL
        documentController = UIDocumentInteractionController(url:URL(fileURLWithPath: "\(url)export.xls"))
        documentController.delegate = self;
        // Do any additional setup after loading the view.
        let query = AVQuery(className: "BookInfo")
        query.findObjectsInBackground { (objects, error) in
            if error == nil{
                self.objects = objects
                print("\(self.objects?.count)书")
                self.tableView.reloadData()
                self.shareActionBtn.isEnabled = true
            }
        }
    }
    @IBAction func clearAllItem(_ sender: UIBarButtonItem) {
        let query = AVQuery(className: "BookInfo")
        query.deleteAllInBackground { (success, error) in
            if success {
                print("删除成功")
                self.objects = []
                self.tableView.reloadData()
                self.navigationController?.popViewController(animated: true)
            }else{
                self.noticeError("删除失败\n\(error!)", autoClear: true, autoClearTime: 2)
            }
        }
        
        
    }
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        //生成文件
        let excelFile = Excel(line: headTitle.count, heads: headTitle)
        var tempStr = [String]()
        for object in objects! {
            tempStr.append((object as AnyObject).value(forKey: "bookTitle") as! String)
            tempStr.append((object as AnyObject).value(forKey: "author") as! String)
            tempStr.append((object as AnyObject).value(forKey: "publisher") as! String)
            tempStr.append((object as AnyObject).value(forKey: "pubdate") as! String)
            var summary = (object as AnyObject).value(forKey: "summary") as! String
            tempStr.append(summary.replacingOccurrences(of: "\n", with: "_"))
            tempStr.append((object as AnyObject).value(forKey: "binding") as! String)
            tempStr.append((object as AnyObject).value(forKey: "price") as! String)
            tempStr.append((object as AnyObject).value(forKey: "pic") as! String)
        }
        path = excelFile.createExcel(lineDatas: tempStr)
        print("文档存储路径:\(path)")
        
        documentController.presentOptionsMenu(from: self.navigationItem.rightBarButtonItem!, animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (objects?.count)!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! BookListCell
        cell.picStr = (objects![indexPath.row] as AnyObject).value(forKey: "pic") as! String
        //print("打印出来吧\(cell.picStr)")
        cell.bookNameStr = (objects![indexPath.row] as AnyObject).value(forKey: "bookTitle") as! String
        cell.bookISBNStr = ""
        let author = (objects![indexPath.row] as AnyObject).value(forKey: "author") as! String
        let publisher = (objects![indexPath.row] as AnyObject).value(forKey: "publisher") as! String
        cell.bookAuthorPublisherStr = "\(author)\n\(publisher)"
        cell.awakeFromNib()
        //cell.cellBackgroud.backgroundColor = UIColor(red: 251.0/255.0, green: 210.0/255.0, blue: 107.0/255.0, alpha: 1)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let title = (objects![indexPath.row] as AnyObject).value(forKey: "bookTitle") as! String
        self.noticeInfo("书名 已复制", autoClear: true, autoClearTime: 1)
        UIPasteboard.general.string = title
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.orange
        view.alpha = 0.0
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if bookSheets.tag == 0{
            return 4
        }else{
            return 124
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if bookSheets.tag == 0{
            bookSheetTopConstraint.constant = -120 - scrollView.contentOffset.y
            if scrollView.contentOffset.y <= -120{
                bookSheetTopConstraint.constant = 0
                bookSheets.tag = 1
                self.tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
            }
        }else{
            if scrollView.contentOffset.y > 0{
                bookSheetTopConstraint.constant = -scrollView.contentOffset.y
                if scrollView.contentOffset.y > 60{
                    bookSheetTopConstraint.constant = -120
                    bookSheets.tag = 0
                    self.tableView.reloadData()
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
                }
            }
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BookSheetCell
        return cell
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
