import UIKit

extension UIViewController {
    func add(_ child: UIViewController, to container: UIView? = nil) {
        addChild(child)
        let target = container ?? view!
        child.view.frame = target.bounds
        target.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
