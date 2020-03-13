//
//  PractoBottomSheetViewController.swift
//  BottomSheetController
//
//  Created by Pavan Powani on 13/03/20.
//  Copyright © 2020 Practo. All rights reserved.
//

import UIKit

@objc public class BottomSheetViewController: UIViewController {
    fileprivate lazy var bottomSheetContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.layer.cornerRadius = 12
        return view
    }()

    fileprivate var contentVC: UIViewController?
    fileprivate var didDismiss: ((Bool) -> UIViewController?)?

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(bottomSheetContainerView)
        self.view.bringSubview(toFront: bottomSheetContainerView)
        setupConstraints()
        embedContent()
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
    }
}
