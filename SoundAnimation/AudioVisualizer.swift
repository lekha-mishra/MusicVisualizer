//
//  AudioVisualizer.swift
//  SoundAnimation
//
//  Created by iPHTech 23 on 23/11/23.
//


import UIKit
import AVFoundation
import Accelerate

class AudioVisualizerView: UIView {

    private var audioEngine: AVAudioEngine!
    private var playerNode: AVAudioPlayerNode!
    private var audioFile: AVAudioFile!
    private var displayLink: CADisplayLink!
    private var barLayers: [CALayer] = []
    
    private let numberOfBars = 30
    private let barWidth: CGFloat = 5.0
    private let barCornerRadius: CGFloat = 2.0
    private let spacing: CGFloat = 5.0
    private let maxBarHeight: CGFloat = 270.0
    
    private var audioFileName: String = ""
    
    init(frame: CGRect, audioFileName: String) {
        super.init(frame: frame)
        self.audioFileName = audioFileName
        setupUI()
        setupAudioEngine()
        self.setupDisplayLink()
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupAudioEngine()
        self.setupDisplayLink()
    }

    private func setupUI() {

        // Create bar layers
        for i in 0..<numberOfBars {
            let barLayer = CALayer()
            barLayer.backgroundColor = UIColor.green.cgColor
            barLayer.frame = CGRect(x: CGFloat(i) * (barWidth + spacing) + 50, y: self.frame.size.height / 2, width: barWidth, height: 0)
            barLayer.cornerRadius = barCornerRadius
            layer.addSublayer(barLayer)
            barLayers.append(barLayer)
        }
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)

        guard let url = Bundle.main.url(forResource: self.audioFileName, withExtension: "mp3") else {
            return
        }
        do {
            audioFile = try AVAudioFile(forReading: url)
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }

        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
        try? audioEngine.start()
    }

    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateBars))
        displayLink.add(to: .main, forMode: .common)
    }


    @objc private func updateBars() {
        // Read audio samples and update bar heights
        if isAudioPlaying {
            let bufferSize = 1024
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(bufferSize))!
            
            do {
                try audioFile.read(into: buffer)
                
                let channelData = buffer.floatChannelData?[0]
                
                for i in 0..<numberOfBars {
                    let barHeight = CGFloat(abs(CGFloat(channelData?[i] ?? 0.0)) * maxBarHeight)
                    barLayers[i].bounds.size.height = barHeight
                    print(barHeight)
                }
            } catch {
                print("Error reading audio file: \(error.localizedDescription)")
            }
        }
    }

    func play() {
        playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        playerNode.play()
        
    }
    
    func pause() {
        playerNode.pause()
    }
}

