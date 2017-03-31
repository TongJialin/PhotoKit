//
//  TJLImagePickerController.h
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/12.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TJLPicPickerSuccessedHanlder)(NSArray *imageArray);

typedef void(^TJLTakePhotoSuccessedHanlder)(UIImage *image);

typedef void(^TJLPickerSuccessedHanlder)(NSArray *imageArray, NSArray *videoArray);

@interface TJLImagePickerController : UINavigationController

+ (instancetype) sharedInstance;

/**
 获取相册照片的方法

 @param vc 当前UIViewController
 @param succeedHandler 返回获取成功后的结果
 */
- (void)showPickerInController:(UIViewController *)vc successBlock:(TJLPicPickerSuccessedHanlder)succeedHandler;

/**
 获取拍照图片的方法

 @param vc 当前UIViewController
 @param succeedHandler 返回获取成功后的结果
 */
- (void)showCameraInController:(UIViewController *)vc successBlock:(TJLTakePhotoSuccessedHanlder)succeedHandler;

/**
 从相册获取图片和视频资源

 @param vc 当前UIViewController
 @param succeedHandler 返回获取成功后的结果
 */
- (void)showAllPickerInController:(UIViewController *)vc successBlock:(TJLPickerSuccessedHanlder)succeedHandler;

@end
