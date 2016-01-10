//
//  NumPad.swift
//  NumPad
//
//  Created by Lasha Efremidze on 1/9/16.
//  Copyright © 2016 Lasha Efremidze. All rights reserved.
//

import UIKit

public struct Position {
    let row: Int
    let column: Int
}

public protocol NumPadDataSource: class {
    
    func numberOfRowsInNumberPad(numPad: NumPad) -> Int
    func numPad(numPad: NumPad, numberOfColumnsInRow row: Int) -> Int
    func numPad(numPad: NumPad, titleForButtonAtPosition position: Position) -> String
    func numPad(numPad: NumPad, titleColorForButtonAtPosition position: Position) -> UIColor
    func numPad(numPad: NumPad, fontForButtonAtPosition position: Position) -> UIFont
    func numPad(numPad: NumPad, imageForButtonAtPosition position: Position) -> UIImage
    func numPad(numPad: NumPad, backgroundColorForButtonAtPosition position: Position) -> UIColor
    func numPad(numPad: NumPad, backgroundHighlightedColorForButtonAtPosition position: Position) -> UIColor
    
}

extension NumPadDataSource {
    
    
    
}

public protocol NumPadDelegate: class {
    
    func numPad(numPad: NumPad, didSelectButtonAtIndexPath indexPath: NSIndexPath)
    
}

extension NumPadDelegate {
    
    func numPad(numPad: NumPad, didSelectButtonAtIndexPath indexPath: NSIndexPath) {}
    
}

public class NumPad: UIView {

    let collectionView = UICollectionView()
    
    weak public var delegate: NumPadDataSource?
    weak public var dataSource: NumPadDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        collectionView.collectionViewLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            return layout
        }()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clearColor()
        collectionView.allowsSelection = false
        collectionView.scrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CollectionViewCell.self)
        addSubview(collectionView)
        
        let views = ["collectionView": collectionView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: [], metrics: nil, views: views))
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

// MARK: - UICollectionViewDataSource
extension NumPad: UICollectionViewDataSource {
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfRows()
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfColumnsInRow(section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        let position = positionForIndexPath(indexPath)
        
        let title = delegate?.numPad(self, titleForButtonAtPosition: position)
        cell.button.setTitle(title, forState: .Normal)
        
        let titleColor = delegate?.numPad(self, titleColorForButtonAtPosition: position)
        cell.button.setTitleColor(titleColor, forState: .Normal)
        cell.button.tintColor = titleColor
        
        let font = delegate?.numPad(self, fontForButtonAtPosition: position)
        cell.button.titleLabel?.font = font
        
        let image = delegate?.numPad(self, imageForButtonAtPosition: position)
        cell.button.setImage(image, forState: .Normal)
        
        let backgroundColor = delegate?.numPad(self, backgroundColorForButtonAtPosition: position)
        let backgroundColorImage = backgroundColor?.toImage()
        cell.button.setBackgroundImage(backgroundColorImage, forState: .Normal)
        
        let backgroundHighlightedColor = delegate?.numPad(self, backgroundHighlightedColorForButtonAtPosition: position)
        let backgroundHighlightedColorImage = backgroundHighlightedColor?.toImage()
        cell.button.setBackgroundImage(backgroundHighlightedColorImage, forState: .Highlighted)
        cell.button.setBackgroundImage(backgroundHighlightedColorImage, forState: .Selected)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension NumPad: UICollectionViewDelegate {
    
}

// MARK: - Helpers
extension NumPad {
    
    func positionForIndexPath(indexPath: NSIndexPath) -> Position {
        return Position(row: indexPath.section, column: indexPath.item)
    }
    
    func numberOfRows() -> Int {
        return delegate?.numberOfRowsInNumberPad(self) ?? 0
    }
    
    func numberOfColumnsInRow(row: Int) -> Int {
        return delegate?.numPad(self, numberOfColumnsInRow: row) ?? 0
    }
    
}

// MARK: - CollectionViewCell
class CollectionViewCell: UICollectionViewCell, ReusableView {
    
    let button = UIButton(type: .Custom)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.textAlignment = .Center
        contentView.addSubview(button)
        
        let views = ["button": button]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-1-[button]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-1-[button]|", options: [], metrics: nil, views: views))
    }
    
}

protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

extension UICollectionView {
    
    func register<T: UICollectionViewCell where T: ReusableView>(_: T.Type) {
        registerClass(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell where T: ReusableView>(forIndexPath indexPath: NSIndexPath) -> T {
        guard let cell = dequeueReusableCellWithReuseIdentifier(T.defaultReuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
    
}

extension UIColor {
    
    func toImage() -> UIImage {
        return UIImage(color: self)
    }
    
}

extension UIImage {
    
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        var rect = CGRectZero
        rect.size = size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }
    
}
