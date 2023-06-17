//
//  Extensions.swift
//  vkAPI
//
//  Created by sergey on 06.10.2022.
//  Copyright © 2022 Devloper. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func roundImage() {
        layer.cornerRadius = bounds.width/2
        clipsToBounds = true
    }
}
