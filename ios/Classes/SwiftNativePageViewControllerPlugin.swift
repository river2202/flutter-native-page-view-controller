import Flutter
import UIKit

public class SwiftNativePageViewControllerPlugin: NSObject, FlutterPlugin {
    
    enum PluginError {
        case general
    }
    
    static let channelName = "native_page_view_controller"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        let instance = SwiftNativePageViewControllerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    var controllers = [UIViewController]()
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "show":
            if let arguments = call.arguments as? [AnyObject],
                arguments.count >= 2,
                let pageNumber = arguments[0] as? Int,
                let pageRouterName = arguments[1] as? String {
                
                SwiftNativePageViewControllerPlugin.show(
                    create(pageNumber: pageNumber, pageRouterName: pageRouterName)
                )
                
            } else {
                handleError()
            }
            
            result(nil)
        case "hide":
            controllers.removeAll()
            SwiftNativePageViewControllerPlugin.hide()
            result(nil)
        default:
            result(nil)
        }
    }
    
    private func create(pageNumber: Int, pageRouterName: String) -> UIPageViewController {
        let pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        
        controllers.removeAll()
        controllers = Array(0..<pageNumber).map { i in
            return createFlutterPageView(index: i, pageRouterName: pageRouterName)
        }
        
        pageController.setViewControllers([controllers[0]], direction: .forward, animated: false)
        
        return pageController
    }
    
    private func createFlutterPageView(index: Int, pageRouterName: String) -> UIViewController {
        let flutterPageView = FlutterViewController()
        flutterPageView.setInitialRoute("\(pageRouterName)?\(index)")
        
        let pageChannel = FlutterMethodChannel(name: SwiftNativePageViewControllerPlugin.channelName, binaryMessenger: flutterPageView)
        pageChannel.setMethodCallHandler(handle)

        return flutterPageView
    }
    
    private func handleError(error: PluginError = .general) {
        
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

