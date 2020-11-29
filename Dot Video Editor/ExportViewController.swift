//
//  ExportViewController.swift
//  Dot Video Editor
//
//  Created by RX on 6/6/20.
//  Copyright © 2020 RX. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController {

    @IBOutlet weak var resolutionSegment: UISegmentedControl!
    @IBOutlet weak var fpsSegment: UISegmentedControl!
    @IBOutlet weak var loadingView: UIView!

    var createModel: CreateModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resolutionSegment.selectedSegmentIndex = 2
        fpsSegment.selectedSegmentIndex = 2
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func saveVideo(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {

    }

    
    // MARK: - IBActions
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: Any) {
        
        if let model = createModel {
            loadingView.isHidden = false

            let resolution: ResolutionType = ResolutionType(rawValue: resolutionSegment.selectedSegmentIndex + 1) ?? ResolutionType.SeventyTwo
            let fps: FramesType = FramesType(rawValue: fpsSegment.selectedSegmentIndex + 1) ?? FramesType.Thirty

            model.export(resolutionType: resolution, fpsType: fps) { (url, error) in
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                    if let path = url?.path {
                        print(path)
                        UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(self.saveVideo(_:didFinishSavingWithError:contextInfo:)), nil)
                    }
                }
            }
        }
    }
}
