//
//  ViewController.swift
//  SoundAnimation
//
//  Created by iPHTech 23 on 23/11/23.
//


import UIKit
import AVFoundation

var isAudioPlaying = false

class ViewController: UIViewController {
    
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    fileprivate let seekDuration: Float64 = 10
    
    var engine : AVAudioEngine!
    @IBOutlet weak var audioVisualizer : AudioVisualizerView!
    @IBOutlet weak var ButtonPlay: UIButton!
    
    var musicDataArray:[MusicData] = [MusicData]()
    var currentlyPlayingMusic: MusicData? = nil
    var currentlySelectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupDefaultMusicData { isDataFetched in
            if isDataFetched {
                if self.musicDataArray.count > 0{
                    self.currentlyPlayingMusic = self.musicDataArray.first
                    self.currentlySelectedIndex = 0
                    self.setupMusicPlayer(musicData: self.currentlyPlayingMusic!)
                }
            }
        }
        
    }
    
    func setupDefaultMusicData(completion: @escaping ((Bool)-> Void)) {
        if let url = Bundle.main.url(forResource: "Music", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([MusicData].self, from: data)
                self.musicDataArray = jsonData
                completion(true)
            } catch {
                print("error:\(error)")
                completion(false)
            }
        }
    }
    
    func setupMusicPlayer(musicData: MusicData) {
//        guard let url = Bundle.main.url(forResource: musicData.url, withExtension: "mp3") else {
//            return
//        }
//        let playerItem:AVPlayerItem = AVPlayerItem(url: url)
//        player = AVPlayer(playerItem: playerItem)
        audioVisualizer = AudioVisualizerView(frame: audioVisualizer.frame, audioFileName: currentlyPlayingMusic?.url ?? "")
    }
    
    @IBAction func ButtonPlay(_ sender: Any) {
        print("play Button")
        if !isAudioPlaying
        {
            isAudioPlaying = true
            ButtonPlay.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
            audioVisualizer.play()
        } else {
            isAudioPlaying = false
            ButtonPlay.setImage(UIImage(named: "play"), for: UIControl.State.normal)
            audioVisualizer.pause()
        }
    }
}
