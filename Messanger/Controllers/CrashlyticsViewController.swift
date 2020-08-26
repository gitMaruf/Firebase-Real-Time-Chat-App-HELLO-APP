//
//  CrashlyticsViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 8/25/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit

final class CrashlyticsViewController: UIViewController {

     override func viewDidLoad() {
          super.viewDidLoad()
          view.backgroundColor = .systemBackground
          // Do any additional setup after loading the view, typically from a nib.

          let button = UIButton(type: .roundedRect)
          button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
          button.setTitle("Crash", for: [])
          button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
          view.addSubview(button)
      }

      @IBAction func crashButtonTapped(_ sender: AnyObject) {
          fatalError()
      }

}
