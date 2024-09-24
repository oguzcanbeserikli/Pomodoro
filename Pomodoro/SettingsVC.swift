//
//  SettingsVC.swift
//  Pomodoro
//
//  Created by Oğuzcan Beşerikli on 24.09.2024.
//

import UIKit

class SettingsVC: UIViewController {
    
    let focusValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Focus Time: 25 min"
        label.textColor = .systemRed
        return label
    }()
    
    let focusSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 5
        slider.maximumValue = 60
        slider.value = 25
        slider.addTarget(self, action: #selector(focusSliderChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    @objc func focusSliderChanged(_ sender: UISlider) {
        let focusTime = Int(sender.value) // Get the value from the slider
        focusValueLabel.text = "Focus Time: \(focusTime) min"
    }
    
    let breakValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Break Time: 5 min"
        label.textColor = .systemGreen
        return label
    }()
    
    let breakSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 20
        slider.value = 5
        slider.addTarget(self, action: #selector(breakSliderChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    @objc func breakSliderChanged(_ sender: UISlider) {
        let breakTime = Int(sender.value) // Get the value from the slide
        breakValueLabel.text = "Break Time: \(breakTime) min"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        focusSlider.addTarget(self, action: #selector(focusSliderChanged(_:)), for: .valueChanged)
        breakSlider.addTarget(self, action: #selector(breakSliderChanged(_:)), for: .valueChanged)
    }
    
    func setupUI() {
        view.backgroundColor = .white
        title = "Settings"
        
        focusSlider.translatesAutoresizingMaskIntoConstraints = false
        breakSlider.translatesAutoresizingMaskIntoConstraints = false
        focusValueLabel.translatesAutoresizingMaskIntoConstraints = false
        breakValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(focusSlider)
        view.addSubview(breakSlider)
        view.addSubview(focusValueLabel)
        view.addSubview(breakValueLabel)
        
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
            breakValueLabel.topAnchor.constraint(equalTo: breakSlider.bottomAnchor, constant: 20)
        ])
        
    }
}
