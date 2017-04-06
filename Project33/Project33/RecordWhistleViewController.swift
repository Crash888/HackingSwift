//
//  RecordWhistleViewController.swift
//  Project33
//
//  Created by D D on 2017-04-06.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

import AVFoundation

class RecordWhistleViewController: UIViewController, AVAudioRecorderDelegate {

    var stackView: UIStackView!
    
    var recordButton: UIButton!
    var playButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var whistleRecorder: AVAudioRecorder!
    
    var whistlePlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Record your Whistle"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Record", style: .plain, target: nil, action: nil)
        
        //  New Audio Session
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            
            //  Asking the user if we can play and record audio
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                
                //  What did the user say?  Take action based on Yes or No
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //  Load and create the view.
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.gray
        
        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackViewDistribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    func loadRecordingUI() {
        recordButton = UIButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        stackView.addArrangedSubview(recordButton)
        
        playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Tap to Play", for: .normal)
        playButton.isHidden = true
        playButton.alpha = 0
        playButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        stackView.addArrangedSubview(playButton)
    }
    
    func loadFailUI() {
        let failLabel = UILabel()
        failLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(failLabel)
    }
    
    //  Directory to store the audio files
    //  Called on class and not the instance
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    class func getWhistleURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("whistle.m4a")
    }
    
    //  Change the UI for recording and begin the recording
    func startRecording() {
        
        //  Red background to indicate recording
        view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        
        //  Change recording label.  User will now press it to stop recording
        recordButton.setTitle("Tap to Stop", for: .normal)
        
        //  Get the place to store the audio file
        let audioURL = RecordWhistleViewController.getWhistleURL()
        print(audioURL.absoluteString)
        
        //  Setup a setting dictionary for the recording
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        //  Ready to go!
        do {
            //  Setup the recorder
            whistleRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            whistleRecorder.delegate = self
            //  Begin recording
            whistleRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        
        //  Put background back to green to indicate recording finished
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        
        whistleRecorder.stop()
        whistleRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            
            if playButton.isHidden {
                //  Animation used in conjunction with the stackview has a nice effect
                UIView.animate(withDuration: 0.35) { [unowned self] in
                    self.playButton.isHidden = false
                    self.playButton.alpha = 1
                }
            }
            
            //  If user likes the recording then can press this to move to next step
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            
            let ac = UIAlertController(title: "Record Failed", message: "There was aprobem recording your whistle; please try again", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func nextTapped() {
        let vc = SelectGenreTableViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func recordTapped() {
        if whistleRecorder == nil {
            startRecording()
            
            if !playButton.isHidden {
                //  Animation used in conjunction with the stackview has a nice effect
                UIView.animate(withDuration: 0.35) {
                    self.playButton.isHidden = true
                    self.playButton.alpha = 0
                }
            }
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        //  If this ended with an error then call finishRecording to reset everything
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func playTapped() {
        let audioURL = RecordWhistleViewController.getWhistleURL()
        
        do {
            whistlePlayer = try AVAudioPlayer(contentsOf: audioURL)
            whistlePlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem playing your whistle; please try re-recording", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
