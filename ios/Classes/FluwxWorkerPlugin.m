#import "FluwxWorkerPlugin.h"
#import "WWKApi.h"
#import "NSStringWrapper.h"
#import "FluwxStringUtil.h"


NSString *const keySource = @"source";
NSString *const fluwxKeyThumbnail = @"thumbUrl";
NSString *const fluwxKeyCompressThumbnail = @"compressThumbnail";
NSString *const fluwxKeyPackage = @"?package=";
NSUInteger defaultThumbnailSize = 32 * 1024;

@interface FluwxWorkerPlugin ()<WWKApiDelegate>

@property (nonatomic, assign) BOOL isWWXRegistered;
@property (nonatomic, strong) NSObject <FlutterPluginRegistrar> *fluwxRegistrar;


@end
@implementation FluwxWorkerPlugin

FlutterMethodChannel *channel;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"fluwx_worker"
            binaryMessenger:[registrar messenger]];
  FluwxWorkerPlugin* instance = [[FluwxWorkerPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        _fluwxRegistrar = registrar;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  // 注册
  if ([@"registerApp" isEqualToString:call.method]) {
    if (self.isWWXRegistered) {
      result(@(YES));
    }else {
      NSString *schema = call.arguments[@"schema"]; 
      NSString *corpId = call.arguments[@"corpId"];
      NSString *agentId = call.arguments[@"agentId"];
      self.isWWXRegistered = [WWKApi registerApp:schema corpId:corpId agentId:agentId];
      NSLog(@"%@", (self.isWWXRegistered ? @"注册成功" : @"注册失败"));
      result(@(self.isWWXRegistered));
    }
  }else if ([@"isWeChatInstalled" isEqualToString:call.method]) {
    // 检测是否安装微信
    if (!self.isWWXRegistered) {
      result([FlutterError errorWithCode:@"wwkapi not configured" message:@"please config  wwkapi first" details:nil]);
    }else{
      BOOL isAppInstalled =  [WWKApi isAppInstalled];
      NSLog(@"%@", (isAppInstalled ? @"已安装" : @"未安装"));
      result(@(isAppInstalled));
    }
  }else if ([@"sendAuth" isEqualToString:call.method]) {
    // 授权
    NSString *state = call.arguments[@"state"];
    WWKSSOReq *req = [[WWKSSOReq alloc] init];
    req.state = state;

    [WWKApi sendReq:req];
    BOOL done = [WWKApi sendReq:req];

    result(@(done));
  }else if ([@"shareText" isEqualToString:call.method]) {
    // 分享文字
    WWKSendMessageReq *req = [[WWKSendMessageReq alloc] init];
    WWKMessageTextAttachment *attachment = [[WWKMessageTextAttachment alloc] init];
    attachment.text = call.arguments[@"text"];
    req.attachment = attachment;
    BOOL isSuccess = [WWKApi sendReq:req];
    result(@(isSuccess)); 
  } else if ([@"shareImage" isEqualToString:call.method]) {
    // 分享图片
    WWKSendMessageReq *req = [[WWKSendMessageReq alloc] init];
    WWKMessageImageAttachment *attachment = [[WWKMessageImageAttachment alloc] init];
    attachment.filename = call.arguments[@"fileName"];
    attachment.path = call.arguments[@"filePath"];
    req.attachment = attachment;
    BOOL isSuccess = [WWKApi sendReq:req];
    result(@(isSuccess));
  }else if ([@"shareFile" isEqualToString:call.method]) {
    // 分享文件
    WWKSendMessageReq *req = [[WWKSendMessageReq alloc] init];
    WWKMessageFileAttachment *attachment = [[WWKMessageFileAttachment alloc] init];
    attachment.filename = call.arguments[@"fileName"];
    attachment.path = call.arguments[@"filePath"];
    req.attachment = attachment;
    BOOL isSuccess = [WWKApi sendReq:req];
    result(@(isSuccess));
  }else if ([@"shareVideo" isEqualToString:call.method]) {
    // 分享视频
    WWKSendMessageReq *req = [[WWKSendMessageReq alloc] init];
    WWKMessageVideoAttachment *attachment = [[WWKMessageVideoAttachment alloc] init];
    attachment.filename = call.arguments[@"fileName"];
    attachment.path = call.arguments[@"filePath"];
    req.attachment = attachment;
    BOOL isSuccess = [WWKApi sendReq:req];
    result(@(isSuccess));
  }else if ([@"shareWebPage" isEqualToString:call.method]) {
    // 分享链接
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
      NSData *iconData = [self getDataWithThumbnail:call.arguments[@"thumbUrl"]];
      dispatch_async(dispatch_get_main_queue(), ^{
        WWKSendMessageReq *req = [[WWKSendMessageReq alloc] init];
        WWKMessageLinkAttachment *attachment = [[WWKMessageLinkAttachment alloc] init];
        attachment.title = call.arguments[@"title"];
        attachment.summary = call.arguments[@"description"];
        attachment.url = call.arguments[@"webpageUrl"];
        attachment.icon = iconData;
        req.attachment = attachment;
        BOOL isSuccess = [WWKApi sendReq:req];
        result(@(isSuccess));
      });
    });

  }else if ([@"shareMiniProgram" isEqualToString:call.method]) {
    // 分享小程序
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_async(globalQueue, ^{
      NSData *hdImageData = [self getDataWithThumbnail:call.arguments[@"hdImageData"]];
      dispatch_async(dispatch_get_main_queue(), ^{
        WWKSendMessageReq *req = [[WWKSendMessageReq alloc] init];
        WWKMessageMiniAppAttachment *attachment = [[WWKMessageMiniAppAttachment alloc] init];
        attachment.userName = call.arguments[@"username"]; 
        attachment.path = call.arguments[@"path"];
        if (hdImageData) {
          attachment.hdImageData = hdImageData;
        }
        attachment.title = call.arguments[@"title"];
        req.attachment = attachment;        
        BOOL isSuccess = [WWKApi sendReq:req];
        result(@(isSuccess));
      });
    });
  }else if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSData *)getDataWithThumbnail:(NSDictionary *)thumbnail {
    NSLog(@"FlutterMethodCall: %@", thumbnail);
    if (thumbnail == nil || thumbnail == (id) [NSNull null]) {
        return nil;
    }
    NSData *imageData = [self getNsDataFromWeChatFile:thumbnail];
    NSLog(@"imageDataSize %d", imageData.length);
    return imageData;
}
//enum ImageSchema {
//    NETWORK,
//    ASSET,
//    FILE,
//    BINARY,
//}
- (NSData *)getNsDataFromWeChatFile:(NSDictionary *)weChatFile {
    NSNumber *schema = weChatFile[@"schema"];

    if ([schema isEqualToNumber:@0]) {
        NSString *source = weChatFile[keySource];
        NSURL *imageURL = [NSURL URLWithString:source];
        //下载图片
        return [NSData dataWithContentsOfURL:imageURL];
    } else if ([schema isEqualToNumber:@1]) {
        NSString *source = weChatFile[keySource];
        return [NSData dataWithContentsOfFile:[self readFileFromAssets:source]];
    } else if ([schema isEqualToNumber:@2]) {
        NSString *source = weChatFile[keySource];
        return [NSData dataWithContentsOfFile:source];
    } else if ([schema isEqualToNumber:@3]) {
        FlutterStandardTypedData *imageData = weChatFile[@"source"];
        return imageData.data;
    } else {
        return nil;
    }
}

- (NSString *)readFileFromAssets:(NSString *)imagePath {
    NSArray *array = [self formatAssets:imagePath];
    NSString *key;
    if ([FluwxStringUtil isBlank:array[1]]) {
        key = [_fluwxRegistrar lookupKeyForAsset:array[0]];
    } else {
        key = [_fluwxRegistrar lookupKeyForAsset:array[0] fromPackage:array[1]];
    }

    return [[NSBundle mainBundle] pathForResource:key ofType:nil];
}

- (NSArray *)formatAssets:(NSString *)originPath {
    NSString *path = nil;
    NSString *packageName = @"";
    NSString *pathWithoutSchema = originPath;
    NSInteger indexOfPackage = [pathWithoutSchema lastIndexOfString:@"?package="];

    if (indexOfPackage != JavaNotFound) {
        path = [pathWithoutSchema substringFromIndex:0 toIndex:indexOfPackage];
        NSInteger begin = indexOfPackage + [fluwxKeyPackage length];
        packageName = [pathWithoutSchema substringFromIndex:begin toIndex:[pathWithoutSchema length]];
    } else {
        path = pathWithoutSchema;
    }

    return @[path, packageName];
}

- (BOOL)isPNG:(NSString *)suffix {
    return [@".png" equals:suffix];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleOpenURL:url sourceApplication:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleOpenURL:url sourceApplication:sourceApplication];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    return [WWKApi handleOpenURL:url delegate:self];
}

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    /*! @brief 处理外部调用URL的时候需要将URL传给SDK进行相关处理
     * @param url 外部调用传入的url
     * @param delegate 当前类需要实现WWKApiDelegate对应的方法
     */
    return [WWKApi handleOpenURL:url delegate:self];
}

// - (void)unregisterApp:(FlutterMethodCall *)call result:(FlutterResult)result {
//     isWWXRegistered = false;
//     result(@YES);
// }

// - (NSString *)nilToEmpty:(NSString *)string {
//     return string == nil?@"":string;
// }

@end
