//
//  ViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/14/21.
//

import UIKit
import NVActivityIndicatorView

class ViewController: UIViewController {
    private let activityIndicator: NVActivityIndicatorView = {
        var temp = NVActivityIndicatorView(frame: .zero,
                                           type: .circleStrokeSpin,
                                           color: .blue,
                                           padding: nil)
        return temp
    }()
    private let backView = UIView()
    
    func updateActivityIndicator(_ viewController: ViewController) {
        view.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.25)
            make.height.equalTo(view.bounds.width * 0.25)
        }
        backView.isHidden = true
        backView.layer.cornerRadius = 10
        backView.backgroundColor = UIColor(hex: "#5896f2")
        backView.layer.opacity = 0.8
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
            make.width.equalTo(view.bounds.width * 0.15)
            make.height.equalTo(view.bounds.width * 0.15)
        }
    }
    
    func startActivityIndicator() {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        backView.isHidden = false
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        backView.isHidden = true
        view.isUserInteractionEnabled = true
    }
}
