//
//  RBKLivenessStyle.swift
//  RBKLiveness
//
//  Created by Gulnaz on 12/20/20.
//  Copyright © 2020 Gulnaz. All rights reserved.
//

import UIKit

public class RBKLivenessConfig {
    public static var backgroundColor: UIColor = .white
    
    public static var buttonColor: UIColor = .blue
    public static var buttonSize: CGSize = .init(width: 60, height: 60)
    public static var successViewSize: CGSize = .init(width: 80, height: 80)
    public static var buttonTitleColor: UIColor = .white
    public static var infoTitleFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    public static var infoTitleColor: UIColor = .black
    public static var imgTintColor: UIColor = .white
    public static var successColor: UIColor = .green
    
    public static var closeTitle = "Close"
    public static var faceNotFoundTitle = "Лиц не найдено"
    public static var toManyFaceErrorTitle = "Внутри овала должно быть одно лицо"
    public static var turnRightTitle = "Поверните голову направо"
    public static var turnLeftTitle = "Поверните голову налево"
    public static var leanLeftTitle = "Наклоните голову налево"
    public static var leanRightTitle = "Наклоните голову направо"
    public static var smileTitle = "Улыбнитесь"
    public static var blinkTitle = "Моргните"
    public static var openMouthTitle = "Откройте рот"
    public static var faceError1Title = "Держите голову прямо с открытими глазами"
    public static var faceError2Title = "Поместите голову в овал"
    public static var breakRegTitle = "Прервать процесс регистрации?"
    public static var livenessTitle = "Идентификация"
    public static var successTitle = "Успешно!"
}
