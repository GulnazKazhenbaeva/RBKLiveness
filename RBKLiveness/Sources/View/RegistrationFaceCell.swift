////
////  RegistrationFaceCell.swift
////  mb_rbk
////
////  Created by Gulnaz on 3/10/20.
////  Copyright © 2020 Gulnaz. All rights reserved.
////
//
//import UIKit
//
//public class RegistrationFaceCell: BaseTableCell {
//    private lazy var iconView = UIImageView(image: RegistrationImage.faceExample.uiImage)
//    private lazy var infoLabel = UILabel()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        stylizeViews()
//        addSubviews()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func stylizeViews() {
//        backgroundColor = .clear
//        contentView.backgroundColor = .clear
//        iconView.cornered()
//        infoLabel.numberOfLines = 0
//        infoLabel.textAlignment = .center
//        infoLabel.font = AppFont.medium(size: .regular)
//        infoLabel.textColor = AppColor.title.uiColor
//    }
//
//    private func addSubviews() {
//        contentView.addSubview(infoLabel)
//        contentView.addSubview(iconView)
//        infoLabel.snp.makeConstraints { m in
//            if UIDevice.current.isDevicesWithSensorHousing {
//                m.top.equalTo(Style.xxxxl.space)
//            } else {
//                m.top.equalTo(Style.large.space)
//            }
//            m.left.equalTo(Style.medium.space)
//            m.right.equalTo(-Style.medium.space)
//        }
//
//        iconView.snp.makeConstraints { m in
//            m.centerX.equalToSuperview()
//            m.width.equalTo(screenWidth - 48)
//            if UIDevice.current.isDevicesWithSensorHousing {
//                m.bottom.equalTo(-Style.xl.space)
//            } else {
//                m.bottom.equalTo(-Style.large.space)
//            }
//            m.top.equalTo(infoLabel.snp.bottom).offset(Style.medium.space)
//        }
//
//    }
//
//    public func configure(_ text: String?){
//        infoLabel.text = text
//    }
//
//    public func configure(_ text: NSAttributedString?){
//        infoLabel.attributedText = text
//    }
//}
