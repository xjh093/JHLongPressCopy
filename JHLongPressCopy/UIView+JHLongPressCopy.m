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
        
        [menuCtrl setTargetRect:view.frame inView:view.superview];
        [menuCtrl setMenuVisible:YES animated:YES];
    }
}

- (void)clickAction:(UIButton *)button
{
    [button removeFromSuperview];
    [UIMenuController sharedMenuController].menuItems = nil;
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

- (void)copyAction:(UIMenuController *)menuCtrl
{
    UIView *view = menuCtrl.targetView;
    [[view.window viewWithTag:1000] removeFromSuperview];
    
    NSString *text = [view performSelector:@selector(text)];
    if (text) {
        [UIPasteboard generalPasteboard].string = text;
    }
}

@end
