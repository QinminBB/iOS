//
//  DVCaptureKit.m
//  OpenCV
//
//  Created by mac on 16/9/28.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import "DVCaptureKit.h"

static DVCaptureKit *_instance = nil;

@interface DVCaptureKit () <AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureOutput *output;
@end

@implementation DVCaptureKit

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (void)setupSessionWithType:(DVCaptureKitType)type
{
    self.captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError * error = nil;
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if ([self.captureSession canAddInput:self.videoInput]) {
        [self.captureSession addInput:self.videoInput];
    }else {
        NSLog(@"Input Error: %@", error);
    }
    
    //AVCaptureMovieFileOutput、AVCaptureVideoDataOutput、AVCaptureAudioFileOutput、AVCaptureAudioDataOutput
    switch (type) {
        case DVCaptureKitTypeImage: {
            AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            NSDictionary *stillImageOutputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
            [stillImageOutput setOutputSettings:stillImageOutputSettings];
            _stillImageOutput = stillImageOutput;
        }
            break;
        
        case DVCaptureKitTypeVideo: {
            AVCaptureVideoDataOutput *captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
            captureVideoDataOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
            [captureVideoDataOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
            captureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
            _output = captureVideoDataOutput;
        }
            break;
        
        default: {
            AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            NSDictionary *stillImageOutputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
            [stillImageOutput setOutputSettings:stillImageOutputSettings];
            _stillImageOutput = stillImageOutput;
        }
            break;
    }
    
    if (_output && [_captureSession canAddOutput:_output]) {
        [_captureSession addOutput:_output];
    }else if (_stillImageOutput && [_captureSession canAddOutput:_stillImageOutput]) {
        [_captureSession addOutput:_stillImageOutput];
    }
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
}

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    if (width == 0 || height == 0) {
        return nil;
        
    }
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress,
                                                 width,
                                                 height,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
    //
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGContextConcatCTM(context, transform);
    
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // 裁剪 图片
    struct CGImage *cgImage = CGImageCreateWithImageInRect(quartzImage, CGRectMake(0, 0, height, height));
    
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:cgImage];

    // 释放Quartz image对象
    CGImageRelease(cgImage);
    CGImageRelease(quartzImage);
    return image;
    
}

#pragma mark - PublicMethod
- (void)setType:(DVCaptureKitType)type
{
    [self setupSessionWithType:type];
}

- (void)capture
{
    if (!_stillImageOutput) {
        return;
    }
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput.connections firstObject];
    if ([stillImageConnection isVideoOrientationSupported]) {
        [stillImageConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         if (imageDataSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             if (_delegate && [_delegate respondsToSelector:@selector(captureKit:didCaptureImage:inType:)]) {
                 [_delegate captureKit:self didCaptureImage:[UIImage imageWithData:imageData] inType:DVCaptureKitTypeImage];
             }
         }else {
             NSLog(@"Error capturing still image: %@", error);
         }
     }];

}

- (void)start
{
    if (![self.captureSession isRunning]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stop
{
    if ([self.captureSession isRunning]) {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession stopRunning];
        });
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (captureOutput == _output) { //只有是视频帧 过来才操作
        UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(captureKit:didCaptureImage:inType:)]) {
                [_delegate captureKit:self didCaptureImage:image inType:DVCaptureKitTypeVideo];
            }
        });
    }
}

@end
