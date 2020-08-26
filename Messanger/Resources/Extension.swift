//
//  Extension.swift
//  Messanger
//
//  Created by Maruf Howlader on 8/26/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    public var width: CGFloat{
        return frame.size.width
    }
    public var height: CGFloat{
        return frame.size.height
    }
    public var top: CGFloat{
        return frame.origin.y
    }
    public var left: CGFloat{
        return frame.origin.x
    }
    public var bottom: CGFloat{
           return top + height 
       }
    public var right: CGFloat{
       return left + width
    }
}

