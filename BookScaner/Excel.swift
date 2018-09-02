//
//  Excel.swift
//  SwiftExcel
//
//  Created by yuzhengkai on 2017/7/30.
//  Copyright © 2017年 yuzhengkai. All rights reserved.
//

import UIKit


class Excel: NSObject {
    
    fileprivate var line:Int!
    fileprivate var column:Int!
    fileprivate var exceldatas = [String]()
    fileprivate var excelStr = String()
    
    init(line:Int,heads:[String]) {
        
        self.line = line
        self.column = heads.count
        exceldatas = exceldatas + heads
    }
    
    func createExcel(lineDatas:[String]) -> String {
        
        exceldatas = exceldatas + lineDatas
        for (index,str) in exceldatas.enumerated() {
            
            if column == 1 {
                
                excelStr = excelStr + str + "\n"
                
            } else {
                
                if (index+1) % column == 0 && index+1 > 1 {
                    
                    excelStr = excelStr + str + "\n"
                    
                } else {
                    
                    excelStr = excelStr + str + "\t"
                }
            }
        }
        
        //print(excelStr)
        let fileManager = FileManager()
        let fileData = excelStr.data(using: .utf16)
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentstring = paths[0]
        let plistPath = documentstring.appending("/export.xls")
        fileManager.createFile(atPath: plistPath, contents: fileData, attributes: nil)
        //print("文件路径:\(plistPath)")
        
        return plistPath
    }
    
}

