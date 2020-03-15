//
//  PractoBottomSheetViewController.swift
//  BottomSheetController
//
//  Created by Pavan Powani on 13/03/20.
//  Copyright © 2020 Practo. All rights reserved.
//

import UIKit

@available(iOS 11.0, *)
@objc public class BottomSheetViewController: UIViewController {

    // MARK: Animation properties
    fileprivate var currentState: State = .collapsed

    let popupOffset: CGFloat = (UIScreen.main.bounds.height) / 2

    lazy var animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, timingParameters: UISpringTimingParameters(dampingRatio: 0.5, initialVelocity: .zero))

    lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(handlePan(recognizer:)))
        recognizer.delegate = self
        return recognizer
    }()

    // MARK: Content properties
    fileprivate lazy var bottomSheetContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.layer.cornerRadius = 12
        return view
    }()

    fileprivate var contentVC: UIViewController?
    fileprivate var didDismiss: ((Bool) -> UIViewController?)?


    //MARK: Methods
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(bottomSheetContainerView)
        self.view.bringSubview(toFront: bottomSheetContainerView)
        setupConstraints()
        embedContent()
        self.bottomSheetContainerView.addGestureRecognizer(panRecognizer)
    }

    override public func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: self.view, duration: 0.2, options: .curveLinear, animations: {
            self.setupBackground()
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = didDismiss?(true)
    }

    public static func getController(with content: UIViewController) -> BottomSheetViewController {
        let controller = BottomSheetViewController()
        controller.contentVC = content
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }

    fileprivate func setupConstraints() {
        let leading = NSLayoutConstraint(item: bottomSheetContainerView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: bottomSheetContainerView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: bottomSheetContainerView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: bottomSheetContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.3)

        NSLayoutConstraint.activate([leading, trailing, bottom, height])
    }

    fileprivate func setupBackground() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bgTapped(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc fileprivate func bgTapped(_ sender: Any) {
        UIView.transition(with: self.view, duration: 0.2, options: .curveLinear, animations: {
            self.view.backgroundColor = .white
            self.view.layoutIfNeeded()
        }, completion: { (_) in
            self.currentState = .collapsed
            self.dismiss(animated: true, completion: nil)
        })
    }

    fileprivate func embedContent() {
        guard let vc = contentVC else { return }
        let maxHeight = (self.view.frame.height * 0.8)
        vc.willMove(toParentViewController: self)
        let heightValue = (vc.view.frame.size.height > maxHeight) ? maxHeight : vc.view.frame.size.height
        NSLayoutConstraint.activate([NSLayoutConstraint(item: bottomSheetContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: heightValue)])
        vc.view.frame = bottomSheetContainerView.bounds
        bottomSheetContainerView.addSubview(vc.view)
        self.addChildViewController(vc)
        vc.didMove(toParentViewController: self)
        self.currentState = .collapsed
    }
}

fileprivate enum State {
    case expanded
    case collapsed

    var change: State {
        switch self {
        case .expanded: return .collapsed
        case .collapsed: return .expanded
        }
    }
}

// MARK: PanGesture Handling
@available(iOS 11.0, *)
extension BottomSheetViewController: UIGestureRecognizerDelegate {

    fileprivate func toggle(to state: State) {
        switch state {
            case .collapsed:
                collapse(state: state)
            case .expanded:
                expand(state: state)
        }
    }

    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        guard !animator.isRunning else { return }
        var animationProgress: CGFloat = 0
        switch recognizer.state {
            case .began:
                toggle(to: currentState.change)
                animator.pauseAnimation()
                animationProgress = animator.fractionComplete
            case .changed:
                let translation = recognizer.translation(in: self.view)
                var fraction = -translation.y / popupOffset

                if currentState == .expanded { fraction *= -1 }
                if animator.isReversed { fraction *= -1 }
                animator.fractionComplete = fraction + animationProgress
            case .ended:
                let yVelocity = recognizer.velocity(in: bottomSheetContainerView).y
                let shouldClose = yVelocity > 0

                if yVelocity == 0 {
                    animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                    break
                }

                switch currentState {
                case .expanded:
                    if !shouldClose && !animator.isReversed {
                        animator.isReversed = !animator.isReversed
                    }
                    if shouldClose && animator.isReversed { animator.isReversed = !animator.isReversed }
                case .collapsed:
                    if shouldClose && !animator.isReversed { animator.isReversed = !animator.isReversed }
                    if !shouldClose && animator.isReversed { animator.isReversed = !animator.isReversed }
                }
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            default: break
        }
    }

    fileprivate func expand(state: State) {
        for constraint in  self.bottomSheetContainerView.constraints {
            if constraint.firstAttribute == .height {
                NSLayoutConstraint.deactivate([constraint])
            }
        }
        let height = NSLayoutConstraint(item: bottomSheetContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.view.frame.size.height * 0.8)
        NSLayoutConstraint.activate([height])

        animator.addAnimations {
            self.view.layoutIfNeeded()
        }

        animator.addCompletion { (position) in
            switch position {
                case .start:
                    self.currentState = state.change
                case .end:
                    self.currentState = state
                default: break
            }
        }

        animator.startAnimation()
    }

    fileprivate func collapse(state: State) {
        for constraint in  self.bottomSheetContainerView.constraints {
            if constraint.firstAttribute == .height {
                NSLayoutConstraint.deactivate([constraint])
            }
        }
        let height = NSLayoutConstraint(item: bottomSheetContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.view.frame.size.height * 0.3)
        NSLayoutConstraint.activate([height])

        animator.addAnimations {
            self.view.layoutIfNeeded()
        }

        animator.addCompletion { (position) in
            switch position {
                case .start:
                    self.currentState = state.change
                case .end:
                    self.currentState = state
                default: break
            }
        }

        animator.startAnimation()
    }

    fileprivate func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return abs((panRecognizer.velocity(in: panRecognizer.view)).y) > abs((panRecognizer.velocity(in: panRecognizer.view)).x)
    }

}
