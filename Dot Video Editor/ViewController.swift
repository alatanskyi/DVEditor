//
//  ViewController.swift
//  Dot Video Editor
//
//  Created by RX on 4/21/20.
//  Copyright © 2020 RX. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos

class ViewController: UIViewController {

    var createModel = CreateModel(segmentCount: 3)
    
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    lazy var videoPlayer: AVPlayer = AVPlayer()
    var playerItem: AVPlayerItem?
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var labelVersion: UILabel!
    @IBOutlet weak var loadingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initPlayer()
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
        labelVersion.text = version + " - " + build!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        replayPlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        releasePlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer.frame = videoView.bounds
    }
    
    
    // MARK: - Private functions
    
    func initPlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            // report for an error
            print(error)
        }
        
        playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        
        buttonPlay.alpha = 0.3
    }
    
    func releasePlayer() {
        videoPlayer.pause()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func replayPlayer() {
        if playerItem != nil {
            playVideo()
        }
    }
    
    func playVideo() {
        playerItem = createModel.playerItem()
        videoPlayer.replaceCurrentItem(with: playerItem)
        videoPlayer.volume = 1.0
        videoPlayer.play()
        
        buttonPlay.setImage(UIImage(named: "pause"), for: .normal)
        UIView.animate(withDuration: 0.5, animations: {
            self.buttonPlay.alpha = 1.0
        }) { (finished) in
            UIView.animate(withDuration: 0.5) {
                self.buttonPlay.alpha = 0.3
            }
        }
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(playerItemDidReachEnd(notification:)),
        name: .AVPlayerItemDidPlayToEndTime,
        object: playerItem)
    }
    
    func importVideo() {
        let videoPickerController = UIImagePickerController()
        videoPickerController.delegate = self
        videoPickerController.transitioningDelegate = self
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false { return }
        videoPickerController.sourceType = .photoLibrary
        videoPickerController.mediaTypes = [kUTTypeMovie as String]
        videoPickerController.modalPresentationStyle = .custom
        if #available(iOS 11.0, *) {
            videoPickerController.videoExportPreset = AVAssetExportPresetPassthrough
        } else {
            videoPickerController.videoQuality = .typeHigh
        }
        self.present(videoPickerController, animated: true, completion: nil)
    }
    
    func importPhoto() {
        let videoPickerController = UIImagePickerController()
        videoPickerController.delegate = self
        videoPickerController.transitioningDelegate = self
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false { return }
        videoPickerController.sourceType = .photoLibrary
        videoPickerController.mediaTypes = [kUTTypeImage as String]
        videoPickerController.modalPresentationStyle = .custom
        self.present(videoPickerController, animated: true, completion: nil)
    }
    
    func showMediaTypeAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertController.Style.actionSheet)

        alertController.addAction(UIAlertAction(title: "Video", style: UIAlertAction.Style.destructive) { action -> Void in
            self.importVideo()
        })
        alertController.addAction(UIAlertAction(title: "Photo", style: UIAlertAction.Style.default) { action -> Void in
            let durationAlert = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertController.Style.actionSheet)

            durationAlert.addAction(UIAlertAction(title: "3s", style: UIAlertAction.Style.default) { action -> Void in
                self.createModel.photoDuration = 3
                self.importPhoto()
            })
            durationAlert.addAction(UIAlertAction(title: "4s", style: UIAlertAction.Style.default) { action -> Void in
                self.createModel.photoDuration = 4
                self.importPhoto()
            })
            durationAlert.addAction(UIAlertAction(title: "5s", style: UIAlertAction.Style.default) { action -> Void in
                self.createModel.photoDuration = 5
                self.importPhoto()
            })
            
            self.present(durationAlert, animated: true, completion: nil)
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showFilterAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertController.Style.actionSheet)

        alertController.addAction(UIAlertAction(title: "None", style: UIAlertAction.Style.destructive) { action -> Void in
            self.createModel.setFilter(filter: .None)
        })
        alertController.addAction(UIAlertAction(title: "MotionBlur", style: UIAlertAction.Style.default) { action -> Void in
            self.createModel.setFilter(filter: .MotionBlur)
        })
        alertController.addAction(UIAlertAction(title: "PhotoEffectNoir", style: UIAlertAction.Style.default) { action -> Void in
            self.createModel.setFilter(filter: .PhotoEffectNoir)
        })
        alertController.addAction(UIAlertAction(title: "AnalogFilm", style: UIAlertAction.Style.default) { action -> Void in
            self.createModel.setFilter(filter: .AnalogFilm)
        })
        alertController.addAction(UIAlertAction(title: "Focusing", style: UIAlertAction.Style.default) { action -> Void in
            self.createModel.setFilter(filter: .Focusing)
        })
        alertController.addAction(UIAlertAction(title: "Vignette", style: UIAlertAction.Style.default) { action -> Void in
            self.createModel.setFilter(filter: .Vignette)
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showBrightnessAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertController.Style.actionSheet)

        alertController.addAction(UIAlertAction(title: "None", style: UIAlertAction.Style.destructive) { action -> Void in
            self.createModel.setBrightness(bright: false)
        })
        alertController.addAction(UIAlertAction(title: "Brightness", style: UIAlertAction.Style.default) { action -> Void in
            self.createModel.setBrightness(bright: true)
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showTemperatureAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle:UIAlertController.Style.actionSheet)

        alertController.addAction(UIAlertAction(title: "None", style: UIAlertAction.Style.destructive) { action -> Void in
            self.createModel.setTemperature(temperature: false)
        })
        alertController.addAction(UIAlertAction(title: "Temperature", style: UIAlertAction.Style.default) { action -> Void in
            self.createModel.setTemperature(temperature: true)
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Notifications
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
            videoPlayer.play()

            buttonPlay.setImage(UIImage(named: "pause"), for: .normal)
            UIView.animate(withDuration: 0.5, animations: {
                self.buttonPlay.alpha = 1.0
            }) { (finished) in
                UIView.animate(withDuration: 0.5) {
                    self.buttonPlay.alpha = 0.3
                }
            }
        }
    }

    
    // MARK: - IBActions
    
    @IBAction func onPlayVideo(_ sender: Any) {
        if buttonPlay.image(for: .normal) == UIImage(named: "pause") {
            buttonPlay.setImage(UIImage(named: "play"), for: .normal)
            videoPlayer.pause()
        } else {
            buttonPlay.setImage(UIImage(named: "pause"), for: .normal)
            videoPlayer.play()
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.buttonPlay.alpha = 1.0
        }) { (finished) in
            UIView.animate(withDuration: 0.5) {
                self.buttonPlay.alpha = 0.3
            }
        }
    }
    
    @IBAction func onExportVideo(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "ExportViewController") as? ExportViewController else { return }
        vc.createModel = createModel
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func onSelectVideo1(_ sender: Any) {
        createModel.editingIndex = 0
        showMediaTypeAlert()
    }
    
    @IBAction func onSelectVideo2(_ sender: Any) {
        createModel.editingIndex = 1
        showMediaTypeAlert()
    }
    
    @IBAction func onSelectVideo3(_ sender: Any) {
        createModel.editingIndex = 2
        showMediaTypeAlert()
    }
    
    @IBAction func onFilterVideo1(_ sender: Any) {
        createModel.editingIndex = 0
        showFilterAlert()
    }
    
    @IBAction func onFilterVideo2(_ sender: Any) {
        createModel.editingIndex = 1
        showFilterAlert()
    }
    
    @IBAction func onFilterVideo3(_ sender: Any) {
        createModel.editingIndex = 2
        showFilterAlert()
    }
    
    @IBAction func onBrightVideo1(_ sender: Any) {
        createModel.editingIndex = 0
        showBrightnessAlert()
    }
    
    @IBAction func onBrightVideo2(_ sender: Any) {
        createModel.editingIndex = 1
        showBrightnessAlert()
    }
    
    @IBAction func onBrightVideo3(_ sender: Any) {
        createModel.editingIndex = 2
        showBrightnessAlert()
    }
    
    @IBAction func onTemperatureVideo1(_ sender: Any) {
        createModel.editingIndex = 0
        showTemperatureAlert()
    }
    
    @IBAction func onTemperatureVideo2(_ sender: Any) {
        createModel.editingIndex = 1
        showTemperatureAlert()
    }
    
    @IBAction func onTemperatureVideo3(_ sender: Any) {
        createModel.editingIndex = 2
        showTemperatureAlert()
    }
    
    @IBAction func onRotateVideo1(_ sender: Any) {
        createModel.editingIndex = 0
        self.createModel.setRotation()
    }
    
    @IBAction func onRotateVideo2(_ sender: Any) {
        createModel.editingIndex = 1
        self.createModel.setRotation()
    }
    
    @IBAction func onRotateVideo3(_ sender: Any) {
        createModel.editingIndex = 2
        self.createModel.setRotation()
    }
    
}

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        if mediaType == kUTTypeImage {
            if let image = info[.originalImage] as? UIImage {
                self.dismiss(animated: true, completion: nil)
                loadingView.isHidden = false
                videoPlayer.pause()
                createModel.writeImageAsMovie(image: image) { (url, error) in
                    DispatchQueue.main.async {
                        self.loadingView.isHidden = true

                        if let videoURL = url {
                            self.createModel.setVideoUrl(url: videoURL)
                            self.playVideo()
                        }
                    }
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }

        } else {
            let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            self.dismiss(animated: true, completion: nil)
            
            if let videoURL = url {
                createModel.setVideoUrl(url: videoURL)
                playVideo()
            }
        }
    }
}
