//
//  NSLayoutConstraintExtension.swift
//  homework-7
//
//  Created by sergey on 02.06.2023.
//

import UIKit

extension NSLayoutConstraint  {
    
    /// Pins v1 to edges of v2
    /// - Parameters:
    ///   - v1: subview of v2
    ///   - v2: superview of v1
    ///   - toSafeArea: whether to pin to safe area or not
    ///   - constant: constant added to constraint
    static func snapToBounds(_ v1: UIView, _ v2: UIView, constant: CGFloat = 0, toSafeArea: Bool = true) {
        v1.translatesAutoresizingMaskIntoConstraints = false
        switch toSafeArea {
        case true:
            snap([
                v1.leadingAnchor,
                v1.trailingAnchor
            ], to: [
                v2.safeAreaLayoutGuide.leadingAnchor,
                v2.safeAreaLayoutGuide.trailingAnchor
            ], constants: .init(repeating: constant, count: 2))
            snap([
                v1.topAnchor,
                v1.bottomAnchor
            ], to: [
                v2.safeAreaLayoutGuide.topAnchor,
                v2.safeAreaLayoutGuide.bottomAnchor
            ], constants: .init(repeating: constant, count: 2))
        case false:
            snapEqual(v1, v2, [.leading,.trailing,.top,.bottom], constant: constant)
        }
    }
    
    /// Pins attributes of v1 to same attributes of v2
    /// - Parameters:
    ///   - v1: subview of v2
    ///   - v2: superview of v1
    ///   - attributes: array of NSLayoutConstraint attributes
    ///   - constant: constant added to constraint
    static func snapEqual(_ v1: UIView, _ v2: UIView,
                          _ attributes: [NSLayoutConstraint.Attribute],
                          constant: CGFloat = 0,
                          toSafeArea: Bool = true) {
        v1.translatesAutoresizingMaskIntoConstraints = false
        var constant = constant
        let item2 = toSafeArea ? v2.safeAreaLayoutGuide : v2
        var constraints: [NSLayoutConstraint] = []
        attributes.forEach { attribute in
            switch attribute {
            case .trailing,.trailingMargin,.bottom,.bottomMargin: constant.negate()
            default: break
            }
            let constraint = NSLayoutConstraint(
                item: v1,
                attribute: attribute,
                relatedBy: .equal,
                toItem: item2,
                attribute: attribute,
                multiplier: 1,
                constant: constant
            )
            constraints.append(constraint)
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Pins n-th anchor of lAnchors to n-th anchor or rAnchors
    /// - Parameters:
    ///   - lAnchors: array of NSLayoutAnchor's of left
    ///   - rAnchors: array of NSLayoutAnchor's
    ///   - constants: constant added to n-th constraint
    /// - Note: Order of anchors matters.
    /// 
    /// Make sure that translatesAutoresizingMaskIntoConstraints is set to false!
    static func snap<T>(_ lAnchors: [NSLayoutAnchor<T>],
                        to rAnchors: [NSLayoutAnchor<T>],
                        constants: [CGFloat]? = nil) where T: AnyObject  {
        guard lAnchors.count == rAnchors.count else {
            return
        }
        var localCostants = [CGFloat](repeating: 0, count: lAnchors.count)
        if let constants = constants {
            guard constants.count == rAnchors.count else {
                return
            }
            localCostants = constants
        }
        var constraints: [NSLayoutConstraint] = []
        for i in 0..<lAnchors.count {
            let constraint = lAnchors[i].constraint(equalTo: rAnchors[i],
                                                    constant: localCostants[i])
            constraints.append(constraint)
        }
        NSLayoutConstraint.activate(constraints)
    }
}
