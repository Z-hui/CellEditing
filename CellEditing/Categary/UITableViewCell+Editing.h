//
//  UITableViewCell+Editing.h
//  CellEditing
//
//  Created by DoZhui on 2020/6/30.
//  Copyright © 2020 DoZhui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (Editing)

//当前cell多选状态
@property (nonatomic, assign,readonly) BOOL zh_isEditingSelect;

//图标frame
@property (nonatomic, assign) CGRect zh_selectImageViewFrame;

//是否可以选中
@property (nonatomic, assign) BOOL zh_isCanSelect;

//替换系统多选图标
- (void)zh_replaceSystemMutiSelectImage:(UIImage *)selectImage normalImage:(UIImage *)normalImage;

@end

NS_ASSUME_NONNULL_END
