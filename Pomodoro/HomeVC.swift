//
//  HomeVC.swift
//  Pomodoro
//
//  Created by Oğuzcan Beşerikli on 24.09.2024.
//

import UIKit

class HomeVC: UIViewController, SliderValueChangedDelegate {
    let circularProgressView = CircularProgressView()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36)
        label.text = "25:00"
        label.textColor = .black
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
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()
    
    @objc func startButtonTapped() {
        startButton.isHidden = true
        pauseButton.isHidden = false
        resetButton.isHidden = false
        startTimer()
    }
    
    let pauseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pause", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()
    
    @objc func pauseButtonTapped() {
        timer?.invalidate() // Pause the timer
        startButton.setTitle("Resume", for: .normal)
        startButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        button.setTitleColor(.systemRed, for: .normal)
        return button
    }()
    
    @objc func resetButtonTapped() {
        timer?.invalidate() // Stop the timer
        timeRemaining = isFocusTime ? focusTime : breakTime // Reset time
        updateTimerLabel()
        startButton.setTitle("Start", for: .normal)
        startButton.isHidden = false
        pauseButton.isHidden = true
        resetButton.isHidden = true
    }
    
    var timer: Timer?
    var isFocusTime = true
    var timeRemaining = 25*60
    var focusTime = 25*60
    var breakTime = 5 * 60
    
    func didValueChanged(focusTime: Int, breakTime: Int) {
        self.focusTime = focusTime * 60
        self.breakTime = breakTime * 60
        
        if isFocusTime {
            timeRemaining = self.focusTime
        } else {
            timeRemaining = self.breakTime
        }
        
        updateTimerLabel()
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCircularProgressView()
        pauseButton.isHidden = true
        resetButton.isHidden = true
    }
    
    func setupTitle() {
        self.title = "Focus Cycle"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    func createRightBarButtonItem() {
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        settingsButton.tintColor = .systemRed
        navigationItem.rightBarButtonItems = [settingsButton]
    }
    
    @objc func settingsButtonTapped() {
        let settingsVC = SettingsVC()
        settingsVC.delegate = self
        settingsVC.currentFocusTime = focusTime / 60
        settingsVC.currentBreakTime = breakTime / 60
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func setupUI() {
        view.backgroundColor = .white
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
    
    func updateCircularProgressView() {
        circularProgressView.updateStrokeColor(isFocusTime: isFocusTime)
        statusLabel.text = isFocusTime ? "Focus Time" : "Break Time"
        updateTimerLabel()
    }
    
    func switchStatus() {
        isFocusTime.toggle()
        timeRemaining = isFocusTime ? focusTime : breakTime
        updateCircularProgressView()
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
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
        
        let progress = CGFloat(timeRemaining) / CGFloat(isFocusTime ? focusTime : breakTime)
        circularProgressView.progress = progress
    }
}
