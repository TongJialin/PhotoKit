//
//  TJLPhotoManageTypes.h
//  PhotoManagement
//
//  Created by Oma-002 on 17/2/22.
//  Copyright © 2017年 com.oma.matec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJLPhotoManageTypes : NSObject

typedef NS_ENUM(NSInteger, TJLPickerTypes) {
    TJLPickerTypesPhoto        = 0, //照片选择器
    TJLPickerTypesAll          = 1, //照片和视频选择器
};

@end
