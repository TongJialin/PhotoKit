//
//  TJLImagePickerController.h
//  PhotoManagement
//
//  Created by Oma-002 on 17/1/12.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TJLPicPickerSuccessedHanlder)(NSArray *imageArray);

@interface TJLImagePickerController : UINavigationController

+ (instancetype) sharedInstance;

- (void)showPickerInController:(UIViewController *)vc successBlock:(TJLPicPickerSuccessedHanlder)succeedHandler;

@end
