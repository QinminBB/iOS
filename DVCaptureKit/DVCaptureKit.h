//
//  DVCaptureKit.h
//  OpenCV
//
//  Created by mac on 16/9/28.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    DVCaptureKitTypeImage,
    DVCaptureKitTypeVideo,
} DVCaptureKitType;


@class DVCaptureKit;
@protocol DVCaptureKitDelegate <NSObject>
- (void)captureKit:(DVCaptureKit *)capture didCaptureImage:(UIImage *)image inType:(DVCaptureKitType)type;
@end


@interface DVCaptureKit : NSObject
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, weak) id<DVCaptureKitDelegate> delegate;
+ (instancetype)sharedInstance;
/**
 *  输出图片或者视频流图片
 *
 */
- (void)setType:(DVCaptureKitType)type;
/**
 *  截图
 */
- (void)capture;
/**
 *  开始运行
 */
- (void)start;
/**
 *  停止运行
 */
- (void)stop;
@end
