# QHalfFaceMakeup
封装弹出页面，可跟随手势滑动消失

近来无事，就写了个弹出页面的控件玩，类似微信读书中的讲书播放页面。动画弹出页面后可跟随手势下滑动消失，上效果（图1是demo效果，图2是项目中应用效果）。
<p align="center">
<img src="https://github.com/qyfeng009/QHalfFaceMakeup/blob/master/demo_show.gif" width="266" height="500"/>
<img src="https://github.com/qyfeng009/QHalfFaceMakeup/blob/master/user_show.gif" width="266" height="500"/>
</p>


#### 使用
使用超简单的
```swift
    let tbv = TableView(frame: self.view.frame, style: .plain)
    let halfFace = QHalfFaceMakeup(self, tbv)
    halfFace.adjustOS = 57
    halfFace.show()
```
#### 思路
控件主要由两个部分组成： QHalfFaceMakeup 和  QHalfFaceMakeupVC 。
###### QHalfFaceMakeup 是最外层，暴露接口，负责初始化控件和弹出内容页面。
>重点：弹出页面的操作这里采用模态推出页面，并且 modalPresentationStyle = .overFullScreen 。
>>开始时的想法是：采用弹出 View 作为容器，经过尝试不管是把 View 加载 viewController 上，还是加在 window 上都没有达到我想要的效果，遂弃之。
``` swift
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
```
###### QHalfFaceMakeupVC 是重点，是展示内容的容器，负责处理展示 View 的基础样式和布局、手势交互等。
1.布局：view -> baseView -> (topView & faceView)
* view 是 QHalfFaceMakeupVC 自带 view 位于最底层，添加有点击手势，点击释放页面，颜色半透明。
* baseView 承载展示效果和其他（比如圆角之类），其添加有平移手势，滑动平移消失效果由此承担。
* topView 是顶部消失按钮；faceView 是主要展示内容，由外部传入，控件不处理任何业务代码。
2.手势处理，若传入的是 scrollView 或其子类 必定会和 baseView 的平滑手势冲突
```swift
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
```
3.平滑消失操作
```
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
```
至此就不贴代码，也没人看。想追究的小伙伴可以点击 [QHalfFaceMakeup](https://github.com/qyfeng009/QHalfFaceMakeup)追查到底！
