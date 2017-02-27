//
//  TJLImagePickerController.m
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/12.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import "TJLImagePickerController.h"
#import "TJLAlbumsViewController.h"
#import "TJLGridViewController.h"
#import "TJLCameraViewController.h"
#import <Photos/Photos.h>

@interface TJLImagePickerController ()

@property (nonatomic, strong) NSMutableArray *imageArray;

/**
 获取相册图片数组成功后的回调
 */
@property (nonatomic, strong) TJLPicPickerSuccessedHanlder successedHandler;

/**
 获取拍照图片成功后的回调
 */
@property (nonatomic, strong) TJLTakePhotoSuccessedHanlder takePhotoSuccessedHandler;

@property (strong, nonatomic) TJLPickerSuccessedHanlder videoPicsuccessedHandler;

@end

@implementation TJLImagePickerController

static TJLImagePickerController *helper;

+ (instancetype) sharedInstance {
    @synchronized (self) {
        if (!helper){
            helper = [[self alloc] init];
        }
    }
    return helper;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized (self) {
        if (!helper) {
            helper = [super allocWithZone:zone];
            return helper;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNotification];
}

#pragma mark --- notification

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction:) name:@"assetsArray" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takePhotoNotification:) name:@"cameraImage" object:nil];
}

- (void)notificationAction:(NSNotification *)notification {
    [self.imageArray removeAllObjects];
    NSDictionary *dict = notification.userInfo;
    NSMutableArray *assetsArray = [dict objectForKey:@"assetsArray"];
    
    __weak typeof(self) weakSelf = self;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    
    NSMutableArray *videoArray = [NSMutableArray new];
    for (PHAsset *asset in assetsArray) {
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(WIDTH, HEIGHT) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                [weakSelf.imageArray addObject:result];
            }];
        } else if (asset.mediaType == PHAssetMediaTypeVideo) {
            
            [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(WIDTH, HEIGHT) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                if (result) {
                    [weakSelf.imageArray addObject:result];
                }
            }];
            
            [videoArray addObject:asset];
            
//            [[PHCachingImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//                AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//                
//                gen.appliesPreferredTrackTransform = YES;
//                CMTime time = CMTimeMakeWithSeconds(0.0, 600);
//                NSError *error = nil;
//                CMTime actualTime;
//                CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
//                UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
//                [weakSelf.imageArray addObject:thumb];
//                CGImageRelease(image);
//                
//            }];
        }
    }
    
    if (videoArray.count > 0) {
        if (self.videoPicsuccessedHandler) {
            self.videoPicsuccessedHandler(self.imageArray,videoArray);
        }
    } else {
        if (self.successedHandler) {
            self.successedHandler(self.imageArray);
        }
    }
    
}

- (void)takePhotoNotification:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    UIImage *image = [dict objectForKey:@"image"];
    if (self.takePhotoSuccessedHandler) {
        self.takePhotoSuccessedHandler(image);
    }
}

- (void)dealloc {
    [self removeNotification];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"assetsArray" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cameraImage" object:nil];
}

#pragma mark --- 获取相册照片的方法

- (void)showPickerInController:(UIViewController *)vc successBlock:(TJLPicPickerSuccessedHanlder)succeedHandler {
    
    self.successedHandler = succeedHandler;
    
    [vc.navigationController presentViewController:self animated:YES completion:nil];
    [self setupNavigationController:TJLPickerTypesPhoto];
}

#pragma mark --- 获取拍照图片的方法

- (void)showCameraInController:(UIViewController *)vc successBlock:(TJLTakePhotoSuccessedHanlder)succeedHandler {
    
    self.takePhotoSuccessedHandler = succeedHandler;
    
    [vc.navigationController presentViewController:self animated:YES completion:nil];
    
    TJLCameraViewController *cameraViewController = [[TJLCameraViewController alloc] init];
    [self setViewControllers:@[cameraViewController]];
}

#pragma mark --- 获取图片和视频资源的方法

- (void)showAllPickerInController:(UIViewController *)vc successBlock:(TJLPickerSuccessedHanlder)succeedHandler {
    
    self.videoPicsuccessedHandler = succeedHandler;
    
    [vc.navigationController presentViewController:self animated:YES completion:nil];
    [self setupNavigationController:TJLPickerTypesAll];
}

- (void)setupNavigationController:(TJLPickerTypes)type {
    TJLAlbumsViewController *albumsViewController = [[TJLAlbumsViewController alloc] init];
    albumsViewController.type = type;
    TJLGridViewController *gridViewController = [[TJLGridViewController alloc] init];
    gridViewController.type = type;
    [self setViewControllers:@[albumsViewController, gridViewController]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark --- get

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    return _imageArray;
}

//- (void)checkAuthorizationStatus {
    //    //检查是否有访问权限
    //    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
    //        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    //            if (status == PHAuthorizationStatusAuthorized) {
    //
    //                self.successedHandler = succeedHandler;
    //
    //                [vc.navigationController presentViewController:self animated:YES completion:nil];
    //                [self setupNavigationController];
    //
    //            } else {
    //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该应用没有访问相册的权限，您可以在设置中修改该配置" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
    //                [alert show];
    //            }
    //        }];
    //    } else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
    //        self.successedHandler = succeedHandler;
    //
    //        [vc.navigationController presentViewController:self animated:YES completion:nil];
    //        [self setupNavigationController];
    //    } else {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该应用没有访问相册的权限，您可以在设置中修改该配置" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:nil, nil];
    //        [alert show];
    //    }
//}

@end
