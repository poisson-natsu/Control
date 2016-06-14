//
//  UIControl+BHTapInterval.m
//  TipsProject
//
//  Created by Natsu on 16/5/31.
//  Copyright © 2016年 Natsu. All rights reserved.
//

#import "UIControl+BHTapInterval.h"
#import "objc/runtime.h"

@interface UIControl ()
@property (nonatomic, assign) NSTimeInterval wh_acceptEventTime;

@end

@implementation UIControl (BHTapInterval)
static const char *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";
static const char *UIControl_acceptEventTime = "UIControl_acceptEventTime";
- (NSTimeInterval)wh_acceptEventInterval
{
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}

- (void)setWh_acceptEventInterval:(NSTimeInterval)wh_acceptEventInterval
{
    objc_setAssociatedObject(self, UIControl_acceptEventInterval, @(wh_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)wh_acceptEventTime
{
    return [objc_getAssociatedObject(self, UIControl_acceptEventTime) doubleValue];
}

- (void)setWh_acceptEventTime:(NSTimeInterval)wh_acceptEventTime
{
    objc_setAssociatedObject(self, UIControl_acceptEventTime, @(wh_acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load
{
    Method systemMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    SEL sysSEL = @selector(sendAction:to:forEvent:);
    
    Method myMethod = class_getInstanceMethod(self, @selector(wh_sendAction:to:forEvent:));
    SEL mySEL = @selector(wh_sendAction:to:forEvent:);
    
    // add method into it
    BOOL didAddMethod = class_addMethod(self, sysSEL, method_getImplementation(myMethod), method_getTypeEncoding(myMethod));
    
    if (didAddMethod) {
        class_replaceMethod(self, mySEL, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else {
        method_exchangeImplementations(systemMethod, myMethod);
    }
}

- (void)wh_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    static int i = 0;
    static NSTimeInterval firstTimeTime;
    if (firstTimeTime < 1) {
        firstTimeTime = NSDate.date.timeIntervalSince1970;
    }
    if (NSDate.date.timeIntervalSince1970 - self.wh_acceptEventTime < self.wh_acceptEventInterval) {
        if (++i >= 5) {
            NSTimeInterval fifthTimeTime = NSDate.date.timeIntervalSince1970;
            i = 0;
            if (fifthTimeTime - firstTimeTime < self.wh_acceptEventInterval) {
                firstTimeTime = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didClick5Times" object:self];
            }else {
                firstTimeTime = NSDate.date.timeIntervalSince1970;
            }
        }
        return;
    }
    
    if (self.wh_acceptEventInterval > 0) {
        self.wh_acceptEventTime = NSDate.date.timeIntervalSince1970;
    }
    
    [self wh_sendAction:action to:target forEvent:event];
}



@end
