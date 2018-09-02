//
//  ViewController.swift
//  BookScaner
//
//  Created by 徐炜楠 on 2018/5/11.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate,
UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var scanRectView:UIView!
    var device:AVCaptureDevice!
    var input:AVCaptureDeviceInput!
    var output:AVCaptureMetadataOutput!
    var session:AVCaptureSession!
    var preview:AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fromPhotoBtn = UIBarButtonItem(title: "输入", style: .plain, target: self, action: #selector(fromPhoto))
        self.navigationItem.rightBarButtonItem = fromPhotoBtn
        self.navigationController?.navigationBar.isTranslucent = false
        fromCamera()
    }
    override func viewDidAppear(_ animated: Bool) {
        //开始捕获
        self.session.startRunning()
    }
    @objc func fromPhoto(){
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = .photoLibrary
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            let alert = UIAlertController(title: "错误", message: "读取相册错误，请检查权限", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //获取选择的原图
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //二维码读取
        let ciImage:CIImage=CIImage(image:image)!
        let context = CIContext(options: nil)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context,
                                  options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        if let features = detector?.features(in: ciImage) {
            print("扫描到二维码个数：\(features.count)")
            //遍历所有的二维码，并框出
            for feature in features as! [CIQRCodeFeature] {
                print(feature.messageString ?? "")
            }
            if features.count != 0{
                //判断是否是小课表二维码
                let codeInfo = ((features as! [CIQRCodeFeature]).first?.messageString)!
                let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "ResultVC") as! ResultVC
                resultVC.codeInfo = codeInfo
                self.navigationController?.pushViewController(resultVC, animated: true)
            }else{
                alert(error: "未找到二维码", message: "请更换更加清晰的图片")
            }
        }
        
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
        })
    }
    //通过摄像头扫描
    func fromCamera() {
        do{
            self.device = AVCaptureDevice.default(for: AVMediaType.video)
            
            self.input = try AVCaptureDeviceInput(device: device)
            
            self.output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            self.session = AVCaptureSession()
            if UIScreen.main.bounds.size.height<500 {
                self.session.sessionPreset = AVCaptureSession.Preset.vga640x480
            }else{
                self.session.sessionPreset = AVCaptureSession.Preset.high
            }
            
            self.session.addInput(self.input)
            self.session.addOutput(self.output)
            
            self.output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            self.output.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13,
                                               AVMetadataObject.ObjectType.ean8,AVMetadataObject.ObjectType.code128,
                                               AVMetadataObject.ObjectType.code39,AVMetadataObject.ObjectType.code93]
            
            //计算中间可探测区域
            let windowSize = UIScreen.main.bounds.size
            let scanSize = CGSize(width:windowSize.width/2<200 ? 200 : windowSize.width/2, height:windowSize.width/2<200 ? 200 : windowSize.width/2)
            var scanRect = CGRect(x:(windowSize.width-scanSize.width)/2,
                                  y:(windowSize.height-64-scanSize.height)*(1-0.618),
                                  width:scanSize.width, height:scanSize.height)
            //计算rectOfInterest 注意x,y交换位置
            scanRect = CGRect(x:scanRect.origin.y/windowSize.height,
                              y:scanRect.origin.x/windowSize.width,
                              width:scanRect.size.height/windowSize.height,
                              height:scanRect.size.width/windowSize.width);
            //设置可探测区域
            self.output.rectOfInterest = scanRect
            
            self.preview = AVCaptureVideoPreviewLayer(session:self.session)
            self.preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.preview.frame = UIScreen.main.bounds
            self.view.layer.insertSublayer(self.preview, at:0)
            
            //添加周围的暗影
            let totalView = UIView(frame: CGRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height-64))
            let upView = UIView()
            upView.frame = CGRect(x: 0, y: 0, width: windowSize.width, height: (windowSize.height-64-scanSize.height)*(1-0.618)+1)
            upView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            totalView.addSubview(upView)
            let downView = UIView()
            downView.frame = CGRect(x: 0, y: (windowSize.height-64-scanSize.height)*(1-0.618)+scanSize.height-1, width: windowSize.width, height: windowSize.height-64-scanRect.origin.y-scanSize.height+1)
            downView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            totalView.addSubview(downView)
            let leftView = UIView()
            leftView.frame = CGRect(x: 0, y: (windowSize.height-64-scanSize.height)*(1-0.618), width: windowSize.width/2-scanSize.width/2+1, height: scanSize.height)
            leftView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            totalView.addSubview(leftView)
            let rightView = UIView()
            rightView.frame = CGRect(x: windowSize.width/2+scanSize.width/2-1, y: (windowSize.height-64-scanSize.height)*(1-0.618), width: windowSize.width/2-scanSize.width/2+1, height: scanSize.height)
            rightView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            totalView.addSubview(rightView)
            
            totalView.alpha = 0.7
            self.view.addSubview(totalView)
            
            //添加中间的探测区域蓝框
            self.scanRectView = UIView();
            self.view.addSubview(self.scanRectView)
            self.scanRectView.frame = CGRect(x:(windowSize.width-scanSize.width)/2,
                                             y:(windowSize.height-64-scanSize.height)*(1-0.618),
                                             width:scanSize.width, height:scanSize.height)
            self.scanRectView.layer.borderColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 1.0).cgColor
            self.scanRectView.layer.borderWidth = 2
            self.scanRectView.layer.cornerRadius = 4
            
            //添加中间的条形码
            let barCode = UIImageView(image: UIImage(named: "条形码"))
            barCode.frame = CGRect(x: 0, y: 0, width: scanSize.height*123/200, height: scanSize.height*60/200)
            barCode.center = CGPoint(x: windowSize.width/2, y: (windowSize.height-64-scanSize.height)*(1-0.618)+scanSize.height/2)
            barCode.alpha = 0.4
            self.view.addSubview(barCode)
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat,.autoreverse], animations: {
                barCode.alpha = 0
            }, completion: nil)
            //开始捕获
            self.session.startRunning()
        }catch _ {
            //打印错误消息
            let alertController = UIAlertController(title: "提醒",
                                                    message: "请在iPhone的\"设置-隐私-相机\"选项中,允许本程序访问您的相机",
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //摄像头捕获
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        var stringValue:String?
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            stringValue = metadataObject.stringValue
            
            if stringValue != nil{
                self.session.stopRunning()
            }
        }
        self.session.stopRunning()
        
        let codeInfo = stringValue!
        let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "ResultVC") as! ResultVC
        resultVC.codeInfo = codeInfo
        self.navigationController?.pushViewController(resultVC, animated: true)
        /*
        if codeInfo.contains("小课表"){
            //执行方法
            //analysingCodeAlert(codeInfo: codeInfo)
        }else{
            //输出结果
            let alertController = UIAlertController(title: "错误",
                                                    message: "错误的二维码\n\(codeInfo)",preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default, handler: {
                action in
                //继续扫描
                self.session.startRunning()
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func alert(error:String,message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
