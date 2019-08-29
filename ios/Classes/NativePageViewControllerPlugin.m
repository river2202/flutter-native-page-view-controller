#import "NativePageViewControllerPlugin.h"
#import <native_page_view_controller/native_page_view_controller-Swift.h>

@implementation NativePageViewControllerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativePageViewControllerPlugin registerWithRegistrar:registrar];
}
@end
