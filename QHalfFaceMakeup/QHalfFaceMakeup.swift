//
//  QHalfFaceMakeup1.swift
//  QHalfFaceMakeup
//
//  Created by 009 on 2018/2/9.
//  Copyright © 2018年 qyfeng. All rights reserved.
//

import UIKit

class QHalfFaceMakeup: NSObject {
    var superVC: UIViewController!
    var faceView: UIView!
    var halfFace: QHalfFaceMakeupVC!
    init(_ vc: UIViewController, _ face: UIView) {
        super.init()
        superVC = vc
        faceView = face
        halfFace = QHalfFaceMakeupVC()
    }

    /// 调整face有轴坐标，default = 0（紧挨导航栏），负值往上反之向下
    var adjustOS: CGFloat! = 0 {
        didSet {
            halfFace.adjustOS = adjustOS
        }
    }
    func show() {
        halfFace.modalPresentationStyle = .overFullScreen
        superVC.present(halfFace, animated: false) {
            self.halfFace.addFace(self.faceView)
            self.halfFace.show()
        }
    }
    func dismiss() {
        halfFace.close()
    }
}
class QHalfFaceMakeupVC: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    private let keyWindow = UIApplication.shared.keyWindow

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        self.view.addSubview(baseView)
        baseView.addSubview(topView)
        baseView.bringSubview(toFront: topView)

        baseView.addGestureRecognizer(closePanGesture)
    }
    func addFace(_ face: UIView) {
        var bottom: CGFloat = 64
        if screenHeight == 812 {
            bottom = 88
        }
        face.frame = CGRect(x: 0, y: topView.frame.size.height, width: baseView.frame.size.width, height: baseView.frame.size.height - bottom - topView.frame.size.height)
        if face is UIScrollView {
            (face as? UIScrollView)?.delegate = self
        }
        baseView.addSubview(face)
        baseView.sendSubview(toBack: face)
    }

    lazy var baseView: UIView! = {
        let baseView = UIView(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight))
        baseView.backgroundColor = .white
        roundedCorners(cornerRadius: 15, rectCorner: [.topLeft, .topRight], desView: baseView)
        return baseView
    }()
    private lazy var closePanGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panClose(_:)))
        panGesture.delegate = self
        return panGesture
    }()
    private lazy var topView: UIView! = {
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        topView.backgroundColor = .white
        topView.layer.shadowColor = UIColor.white.cgColor
        topView.layer.shadowOpacity = 1.0
        topView.layer.shadowOffset = CGSize(width: 0, height: 15)
        topView.layer.shadowRadius = 7.2
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 44)
        button.center = topView.center
        button.setBackgroundImage(UIImage(named: "down_arrow"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        topView.addSubview(button)
        return topView
    }()
    var adjustOS: CGFloat! = 0 {
        didSet {
            print(adjustOS)
            baseView.frame.size.height += -(adjustOS)
        }
    }
    /// 显示
    open func show() {
        var top: CGFloat = 64
        if screenHeight == 812 {
            top = 88
        }
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: {
            self.baseView.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.size.height + top + self.adjustOS)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }, completion: { (finish: Bool) in

        })
    }
    /// 关闭
    @objc func close() {
        UIView.animate(withDuration: 0.7) {
            self.view.backgroundColor = .clear
        }
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: {
            self.baseView.transform = CGAffineTransform.identity
        }, completion: { (finish: Bool) in
            self.dismiss(animated: false, completion: nil)
        })
    }

    // MARK: - 滑动关闭页面
    @objc private func panClose(_ panGesture: UIPanGestureRecognizer) {
        var top: CGFloat = 64
        if screenHeight == 812 {
            top = 88
        }
        let offsetY = panGesture.translation(in: panGesture.view).y
        if offsetY >= 0 {
            UIView.animate(withDuration: 0.13, animations: {
                self.baseView.transform = CGAffineTransform(translationX: 0, y: -self.baseView.frame.size.height + top + offsetY)
            })
        }
        if panGesture.state == .ended || panGesture.state == .failed || panGesture.state == .cancelled {
            if offsetY >= (baseView.frame.size.height - top)/4 {
                close()
            } else {
                show()
            }
        }
    }
    // MARK: - 手势处理
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let className: AnyClass = gestureRecognizer.classForCoder
        if touch.view != self.view {
            if NSStringFromClass(className) == "UITapGestureRecognizer" {
                return false
            }
        }
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is UIScrollView {
            if gestureRecognizer.state == .began && (otherGestureRecognizer.view as! UIScrollView).contentOffset.y <= 0 {
                (otherGestureRecognizer.view as! UIScrollView).bounces = false
                return true
            }
            (otherGestureRecognizer.view as! UIScrollView).bounces = true
        }
        return false
    }
    /// 设置指定角的圆角
    func roundedCorners(cornerRadius: CGFloat?, rectCorner: UIRectCorner?, desView: UIView) {
        let path = UIBezierPath(roundedRect: desView.bounds, byRoundingCorners: rectCorner!, cornerRadii: CGSize(width: cornerRadius!, height: cornerRadius!))
        let layer = CAShapeLayer()
        layer.frame = desView.bounds
        layer.path = path.cgPath
        desView.layer.mask = layer
    }
}
