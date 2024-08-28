//
//  ButcherNewCarouselItem.swift
//  Vought Showcase
//
//  Created by Rishikesh Reddy on 27/08/24.
//

import UIKit


final class ButcherCarouselItem: CarouselItem {
    private var viewController: UIViewController?
    
    /// Get controller
    /// - Returns: View controller
    func getController() -> UIViewController {
        // Check if view controller is already created
        // If not, create new view controller
        // else return the existing view controller
        guard let viewController = viewController else {
            viewController = ImageViewController(imageName: "butcher")
            return viewController!
        }
        return viewController
    }
}
