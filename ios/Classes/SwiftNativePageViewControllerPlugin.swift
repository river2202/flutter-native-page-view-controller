import Flutter
import UIKit

public class SwiftNativePageViewControllerPlugin: NSObject, FlutterPlugin {
    
    enum TransitionStyle: Int {
        case none
        case slideUp
        
        static func parse(_ value: Any) -> TransitionStyle {
            return .none
        }
    }
    
    static let channelName = "native_page_view_controller"
    
    enum PluginError {
        case general
    }
    
    struct Parameters {
        
        let pageNumber: Int
        let pageRouterName: String
        let disableNativeTap: Bool
        let transitionStyle: TransitionStyle
        
        static func parse(arguments: Any?) -> Parameters? {
            if let arguments = arguments as? [Any],
                arguments.count >= 2,
                let pageNumber = arguments[0] as? Int,
                let pageRouterName = arguments[1] as? String {
                
                let transitionStyle = TransitionStyle.parse(arguments[2])
                let disableNativeTap = (arguments[3] as? Bool) ?? false
                
                return Parameters(
                    pageNumber: pageNumber,
                    pageRouterName: pageRouterName,
                    disableNativeTap: disableNativeTap,
                    transitionStyle: transitionStyle
                )
            }
            
            return nil
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftNativePageViewControllerPlugin(flutterAppMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: instance.flutterAppChannel)
    }
    
    let flutterAppChannel: FlutterMethodChannel
    var controllers = [UIViewController]()
    
    public init(flutterAppMessenger: FlutterBinaryMessenger) {
         flutterAppChannel = FlutterMethodChannel(name: SwiftNativePageViewControllerPlugin.channelName, binaryMessenger: flutterAppMessenger)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
            
        case "show":
            if let parameters = Parameters.parse(arguments: call.arguments) {
                SwiftNativePageViewControllerPlugin.show(
                    create(with: parameters)
                )
            } else {
                handleError()
            }
            result(nil)
            
        case "hide":
            hide()
            result(nil)
            
        default:
            result(nil)
        }
    }
    
    func handlePageMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
            
        case "hide":
            hide()
            result(nil)
            
        case "load":
            flutterAppChannel.invokeMethod("load", arguments: call.arguments, result: result)
            
        default:
            result(nil)
        }
    }
    
    private func hide() {
        SwiftNativePageViewControllerPlugin.hide()
        controllers.removeAll()
    }
    
    private func create(with parameters: Parameters) -> UIPageViewController {
        let pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        pageController.eanbleTapRecognizer(!parameters.disableNativeTap)
        
        controllers.removeAll()
        controllers = Array(0..<parameters.pageNumber).map { i in
            return createFlutterPageView(index: i, pageRouterName: parameters.pageRouterName)
        }
        
        pageController.setViewControllers([controllers[0]], direction: .forward, animated: false)
        
        return pageController
    }
    
    private func createFlutterPageView(index: Int, pageRouterName: String) -> UIViewController {
        let flutterPageView = FlutterViewController()
        flutterPageView.setInitialRoute("\(pageRouterName)?\(index)")
        
        let pageChannel = FlutterMethodChannel(name: SwiftNativePageViewControllerPlugin.channelName, binaryMessenger: flutterPageView)
        pageChannel.setMethodCallHandler(handlePageMessage)

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
    
    private static func show(_ viewController: UIViewController, transitionStyle: TransitionStyle = .none) {
        if toolWindowLayer.isHidden {
            toolWindowLayer.makeKeyAndVisible()
            
            switch transitionStyle {
            case .none:
                toolWindowLayer.rootViewController?.present(viewController, animated: false, completion: nil)
            case .slideUp:
                toolWindowLayer.rootViewController?.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    private static func hide() {
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

extension UIPageViewController {
    func eanbleTapRecognizer(_ enable: Bool) {
        let gestureRecognizers = self.gestureRecognizers
        
        gestureRecognizers.forEach { recognizer in
            if recognizer.isKind(of: UITapGestureRecognizer.self) {
                recognizer.isEnabled = enable
            }
        }
    }
}
