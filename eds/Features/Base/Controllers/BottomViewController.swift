//
//  MenuViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/26.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  方案来源于网络，底部弹出框

import UIKit



class BottomViewController: UIViewController {

    lazy var backdropView: UIView = {
        let bdView = UIView(frame: self.view.bounds)
        bdView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        return bdView
    }()

    let contentView = UIView()
    let titleLabel = UILabel()
    var viewHeight = UIScreen.main.bounds.height / 3
    var isPresenting = false

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {

        view.backgroundColor = .clear
        view.addSubview(backdropView)
        view.addSubview(contentView)
        contentView.backgroundColor = .white
        contentView.edgesToSuperview(excluding: .top)
        contentView.height(viewHeight)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BottomViewController.handleTap(_:)))
        backdropView.addGestureRecognizer(tapGesture)

        let dismissButton = UIButton()
        dismissButton.tintColor = .systemGray
        dismissButton.addTarget(self, action: #selector(handleTap(_:)), for: .touchDown)
        dismissButton.setBackgroundImage(UIImage(systemName: "chevron.compact.down"), for: .normal)
        contentView.addSubview(dismissButton)
        dismissButton.topToSuperview()
        dismissButton.centerXToSuperview()
        dismissButton.height(edsIconSize)
        dismissButton.width(edsIconSize)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        contentView.addSubview(titleLabel)
        titleLabel.centerXToSuperview()
        titleLabel.topToBottom(of: dismissButton, offset: edsMinSpace)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension BottomViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else { return }
        isPresenting = !isPresenting

        if isPresenting == true {
            containerView.addSubview(toVC.view)

            contentView.frame.origin.y += viewHeight
            backdropView.alpha = 0

            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.contentView.frame.origin.y -= self.viewHeight
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
                self.contentView.frame.origin.y += self.viewHeight
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
