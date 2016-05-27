//
//  ViewController.m
//  Video
//
//  Created by fanren on 16/5/27.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property(nonatomic,strong) AVCaptureSession            *session;
@property(nonatomic,strong) AVCaptureVideoPreviewLayer  *previewLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAVFoundation];
}

- (void)setupAVFoundation
{
    //session
    self.session = [[AVCaptureSession alloc] init];
    //device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    //input
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if(input) {
        [self.session addInput:input];
    } else {
        NSLog(@"%@", error);
        return;
    }
    //output
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:output];
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_global_queue(0, 0)];
    //add preview layer
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _previewLayer.frame = self.view.layer.bounds;
    [self.view.layer addSublayer:self.previewLayer];
}

- (IBAction)clickStartButton:(UIButton *)sender {
    [self.session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"%@", metadataObjects);
}
@end
