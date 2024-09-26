//
//  CircularProgressView.swift
//  Pomodoro
//
//  Created by Oğuzcan Beşerikli on 24.09.2024.
//

import UIKit

class CircularProgressView: UIView {

    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    
    var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
                                        radius: 100,
                                        startAngle: CGFloat(-0.5 * Double.pi),
                                        endAngle: CGFloat(1.5 * Double.pi), clockwise: true)
        
    
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(backgroundLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.red.cgColor
        progressLayer.lineWidth = 10
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    func updateStrokeColor(for timerState: TimerState) {
        let color: UIColor
        switch timerState {
        case .focus:
            color = .red
            progressLayer.strokeColor = color.cgColor
        case .break:
            color = .green
            progressLayer.strokeColor = color.cgColor
        case .longBreak:
            color = .blue
            progressLayer.strokeColor = color.cgColor
        }
    }
}

enum TimerState{
    case focus
    case `break`
    case longBreak
}
