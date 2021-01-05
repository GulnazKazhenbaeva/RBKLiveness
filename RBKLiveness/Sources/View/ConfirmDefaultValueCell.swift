////
////  ConfirmDefaultValueCell.swift
////  mb_rbk
////
////  Created by Nazhmeddin on 9/18/20.
////  Copyright © 2020 Gulnaz. All rights reserved.
////
//
//import UIKit
//
//public class ConfirmDefaultValueCell: BaseTableCell {
//    private lazy var cornerView = UIView()
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
//        cornerView.backgroundColor = AppColor.button.uiColor
//        cornerView.cornered(radius: 12)
//        iconView.contentMode = .scaleAspectFill
//        infoLabel.numberOfLines = 0
//        infoLabel.textAlignment = .left
//        infoLabel.font = AppFont.medium(size: .regular)
//        infoLabel.textColor = AppColor.title.uiColor
//    }
//    
//    private func addSubviews() {
//        
//        cornerView.addSubview(iconView)
//        contentView.addSubview(cornerView)
//        contentView.addSubview(infoLabel)
//        
//        cornerView.snp.makeConstraints { m in
//            m.width.height.equalTo(24)
//            m.centerY.equalToSuperview()
//            m.left.equalTo(Style.medium.space)
//        }
//        
//        iconView.snp.makeConstraints { m in
//            m.edges.equalToSuperview().inset(2)
//        }
//        
//        infoLabel.snp.makeConstraints { m in
//            m.top.bottom.equalToSuperview().inset(Style.medium.space)
//            m.left.equalTo(cornerView.snp.right).offset(Style.xs.space)
//            m.right.equalTo(-Style.small.space)
//        }
//        
//    }
//    
//    public func configure(_ text: String?, _ image: ImageProtocol?){
//        infoLabel.text = text
//        let image = image?.uiImage?.withRenderingMode(.alwaysTemplate)
//        iconView.image = image?.withAlignmentRectInsets(UIEdgeInsets(top: -4, left: -4, bottom: -4, right: -4))
//        iconView.tintColor = AppColor.buttonTitle.uiColor
//    }
//}
