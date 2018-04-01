//
//  ViewController.swift
//  animatedcountdownchart
//
//  Created by Ömer Faruk Öztürk on 31.03.2018.
//  Copyright © 2018 omerfarukozturk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var chartView: ChartView!
    @IBOutlet weak var countdownView: CountdownView!
    
    let fillColor = UIColor(red: 92/255, green: 184/255, blue: 92/255, alpha: 1.0)
    let backgroundColor = UIColor(red: 240/255, green: 235/255, blue: 239/255, alpha: 1.0)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let totalValue = 1200.93
        let toValue  = 247.43
        let ratio = toValue / totalValue
        
        self.chartView.initializeView(arcWidth: 9.0, arcFillColor: fillColor, arcBackgroundColor: backgroundColor, fullArcAngle: 210.0)
        
        // initialize Countdown view
        self.countdownView.initializeView(totalValue: totalValue, fontColor : fillColor)

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800), execute: {
          
            self.chartView.animateCircle(toRatio: ratio)
            self.countdownView.animateCountdown(toValue: toValue)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

