//
//  CustomButton.swift
//  ifkadyrovPW7
//
//  Created by user211270 on 1/26/22.
//

import Foundation
import UIKit

class CustomButton : UIButton {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(backgroundColor: UIColor, content: String, frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        self.setTitle(content, for: .normal)
        self.layer.cornerRadius = 25
    }
}
