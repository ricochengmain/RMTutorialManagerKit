//
//  ViewController.swift
//  RMTutorialManagerKit
//
//  Created by ricocheng on 09/12/2023.
//  Copyright (c) 2023 ricocheng. All rights reserved.
//

import UIKit
import RMTutorialManagerKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(testView1)
        view.addSubview(testView2)
    }

    var testView1: UIView = {
        let view = UIView.init(frame: CGRect(x: 100, y: 250, width: 200, height: 200))
        view.layer.cornerRadius = 100
        view.backgroundColor = .purple
        return view
    }()
    
    var testView2: UIView = {
        let view = UIView.init(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        view.layer.cornerRadius = 50
        view.backgroundColor = .purple
        return view
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        RMTutorialManager.add(itemView: testView2, tipText: "Hi! I'm Test2", position: .bottom, identifier: "Test2")
        RMTutorialManager.add(itemView: testView1, tipText: "Hello! Test1 is here", position: .top, identifier: "Test1")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



