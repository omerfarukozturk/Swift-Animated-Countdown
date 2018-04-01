//
//  CountdownView.swift
//  animatedcountdownchart
//
//  Created by Ömer Faruk Öztürk on 31.03.2018.
//  Copyright © 2018 omerfarukozturk. All rights reserved.
//

import Foundation
import UIKit

class CountdownView : UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!
    
    var labelWidthLarge : CGFloat = 28 // Indeger digits
    var labelWidthMedium : CGFloat = 18 // Decimal digits
    var labelWidthSmall : CGFloat = 7 // Comma
    
    var fontSizeLarge : CGFloat = 48
    var fontSizeMedium : CGFloat = 32
    
    var fontColor : UIColor = .orange
    
    // initial (total) value
    var totalValue : Double = 0.0 {
        didSet {
            self._totalValueArray = nil
        }
    }
    
    // new value
    var value : Double = 0.0 {
        didSet {
            self._valueArray = nil
        }
    }
    
    // Index of integer and decimal seperator "."
    private var commaIdx : Int {
        get {
            let intValue = Int(totalValue)
            return intValue.description.count
        }
    }
    
    // For 1500.98 : return ["1", "5", "0", "0", ".", "9", "8"]
    private var _totalValueArray : [String]?
    private var totalValueArray : [String] {
        get {
            
            if let array = self._totalValueArray {
                return array
            }
            
            let newArray = self.getValueArray(totalValue)
            self._totalValueArray = newArray
            return newArray
        }
    }
    
    // For 150.23 : return ["-1", "1","5","0",".","2","3"]
    // Add "-1" for remaining digits between "totalValue" and "value"
    private var _valueArray : [String]?
    private var valueArray : [String] {
        get {
            
            if let array = self._valueArray {
                return array
            }
            
            let newArray = self.getValueArray(value)
            self._valueArray = newArray
            return newArray
        }
    }
    
    // Initialize main view (UICollectionView)
    func initializeView(totalValue : Double, fontColor: UIColor){
        
        self.totalValue = totalValue
        self.fontColor = fontColor
        
        // Create CcollectionView and add to superview.
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        
        self.collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        self.collectionView.backgroundColor = UIColor.clear
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(CountdownCollectionViewCell.self, forCellWithReuseIdentifier: "CountdownCollectionViewCell")
        self.collectionView.register(CommaCell.self, forCellWithReuseIdentifier: "CommaCell")
        
        self.addSubview(self.collectionView)
        
        // CollectionView constraints.
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: collectionView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: collectionView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        
        // Calculated total width of CollectionView. (sum of label widths)
        let width = self.labelWidthLarge * CGFloat(Int(totalValue).description.count) + self.labelWidthSmall + self.labelWidthMedium * 2
        let widthConstraint = NSLayoutConstraint(item: collectionView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: width)
        let heightConstraint = NSLayoutConstraint(item: collectionView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.frame.height)
        self.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    
    // Create and return an array with digits of decimal value.
    private func getValueArray(_ value: Double) -> [String]{
        var valueArray = [String]()
        
        var intValue = Int(value)
        let decimalValue = Int((value * 100).truncatingRemainder(dividingBy: 100))
        
        valueArray.append(".")
        
        valueArray.append((decimalValue / 10).description)
        valueArray.append((decimalValue % 10).description)
        
        repeat {
            valueArray.insert(((intValue % 10).description), at: 0)
            intValue = intValue / 10
        } while intValue != 0
        
        let defaultIntValue = Int(value)
        let totalIntValue = Int(totalValue)
        let remainingValue = totalIntValue.description.count - defaultIntValue.description.count
        
        // insert -1 for difference between number of integer digits
        for _ in 0..<remainingValue {
            valueArray.insert("-1", at: 0)
        }
        return valueArray
    }
    
    // Animate countdown.
    func animateCountdown(toValue: Double){
        
        if self.collectionView == nil {
            print("To animate countdown, initialize CountdownView first by calling initializeView().")
            return
        }
        
        self.value = toValue
        
        // Animate all digits to related number.
        for idx in 0..<self.valueArray.count {
            if let contdownCell = self.collectionView.cellForItem(at: IndexPath(row: idx, section: 0)) as? CountdownCollectionViewCell {
                let index = (self.valueArray[idx] as NSString).integerValue
                contdownCell.scrollToIndex(index)
            }
        }
    }
    
    //MARK: - CollectionView delegates
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width : CGFloat = self.labelWidthSmall
        
        if indexPath.row < self.commaIdx {
            width = self.labelWidthLarge
        } else if indexPath.row > self.commaIdx {
            width = self.labelWidthMedium
        }
        return CGSize(width: width, height: self.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == self.commaIdx {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommaCell", for: indexPath) as! CommaCell
            cell.fontColor = self.fontColor
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountdownCollectionViewCell", for: indexPath) as! CountdownCollectionViewCell
            cell.fontColor = self.fontColor
            var fontSize : CGFloat = 32.0
            if indexPath.row < self.commaIdx {
                fontSize = self.fontSizeLarge
            } else if indexPath.row > 3 {
                fontSize = self.fontSizeMedium
            }
            
            let shouldHideZero = indexPath.row == 0
            cell.shouldHideZero = shouldHideZero

            cell.addLabels(fontsize: fontSize)
            cell.layoutIfNeeded()
            
            let value = self.totalValueArray[indexPath.row]
            let idx = (value as NSString).integerValue
            
            cell.scrollToIndex(idx,animated: false)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalValueArray.count
    }
    
    
}

class CommaCell : UICollectionViewCell {
    var label : UILabel!
    var fontColor : UIColor = .orange {
        didSet {
            if self.label != nil {
                self.label.textColor = self.fontColor
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.label = UILabel()
        self.label.text = "."
        self.label.font = UIFont(name: "AvenirNext-Demibold", size: 32)!
        self.label.textColor = self.fontColor
        self.label.textAlignment = .left
        
        self.addSubview(label)
        
        // Label constraints
        self.label.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: -1)
        let verticalConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.frame.width)
        let heightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 25)
        self.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class CountdownCollectionViewCell : UICollectionViewCell {
    
    var scrollView: UIScrollView!
    var stackView: UIStackView!
    var shouldHideZero : Bool = false
    var heightConstraint : NSLayoutConstraint!
    
    var fontColor : UIColor = .orange
    private var _numbers : [Int] = [-1,0,1,2,3,4,5,6,7,8,9]
    
    var numbers : [Int] {
        get {
            var numbers = self._numbers
            if self.shouldHideZero{
                numbers.remove(at: 1)
            }
            return numbers
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.scrollView = UIScrollView(frame: self.frame)
        
        self.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let scrollViewHorizontalConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let scrollViewVerticalConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        let scrollViewWidthConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.frame.width)
        let scrollViewHeightConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.frame.height)
        self.addConstraints([scrollViewHorizontalConstraint, scrollViewVerticalConstraint, scrollViewWidthConstraint, scrollViewHeightConstraint])
        
        
        self.stackView = UIStackView(frame: self.frame)
        self.stackView.axis  = .vertical
        self.stackView.distribution  = .equalSpacing
        self.stackView.alignment = .fill
        self.stackView.spacing   = 0.0
        
        scrollView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: stackView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: stackView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: stackView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        self.heightConstraint = NSLayoutConstraint(item: stackView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        self.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Get a label for any digit.
    func getLabel(_ text: String, fontSize: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        view.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true

        let labelHeight = fontSize * 0.833
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont(name: "AvenirNext-Demibold", size: fontSize)!
        textLabel.textColor = self.fontColor
        
        view.addSubview(textLabel)
        //textLabel.adjustsFontSizeToFitWidth = true

        // Label constraints
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.width, multiplier: 1, constant: self.frame.width)
        let heightConstraint = NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.height, multiplier: 1, constant: labelHeight)
        let buttomConstraint = NSLayoutConstraint(item: textLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        view.addConstraints([horizontalConstraint, widthConstraint, heightConstraint, buttomConstraint])

        return view
    }
    
    // Add labels for digits to StackView.
    func addLabels(fontsize : CGFloat){
        stackView.subviews.forEach { (item) in
            stackView.removeArrangedSubview(item)
            item.removeFromSuperview()
        }
        
        // height of stack view (40: item height)
        self.heightConstraint.constant = CGFloat(self.numbers.count * 40)
        
        self.numbers.forEach({ (item) in
            let text = item == -1 ? "" : item.description
            stackView.addArrangedSubview(self.getLabel(text , fontSize: fontsize))
        })
    }
    
    // Scroll to related digit.
    func scrollToIndex(_ value: Int, animated: Bool = true){
        var bounds = scrollView.bounds
        
        let idx = numbers.index(of: value) ?? 0
        
        bounds.origin.y = CGFloat(idx) * self.frame.height
        
        if animated {
            let animation = CABasicAnimation(keyPath: "bounds")
            animation.duration = 1.2
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.775, 0, 0.178, 1)
            
            animation.fromValue = scrollView.bounds
            
            animation.toValue = bounds
            scrollView.layer.add(animation, forKey: "bounds")
        }
        
        scrollView.bounds = bounds
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(1.2)
        UIView.commitAnimations()
    }
}
