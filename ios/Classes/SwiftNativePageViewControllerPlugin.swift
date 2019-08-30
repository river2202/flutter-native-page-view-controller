import Flutter
import UIKit

public class SwiftNativePageViewControllerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_page_view_controller", binaryMessenger: registrar.messenger())
        let instance = SwiftNativePageViewControllerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    var controllers = [UIViewController]()
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "show":
            SwiftNativePageViewControllerPlugin.show(create())
            result("iOS " + UIDevice.current.systemVersion)
        case "close":
            controllers.removeAll()
            SwiftNativePageViewControllerPlugin.hide()
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }
    
    private func create() -> UIPageViewController {
        let pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        
        controllers.removeAll()
        controllers = [1,2,3].map { i in
            return createFlutterPageView(index: i)
        }
        
        pageController.setViewControllers([controllers[0]], direction: .forward, animated: false)
        
        return pageController
    }
    
    private func createFlutterPageView(index: Int) -> UIViewController {
        let flutterPageView = FlutterViewController()
        flutterPageView.setInitialRoute("page\(index)")
        
        let pageChannel = FlutterMethodChannel(name: "native_page_view_controller", binaryMessenger: flutterPageView)
        pageChannel.setMethodCallHandler(handle)

        return flutterPageView
    }

    private func createPageViewController(index: Int) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = randomColor()

        let labeView = UILabel(frame: vc.view.frame)
        labeView.numberOfLines = 0
        labeView.text = """
        Page \(index)

        UIPageViewController pageCurl demo

        Navigate between views via a page curl transition.
        """
        vc.view.addSubview(labeView)

        let closeButton = UIButton(frame: CGRect(x: 10, y: 100, width: 50, height: 50))
        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(tapClose), for: .touchUpInside)

        vc.view.addSubview(closeButton)

        return vc
    }

    @objc func tapClose(sender: UIButton!) {
        SwiftNativePageViewControllerPlugin.hide()
    }
}

extension SwiftNativePageViewControllerPlugin {
    
    private static var toolWindowLayer: UIWindow = {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        window.windowLevel = UIWindow.Level(integerLiteral: 999)
        window.rootViewController = UIViewController()
        
        return window
    }()
    
    public static func show(_ viewController: UIViewController) {
        if toolWindowLayer.isHidden {
            toolWindowLayer.makeKeyAndVisible()
            toolWindowLayer.rootViewController?.present(viewController, animated: true, completion: nil)
        }
    }
    
    public static func hide() {
        toolWindowLayer.rootViewController?.dismiss(animated: true) {
            toolWindowLayer.isHidden = true
        }
    }
}


extension SwiftNativePageViewControllerPlugin: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // UIPageViewControllerDataSource
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController) {
            if index > 0 {
                return controllers[index - 1]
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController) {
            if index < controllers.count - 1 {
                return controllers[index + 1]
            } else {
                return nil
            }
        }
        
        return nil
    }
}

extension SwiftNativePageViewControllerPlugin {
    func randomCGFloat() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    
    func randomColor() -> UIColor {
        return UIColor(red: randomCGFloat(), green: randomCGFloat(), blue: randomCGFloat(), alpha: 1)
    }
}

