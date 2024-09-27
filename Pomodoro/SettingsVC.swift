//
//  SettingsVC.swift
//  Pomodoro
//
//  Created by Oğuzcan Beşerikli on 24.09.2024.
//

import UIKit
import SafariServices

protocol SliderValueChangedDelegate {
    func didValueChanged(focusTime: Int, breakTime: Int, longBreakTime: Int)
}

class SettingsVC: UIViewController {
    var isPomodoroOn: Bool!

    
    let focusValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Focus Time: 25 min"
        label.textColor = .systemRed
        return label
    }()
    
    let breakValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Break Time: 5 min"
        label.textColor = .systemGreen
        return label
    }()
    
    let longBreakValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Long Break Time: 20 min"
        label.textColor = .systemBlue
        return label
    }()
    
    let focusSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 10
        slider.maximumValue = 40
        slider.addTarget(self, action: #selector(focusSliderChanged(_:)), for: .valueChanged)
        slider.minimumTrackTintColor = .systemRed
        return slider
    }()
    
    let breakSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 5
        slider.maximumValue = 20
        slider.addTarget(self, action: #selector(breakSliderChanged(_:)), for: .valueChanged)
        slider.minimumTrackTintColor = .systemGreen
        return slider
    }()
    
    let longBreakSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 15
        slider.maximumValue = 30
        slider.addTarget(self, action: #selector(longBreakSliderChanged(_:)), for: .valueChanged)
        slider.minimumTrackTintColor = .systemBlue
        return slider
    }()
    
    var delegate: SliderValueChangedDelegate?
    var currentFocusTime: Int = 25
    var currentBreakTime: Int = 10
    var currentLongBreakTime: Int = 20
    var tableView = UITableView()
    let sections = ["Share & Comment", "Terms of Service", "Privacy Policy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        aboutSlider()
    }
    
    func aboutSlider() {
        focusSlider.value = Float(currentFocusTime)
        focusValueLabel.text = "Focus Time: \(currentFocusTime) min"
        
        breakSlider.value = Float(currentBreakTime)
        breakValueLabel.text = "Break Time: \(currentBreakTime) min"
        
        longBreakSlider.value = Float(currentLongBreakTime)
        longBreakValueLabel.text = "Long Break Time: \(currentLongBreakTime) min"
        
        focusSlider.addTarget(self, action: #selector(focusSliderChanged(_:)), for: .valueChanged)
        breakSlider.addTarget(self, action: #selector(breakSliderChanged(_:)), for: .valueChanged)
        longBreakSlider.addTarget(self, action: #selector(longBreakSliderChanged(_:)), for: .valueChanged)
        
        focusSlider.isEnabled = !isPomodoroOn
        breakSlider.isEnabled = !isPomodoroOn
        longBreakSlider.isEnabled = !isPomodoroOn
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: longBreakValueLabel.bottomAnchor, constant: 45),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    func setupUI() {
        view.backgroundColor = .black
        title = "Settings"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemRed]
        
        focusSlider.translatesAutoresizingMaskIntoConstraints = false
        breakSlider.translatesAutoresizingMaskIntoConstraints = false
        longBreakSlider.translatesAutoresizingMaskIntoConstraints = false
        focusValueLabel.translatesAutoresizingMaskIntoConstraints = false
        breakValueLabel.translatesAutoresizingMaskIntoConstraints = false
        longBreakValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(focusSlider)
        view.addSubview(breakSlider)
        view.addSubview(longBreakSlider)
        view.addSubview(focusValueLabel)
        view.addSubview(breakValueLabel)
        view.addSubview(longBreakValueLabel)
        
        NSLayoutConstraint.activate([
            focusSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            focusSlider.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            focusSlider.widthAnchor.constraint(equalToConstant: 250),
            
            focusValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            focusValueLabel.topAnchor.constraint(equalTo: focusSlider.bottomAnchor, constant: 20),
            
            breakSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            breakSlider.topAnchor.constraint(equalTo: focusValueLabel.bottomAnchor, constant: 50),
            breakSlider.widthAnchor.constraint(equalToConstant: 250),
            
            breakValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            breakValueLabel.topAnchor.constraint(equalTo: breakSlider.bottomAnchor, constant: 20),
            
            longBreakSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            longBreakSlider.topAnchor.constraint(equalTo: breakValueLabel.bottomAnchor, constant: 50),
            longBreakSlider.widthAnchor.constraint(equalToConstant: 250),
            
            longBreakValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            longBreakValueLabel.topAnchor.constraint(equalTo: longBreakSlider.bottomAnchor, constant: 20)
        ])
    }
    
    @objc func focusSliderChanged(_ sender: UISlider) {
        let focusTime = Int(sender.value) // Get the value from the slider
        let breakTime = Int(breakSlider.value)
        let longBreakTime = Int(longBreakSlider.value)
        focusValueLabel.text = "Focus Time: \(focusTime) min"
        delegate?.didValueChanged(focusTime: focusTime, breakTime: breakTime, longBreakTime: longBreakTime)
    }
    
    @objc func breakSliderChanged(_ sender: UISlider) {
        let breakTime = Int(sender.value) // Get the value from the slide
        let focusTime = Int(focusSlider.value)
        let longBreakTime = Int(longBreakSlider.value)
        breakValueLabel.text = "Break Time: \(breakTime) min"
        delegate?.didValueChanged(focusTime: focusTime, breakTime: breakTime, longBreakTime: longBreakTime)
    }
    
    @objc func longBreakSliderChanged(_ sender: UISlider) {
        let longBreakTime = Int(sender.value)
        let focusTime = Int(focusSlider.value)
        let breakTime = Int(breakSlider.value)
        longBreakValueLabel.text = "Long Break Time: \(longBreakTime) min"
        delegate?.didValueChanged(focusTime: focusTime, breakTime: breakTime, longBreakTime: longBreakTime)
    }
    
    func shareAndComment() {
        if let url = URL(string: "https://apps.apple.com/us/app/focus-cycle/id6723672321") {
            UIApplication.shared.open(url)
        }
    }
    
    func showTermsOfService() {
        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/") {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
    
    func showPrivacyPolicy() {
        if let url = URL(string: "https://www.termsfeed.com/live/63110042-4014-48e1-906b-61ac1ca4ef33") {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = NSLocalizedString(sections[indexPath.section], comment: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            shareAndComment()
        case 1:
            showTermsOfService()
        case 2:
            showPrivacyPolicy()
        default:
            break
        }
    }
}
