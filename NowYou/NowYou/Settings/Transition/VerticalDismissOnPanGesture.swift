//  Created by David Seek on 11/21/16.
//  Copyright © 2016 David Seek. All rights reserved.

import UIKit

class VerticalDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval {
            
            return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let sourceController = transitionContext.viewController(forKey: .from),
            let destinationController = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let screenBounds = UIScreen.main.bounds
        
        let xPosition = destinationController.view.bounds.origin.x
        var yPosition = destinationController.view.bounds.origin.y - screenBounds.height

        sourceController.view.alpha = 1.0
        destinationController.view.alpha = 0.0
        destinationController.view.frame = CGRect(
            x: xPosition,
            y: yPosition,
            width: destinationController.view.bounds.width,
            height: destinationController.view.bounds.height)
        
        let containerView = transitionContext.containerView
        
        containerView.insertSubview(
            destinationController.view, belowSubview:
            sourceController.view)

        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                
                sourceController.view.frame = finalFrame
                destinationController.view.alpha = 1
//                sourceController.view.alpha = 0
//                xPosition = destinationController.view.bounds.origin.x
                yPosition = destinationController.view.bounds.origin.y
                destinationController.view.frame = CGRect(
                    x: xPosition,
                    y: yPosition,
                    width: destinationController.view.bounds.width,
                    height: destinationController.view.bounds.height)
                
            }, completion: { _ in
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
    }
}
