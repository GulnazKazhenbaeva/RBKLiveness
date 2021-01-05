////
////  CameraBottomView.swift
////  mb_rbk
////
////  Created by Gulnaz on 10/16/19.
////  Copyright © 2019 Gulnaz. All rights reserved.
////

import UIKit

public class CameraBottomView: UIView {
    lazy var takePhotoButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = RBKLivenessConfig.buttonColor
        return button
    }()
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle(RBKLivenessConfig.closeTitle, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onTakePhoto: (() -> Void)?
    var onClose: (() -> Void)?
    
    private func addSubviews() {
        addSubview(takePhotoButton)
        addSubview(closeButton)
        
        takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        var bottomPadding: CGFloat = 0
//        if #available(iOS 11.0, *) {
//            let window = UIApplication.shared.keyWindow
//            bottomPadding = window?.safeAreaInsets.bottom ?? 0
//        }
        
//        takePhotoButton.snp.makeConstraints { make in
//            make.top.equalTo(Style.large.space)
//            make.bottom.equalToSuperview().offset(-Style.xxl.space - bottomPadding)
//            make.centerX.equalToSuperview()
//            make.size.equalTo(Style.xxxl.size).priority(900)
//        }
//        takePhotoButton.cornered(radius: Style.xxxl.size.height / 2)
//
//        closeButton.snp.makeConstraints { make in
//            make.left.equalTo(Style.small.space).priority(900)
//            make.centerY.equalTo(takePhotoButton)
//        }
    }
    
    @objc private func takePhoto() {
        onTakePhoto?()
    }
    @objc private func close() {
        onClose?()
    }
}
