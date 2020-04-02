//
//  UIView+JHLongPressCopy.m
//  JHKit
//
//  Created by HaoCold on 2019/4/30.
//  Copyright © 2019 HaoCold. All rights reserved.
//

#import "UIView+JHLongPressCopy.h"
#import <objc/runtime.h>

@interface UIMenuController (JHLongPressCopy)

@property (nonatomic,  strong) UIView *targetView;

@end

@implementation UIMenuController (JHLongPressCopy)

- (void)setTargetView:(UIView *)targetView
{
    objc_setAssociatedObject(self, @selector(targetView), targetView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)targetView
{
    return objc_getAssociatedObject(self, _cmd);
}

@end


@implementation UIView (JHLongPressCopy)

#pragma mark - public
- (void)jh_addLongPressCopy
{
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressActioin:)]];
}

#pragma mark - private
- (void)longPressActioin:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIView *view = gesture.view;
        
        // 用于点击其他区域，隐藏 UIMenuController
        [view.window addSubview:({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = 1000;
            button.frame = [UIScreen mainScreen].bounds;
            [button addTarget:self action:@selector(clickAction:) forControlEvents:1<<6];
            button;
        })];

        
        UIMenuController *menuCtrl = [UIMenuController sharedMenuController];
        menuCtrl.targetView = view;
        
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyAction:)];
        menuCtrl.menuItems = @[copyItem];
        
        // 用于唤起 UIMenuController
        // 更新 Xcode 11 后，UILabel 不起作用了，唤不起小菜单了
        UITextView *textView = [[UITextView alloc] init];
        textView.editable = NO;
        textView.tag = 20200402;
        [view.window addSubview:textView];
        [textView becomeFirstResponder];
        
        if (@available(iOS 13.0, *)) {
            [menuCtrl showMenuFromView:view.superview rect:view.frame];
        } else {
            [menuCtrl setTargetRect:view.frame inView:view.superview];
            [menuCtrl setMenuVisible:YES animated:YES];
        }
    }
}

- (void)clickAction:(UIButton *)button
{
    [button removeFromSuperview];
    [[button.window viewWithTag:20200402] removeFromSuperview];
    [UIMenuController sharedMenuController].menuItems = nil;
    
    if (@available(iOS 13.0, *)) {
        [[UIMenuController sharedMenuController] hideMenu];
    }else{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
}

- (void)copyAction:(UIMenuController *)menuCtrl
{
    UIView *view = menuCtrl.targetView;
    [[view.window viewWithTag:1000] removeFromSuperview];
    [[view.window viewWithTag:20200402] removeFromSuperview];
    
    NSString *text = [view performSelector:@selector(text)];
    if (text) {
        [UIPasteboard generalPasteboard].string = text;
    }
}

@end
