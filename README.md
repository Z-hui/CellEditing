# CellEditing
# 一、主要实现：

1.支持自定义cell多选图标

2.支持定义cell多选图标位置

3.支持指定不可选indexPath

![image.png](https://upload-images.jianshu.io/upload_images/5333893-e9df4ba52c3f6fe4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


# 二、使用方法：
## 1.支持自定义cell多选图标

```
@implementation CustomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
         reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zh_replaceSystemMutiSelectImage:[UIImage imageNamed:@"icon_select"]  normalImage:[UIImage imageNamed:@"icon_noSelect"]];
    }
    return self;
}
```
在自定义cell中调用` zh_replaceSystemMutiSelectImage:normalImage:`方法,传入自定义选中图片与未选中图片.

## 2.支持定义cell多选图标位置

```
    /**
     如果你有某些cell是想自定义多选图标位置的
     1.设置zh_selectImageViewFrame，此属性使用后其他indexPath要设置为CGRectZero，分类内部无法判断重用
     */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 5) {
        cell.zh_selectImageViewFrame = CGRectMake(13, 10, 23, 23);
    }else {
        cell.zh_selectImageViewFrame = CGRectZero;
    }
}
```
在cellforrow中设置多选图标的frame，设置zh_selectImageViewFrame，此属性使用后其他indexPath要设置为CGRectZero，分类内部无法判断重用

## 3.支持指定不可选indexPath

```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomTableViewCell"];
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"CustomTableViewCell"];
    }
    
    /**
     如果你有某些cell是不想支持多选的
     1.实现- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 对制定的indexPath返回nil；
     2.设置zh_isCanSelect为NO，此属性使用后其他不隐藏indexPath要设置为YES，分类内部无法判断重用
     */
    if (indexPath.row == 3) {
        cell.zh_isCanSelect = NO;
    }else {
        cell.zh_isCanSelect = YES;
    }
  
    cell.textLabel.text = [NSString stringWithFormat:@"Index:%ld",indexPath.row];
    return cell;
}
```
设置zh_isCanSelect为NO，此属性使用后其他不隐藏indexPath要设置为YES，分类内部无法判断重用


# 三、具体实现`UITableViewCell+Editing.h`
```
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

```

```
#import "UITableViewCell+Editing.h"
#import <objc/runtime.h>

static const void *kZh_Edit_SelectImage = @"kZh_Edit_SelectImage";
static const void *kZh_Edit_NomalImage = @"kZh_Edit_NomalImage";
static const void *kZh_SelectImageView = @"kZh_SelectImageView";


@interface UITableViewCell ()

@property (nonatomic, strong)UIImage *zh_Edit_SelectImage;

@property (nonatomic, strong)UIImage *zh_Edit_NomalImage;

@property (nonatomic, strong)UIImageView *zh_SelectImageView;

//当前cell多选状态
@property (nonatomic, assign) BOOL zh_isEditingSelect;

@end

@implementation UITableViewCell (Editing)

#pragma mark - Swizzling
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(layoutSubviews);
        SEL swizzledSelector = @selector(swizzling_layoutSubviews);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)swizzling_layoutSubviews {
    [self swizzling_layoutSubviews];
    
    //当前cell不支持多选
    if (!self.zh_isCanSelect) {
        [self zh_removeSystemSelect];
        [self zh_removeSelectView];
        return;
    }
    
    //隐藏系统多选图标
    if (self.ksHiddenSystemMutSelect) {
        [self zh_removeSystemSelect];
    }else {
        return;
    }


    //添加/移除自定义多选图标
    if (self.isEditing) {
        [self zh_addSelectView];
        
        //判断当前cell选中状态
        UITableView *tableView = (UITableView *)self.superview;
        CGRect cellRect = [tableView convertRect:self.frame toView:tableView];
        if ([[tableView indexPathsForSelectedRows] containsObject:[tableView indexPathForRowAtPoint:CGPointMake(cellRect.origin.x + cellRect.size.width/2.f, cellRect.origin.y+cellRect.size.height/2.f)]]) {
            self.zh_isEditingSelect = YES;
        }else {
            self.zh_isEditingSelect = NO;
        }
        
        //自定义多选图标自定义frame
        if (self.zh_SelectImageView) {
            if (!CGRectEqualToRect(self.zh_selectImageViewFrame, CGRectZero)) {
                self.zh_SelectImageView.frame = self.zh_selectImageViewFrame;
            } else {
                self.zh_SelectImageView.frame = CGRectMake(13, (self.frame.size.height-23)/2.f, 23, 23);
            }
        }
    }else {
        [self zh_removeSelectView];
    }
}

//替换体统多选图标为自定义图标
- (void)zh_replaceSystemMutiSelectImage:(UIImage *)selectImage normalImage:(UIImage *)normalImage {
    self.ksHiddenSystemMutSelect = YES;
    self.zh_Edit_SelectImage = selectImage;
    self.zh_Edit_NomalImage = normalImage;
}

//隐藏多选
- (void)zh_hiddenSelectView {
    
}

//移除系统图标
- (void)zh_removeSystemSelect {
    for (UIView* subview in [self subviews]) {
        // As determined by NSLogging every subview's class, and guessing which was the one I wanted
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellEditControl"]) {
            subview.hidden = YES;
            break;
        }
    }
}

//添加自定义多选imageView
- (void)zh_addSelectView {
    if (self.zh_SelectImageView) {
        return;
    } 
    UIImageView *selectImageView = [[UIImageView alloc] initWithImage:self.zh_Edit_NomalImage];
    self.zh_SelectImageView = selectImageView;
    [self addSubview:selectImageView];
}

//移除自定义多选imageView
- (void)zh_removeSelectView {
    if (self.zh_SelectImageView) {
        [self.zh_SelectImageView removeFromSuperview];
        self.zh_SelectImageView = nil;
    }
}

- (void)setZh_Edit_NomalImage:(UIImage *)zh_Edit_NomalImage {
    objc_setAssociatedObject(self, kZh_Edit_NomalImage, zh_Edit_NomalImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)zh_Edit_NomalImage {
    return objc_getAssociatedObject(self, kZh_Edit_NomalImage);
}

- (void)setZh_Edit_SelectImage:(UIImage *)zh_Edit_SelectImage {
    objc_setAssociatedObject(self, kZh_Edit_SelectImage, zh_Edit_SelectImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)zh_Edit_SelectImage {
    return objc_getAssociatedObject(self, kZh_Edit_SelectImage);
}

- (void)setZh_isEditingSelect:(BOOL)zh_isEditingSelect {
    if (self.zh_SelectImageView) {
        if (zh_isEditingSelect) {
            self.zh_SelectImageView.image = self.zh_Edit_SelectImage;
        } else {
            self.zh_SelectImageView.image = self.zh_Edit_NomalImage;
        }
    }
    
    objc_setAssociatedObject(self, @selector(zh_isEditingSelect), [NSNumber numberWithBool:zh_isEditingSelect], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)zh_isEditingSelect {
    return [objc_getAssociatedObject(self, @selector(zh_isEditingSelect)) boolValue];
}


- (BOOL)zh_isCanSelect {
    return [objc_getAssociatedObject(self, @selector(zh_isCanSelect)) boolValue];
}

- (void)setZh_isCanSelect:(BOOL)zh_isCanSelect {
    objc_setAssociatedObject(self, @selector(zh_isCanSelect), [NSNumber numberWithBool:zh_isCanSelect], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)ksHiddenSystemMutSelect {
    return [objc_getAssociatedObject(self, @selector(ksHiddenSystemMutSelect)) boolValue];
}

-(void)setKsHiddenSystemMutSelect:(BOOL)ksHiddenSystemMutSelect {
    objc_setAssociatedObject(self, @selector(ksHiddenSystemMutSelect), [NSNumber numberWithBool:ksHiddenSystemMutSelect], OBJC_ASSOCIATION_COPY_NONATOMIC);
   
}

- (UIImageView *)zh_SelectImageView {
    return objc_getAssociatedObject(self, kZh_SelectImageView);
}

- (void)setZh_SelectImageView:(UIImageView *)zh_SelectImageView {
    objc_setAssociatedObject(self, kZh_SelectImageView, zh_SelectImageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (CGRect)zh_selectImageViewFrame {
    return [objc_getAssociatedObject(self, @selector(zh_selectImageViewFrame)) CGRectValue];
}

- (void)setZh_selectImageViewFrame:(CGRect)zh_selectImageViewFrame {
    if (self.zh_SelectImageView) {
        self.zh_SelectImageView.frame = zh_selectImageViewFrame;
    }
    objc_setAssociatedObject(self, @selector(zh_selectImageViewFrame),[NSValue valueWithCGRect:zh_selectImageViewFrame] , OBJC_ASSOCIATION_COPY_NONATOMIC);
}

```
# 四、场景
1.自定义cell的多选图标，系统的太丑，无侵入，使用简单
2.在聊天页面合并转发消息需要指定某些消息不可以选中转发
3.自定义frame主要是系统的多选默认是居中的，但是在聊天页面多选图标可能要求与聊天头像居中对齐
![image.png](https://upload-images.jianshu.io/upload_images/5333893-e6754b779f5d1524.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


