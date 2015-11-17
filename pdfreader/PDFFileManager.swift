//
//  PDFFileManager.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/16.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit
import CoreData

class PDFFileManager: NSObject {

    let serverURL = "http://192.168.144.46:8080/bpm_wechat/bpmclient/getFileInfo.json"

    func doCheckUpdate() {
        // 检查是否有新数据

        let url = NSURL(string: serverURL)

        if let jsonData = NSData(contentsOfURL: url!) {

            do {
                let jsonObj = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())
                print(jsonObj)
            } catch {
                print("json 解析出错")
            }

        }
        else {
            print("网络通信出错")
        }
    }

}
