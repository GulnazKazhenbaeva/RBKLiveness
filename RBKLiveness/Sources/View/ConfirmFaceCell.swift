////
////  ConfirmFaceCell.swift
////  mb_rbk
////
////  Created by Nazhmeddin on 9/18/20.
////  Copyright © 2020 Gulnaz. All rights reserved.
////
//
//import UIKit
//
//public class ConfirmFaceCell: BaseTableCell {
//    private lazy var iconView = UIImageView()
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
//        iconView.contentMode = .scaleAspectFill
//        infoLabel.numberOfLines = 0
//        infoLabel.textAlignment = .center
//        infoLabel.font = AppFont.medium(size: .regular)
//        infoLabel.textColor = AppColor.title.uiColor
//    }
//    
//    private func addSubviews() {
//        
//        contentView.addSubview(iconView)
//        contentView.addSubview(infoLabel)
//        
//        iconView.snp.makeConstraints { m in
//            m.top.equalTo(Style.xxxxl.space)
//            m.centerX.equalToSuperview()
//        }
//        
//        infoLabel.snp.makeConstraints { m in
//            m.top.equalTo(iconView.snp.bottom).offset(Style.medium.space)
//            m.left.equalTo(Style.medium.space)
//            m.right.equalTo(-Style.medium.space)
//            m.bottom.equalTo(-Style.xl.space)
//        }
//    }
//    
//    public func configure(_ text: String?, _ image: ImageProtocol?, color: UIColor?){
//        infoLabel.text = text
//        iconView.image = image?.uiImage?.withRenderingMode(.alwaysTemplate)
//        iconView.tintColor = color
//    }
//}
