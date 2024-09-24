//
//  HomeVC.swift
//  Pomodoro
//
//  Created by Oğuzcan Beşerikli on 24.09.2024.
//

import UIKit

class HomeVC: UIViewController {
    
    let circularProgressView = CircularProgressView()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36)
        label.text = "25:00"
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Focus Time"
        return label
    }()
    
    var isFocusTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupTitle() {
        self.title = "FocusCycle"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
    }
    
    func createRightBarButtonItem() {
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        settingsButton.tintColor = .systemRed
        navigationItem.rightBarButtonItems = [settingsButton]
    }

    @objc func settingsButtonTapped() {
        let settingsVC = SettingsVC()
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
        
        NSLayoutConstraint.activate([
            circularProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularProgressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circularProgressView.widthAnchor.constraint(equalToConstant: 200),
            circularProgressView.heightAnchor.constraint(equalToConstant: 200),
            
            timerLabel.centerXAnchor.constraint(equalTo: circularProgressView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: circularProgressView.centerYAnchor, constant: -20),
            
            statusLabel.centerXAnchor.constraint(equalTo: circularProgressView.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 10)
        ])
    }
    
    func updateCircularProgressView() {
        circularProgressView.updateStrokeColor(isFocusTime: isFocusTime)
        statusLabel.text = isFocusTime ? "Focus Time" : "Break Time"
    }
    
    func switchStatus() {
        isFocusTime.toggle()
        updateCircularProgressView()
    }
}
