//
//  HomeVC.swift
//  Pomodoro
//
//  Created by Oğuzcan Beşerikli on 24.09.2024.
//

import UIKit
import AVFoundation

class HomeVC: UIViewController, SliderValueChangedDelegate {
    let circularProgressView = CircularProgressView()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36)
        label.text = "25:00"
        label.textColor = .white
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Focus Time"
        label.textColor = .systemRed
        return label
    }()
    
    let startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()
    
    @objc func startButtonTapped() {
        startButton.isHidden = true
        pauseButton.isHidden = false
        resetButton.isHidden = false
        startTimer()
        isPomodoroOn = true
    }
    
    let pauseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pause", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()
    
    @objc func pauseButtonTapped() {
        timer?.invalidate() // Pause the timer
        startButton.setTitle("Resume", for: .normal)
        startButton.isHidden = false
        pauseButton.isHidden = true
        stopSound()
    }
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()
    
    @objc func resetButtonTapped() {
        resetTimer()
        stopSound()
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo1")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var audioPlayer: AVAudioPlayer?
    var audioSession: AVAudioSession?
    var timer: Timer?
    var timerState: TimerState = .focus
    var timeRemaining = 25 * 60
    var focusTime = 25 * 60
    var breakTime = 10 * 60
    var longBreakTime = 20 * 60
    var cycleCount = 0
    var isPomodoroOn = false
    var selectedSound = "silence"
    
    func didValueChanged(focusTime: Int, breakTime: Int, longBreakTime: Int) {
        self.focusTime = focusTime * 60
        self.breakTime = breakTime * 60
        self.longBreakTime = longBreakTime * 60
        
        switch timerState {
        case .focus:
            timeRemaining  = self.focusTime
        case .break:
            timeRemaining  = self.breakTime
        case .longBreak:
            timeRemaining  = self.longBreakTime
        }
        
        updateTimerLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCircularProgressView()
        pauseButton.isHidden = true
        resetButton.isHidden = true
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        setupAudioSession()
    }
    
    func setupTitle() {
        let titleView = UIView()
        let titleLabel = UILabel()
        navigationController?.navigationBar.tintColor = .systemRed
        
        titleLabel.text = "Focus Cycle"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .systemRed
        
        titleView.addSubview(imageView)
        titleView.addSubview(titleLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor)
        ])
        
        titleView.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        navigationItem.titleView = titleView
    }
    
    func createRightBarButtonItem() {
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        let soundButton = UIBarButtonItem(image: UIImage(systemName: "speaker.wave.2.fill"), style: .plain, target: self, action: #selector(soundButtonTapped))
        settingsButton.tintColor = .systemRed
        navigationItem.rightBarButtonItems = [settingsButton, soundButton]
    }
    
    @objc func soundButtonTapped() {
        let alert = UIAlertController(title: "Select Sound", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Rain", style: .default, handler: { _ in
            self.selectedSound = "Rain"
        }))
        alert.addAction(UIAlertAction(title: "Birds", style: .default, handler: { _ in
            self.selectedSound = "Bird"
        }))
        alert.addAction(UIAlertAction(title: "Fireplace", style: .default, handler: { _ in
            self.selectedSound = "Fireplace"
        }))
        alert.addAction(UIAlertAction(title: "Sea Waves", style: .default, handler: { _ in
            self.selectedSound = "Sea Waves"
        }))
        alert.addAction(UIAlertAction(title: "Clear Sound", style: .destructive, handler: { _ in
            self.selectedSound = "silence"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func settingsButtonTapped() {
        let settingsVC = SettingsVC()
        settingsVC.delegate = self
        settingsVC.currentFocusTime = focusTime / 60
        settingsVC.currentBreakTime = breakTime / 60
        settingsVC.currentLongBreakTime = longBreakTime / 60
        settingsVC.isPomodoroOn = isPomodoroOn
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func setupUI() {
        view.backgroundColor = .black
        setupTitle()
        createRightBarButtonItem()
        
        circularProgressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circularProgressView)
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        circularProgressView.addSubview(timerLabel)
        circularProgressView.addSubview(statusLabel)
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)
        view.addSubview(pauseButton)
        view.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            circularProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularProgressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            timerLabel.centerXAnchor.constraint(equalTo: circularProgressView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: circularProgressView.centerYAnchor, constant: -20),
            
            statusLabel.centerXAnchor.constraint(equalTo: circularProgressView.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 10),
            
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: circularProgressView.bottomAnchor, constant: 120),
            
            pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pauseButton.topAnchor.constraint(equalTo: circularProgressView.bottomAnchor, constant: 120),
            
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.topAnchor.constraint(equalTo: pauseButton.bottomAnchor, constant: 20)
        ])
    }
    
    func resetTimer() {
        timer?.invalidate()
        timerState = .focus
        cycleCount = 0
        timeRemaining = focusTime
        updateCircularProgressView()
        startButton.setTitle("Start", for: .normal)
        startButton.isHidden = false
        pauseButton.isHidden = true
        resetButton.isHidden = true
        isPomodoroOn = false
    }
    
    func updateCircularProgressView() {
        circularProgressView.updateStrokeColor(for: timerState)
        switch timerState {
        case .focus:
            statusLabel.text = "Focus Time"
            statusLabel.textColor = .systemRed
        case .break:
            statusLabel.text = "Break Time"
            statusLabel.textColor = .systemGreen
        case .longBreak:
            statusLabel.text = "Long Break"
            statusLabel.textColor = .systemBlue
        }
        updateTimerLabel()
    }
    
    func switchStatus() {
        stopSound()
        if timerState == .focus {
            cycleCount += 1
            if cycleCount % 4 == 0 {
                timerState = .longBreak
                timeRemaining = longBreakTime
            }
            else {
                timerState = .break
                timeRemaining = breakTime
            }
        }
        else {
            timerState = .focus
            timeRemaining = focusTime
        }
        updateCircularProgressView()
        timer?.invalidate()
        playAlert {
            self.startTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
        isPomodoroOn = true
        
        playBackgroundAudio()
    }
    
    func playBackgroundAudio() {
        if timerState == .focus {
            playSelectedOrSilentSound()
        } else {
            playSilentSound()
        }
    }
    
    @objc func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            updateTimerLabel()
        }
        else {
            switchStatus()
        }
    }
    
    func updateTimerLabel() {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        let totalTime: Int
        switch timerState {
        case .focus:
            totalTime = focusTime
        case .break:
            totalTime = breakTime
        case .longBreak:
            totalTime = longBreakTime
        }
        let progress = CGFloat(timeRemaining) / CGFloat(totalTime)
        circularProgressView.progress = progress
    }
    
    func playAlert(completion: @escaping () -> Void) {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try audioSession?.setActive(true)
            
            guard let url = Bundle.main.url(forResource: "alert", withExtension: "mp3") else {
                print("Sound file not found.")
                return
            }
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + audioPlayer!.duration) {
                completion()
            }
        } catch let error {
            print("Error setting up audio session or playing sound: \(error.localizedDescription)")
        }
    }
    
    func playSelectedOrSilentSound() {
        if selectedSound != "silence" {
            playSound()
        } else {
            playSilentSound()
        }
    }
    
    func playSilentSound() {
        if let soundURL = Bundle.main.url(forResource: "silence", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = 0
                audioPlayer?.play()
                print("Playing silent sound")
            } catch {
                print("Failed to play silent sound: \(error.localizedDescription)")
            }
        } else {
            print("Silent sound file not found")
        }
    }
    
    func playSound() {
        if let soundURL = Bundle.main.url(forResource: selectedSound, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = 1
                audioPlayer?.play()
                print("Playing sound: \(selectedSound)")
            } catch {
                print("Failed to play sound: \(error.localizedDescription)")
            }
        } else {
            print("Sound file not found: \(selectedSound)")
            playSilentSound()
        }
    }
    
    func stopSound() {
        if let player = audioPlayer, player.isPlaying {
            player.stop()
            print("Sound stopped.")
        } else {
            print("No sound is currently playing.")
        }
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
}
