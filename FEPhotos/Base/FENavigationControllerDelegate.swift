//
//  FENavigationControllerDelegate.swift
//  FEPhotos
//
//  Created by 罗祖根 on 2019/6/20.
//  Copyright © 2019 罗祖根. All rights reserved.
//

import UIKit

class FENavigationControllerDelegate: NSObject, UINavigationControllerDelegate{
    internal func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
   
        if (fromVC.conforms(to: FEAnimatorDelegate.self) && toVC.conforms(to: FEAnimatorDelegate.self)) {
            let avc = fromVC as? FEAnimatorDelegate
            let bvc = toVC as? FEAnimatorDelegate
            if let a = avc?.animatorType(), let b = bvc?.animatorType() {
                if (a == .spread && b == .spread) {
                    return FEPhotoCollectionViewAnimator(operation: operation)
                } else {
                    
                }
            }
        }
        return nil
//        let animator = CKWaveCollectionViewAnimator()
//        animator.animationDuration = 0.7
//
//        if operation != UINavigationControllerOperation.push {
//
//            animator.reversed = true
//        }
//
//        return animator
    }
}