//
//  ProfileModel.swift
//  Messanger
//
//  Created by Maruf Howlader on 8/26/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import Foundation

enum ProfileViewDataType{
       case info, signout
   }
   struct ProfileView{
       var viewDataType: ProfileViewDataType
       var title: String
       var handler: (() -> Void)?
   }
