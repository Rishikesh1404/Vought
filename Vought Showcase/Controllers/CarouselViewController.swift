//
//  CarouselViewController.swift
//  Vought Showcase
//
//  Created by Burhanuddin Rampurawala on 06/08/24.
//

import Foundation
import UIKit

final class CarouselViewController: UIViewController, SegmentedProgressBarDelegate {

    /// Container view for the carousel
    @IBOutlet private weak var containerView: UIView!
    
    private var segmentedProgressBar: SegmentedProgressBar?
    private var isAnimationHandling = false
    
    /// Left tap area view
    @IBOutlet private weak var leftTapView: UIView!
    
    /// Right tap area view
    @IBOutlet private weak var rightTapView: UIView!

    /// Page view controller for carousel
    private var pageViewController: UIPageViewController?
    
    /// Carousel items
    private var items: [CarouselItem] = []
    
    /// Current item index
    private var currentItemIndex: Int = 0 {
        didSet {
            // Update the view for the current item
            updateViewForCurrentItem()
        }
    }
    
    /// Initializer
    /// - Parameter items: Carousel items
    public init(items: [CarouselItem]) {
        self.items = items
        super.init(nibName: "CarouselViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPageViewController()
        initSegmentedProgressBar()
        initUI()
        
        DispatchQueue.main.async {
                // Make sure the layout is complete before starting the animation
                self.segmentedProgressBar?.startAnimation()
            }
    }
    
    private func initUI() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        // Set up tap gesture recognizers for left and right views
        let leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(showPreviousMember))
        leftTapView.addGestureRecognizer(leftTapGesture)
        leftTapGesture.numberOfTapsRequired = 1
        leftTapGesture.cancelsTouchesInView = false
        
        let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(showNextMember))
        rightTapView.addGestureRecognizer(rightTapGesture)
        rightTapGesture.numberOfTapsRequired = 1
        rightTapGesture.cancelsTouchesInView = false
        
    }
    
    /// Initialize page view controller
    private func initPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController?.dataSource = nil // Disable swipe gestures
        pageViewController?.delegate = self
        pageViewController?.setViewControllers([viewControllerForPage(at: currentItemIndex)], direction: .forward, animated: true)
        
        if let pageVC = pageViewController {
            addChild(pageVC)
            containerView.addSubview(pageVC.view)
            pageVC.view.frame = containerView.bounds
            pageVC.didMove(toParent: self)
        }
    }
    
    /// Initialize segmented progress bar
    private func initSegmentedProgressBar() {
        segmentedProgressBar = SegmentedProgressBar(numberOfSegments: items.count, duration: 5.0)
        segmentedProgressBar?.delegate = self
        segmentedProgressBar?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedProgressBar!)
        
        NSLayoutConstraint.activate([
            segmentedProgressBar!.topAnchor.constraint(equalTo: view.topAnchor, constant: 55), // Extend to the top of the screen
            segmentedProgressBar!.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedProgressBar!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedProgressBar!.heightAnchor.constraint(equalToConstant: 4)
        ])
        
       

    }
    
    
    
    private func updateViewForCurrentItem() {
        // Update your custom view with the new item data if needed
    }
    
    private func viewControllerForPage(at index: Int) -> UIViewController {
        return items[index].getController()
    }
    
    func segmentedProgressBarChangedIndex(index: Int) {
        let direction: UIPageViewController.NavigationDirection = index > currentItemIndex ? .forward : .reverse
        pageViewController?.setViewControllers([viewControllerForPage(at: index)], direction: direction, animated: true)
        currentItemIndex = index
    }
    
    func segmentedProgressBarFinished() {
        if !isAnimationHandling {
            isAnimationHandling = true
            showNextMember()
        }
    }
    
    @objc private func showNextMember() {
        currentItemIndex = (currentItemIndex + 1) % items.count
        segmentedProgressBar?.skip()
    }
    
    @objc private func showPreviousMember() {
        currentItemIndex = (currentItemIndex - 1 + items.count) % items.count
        segmentedProgressBar?.rewind()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CarouselViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first, let index = items.firstIndex(where: { $0.getController() == visibleViewController }) {
            currentItemIndex = index
        }
    }
}
