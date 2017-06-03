//
//  objcpp.h
//  rapid_medley
//
//  Created by base64 on 2017/05/14.
//  Copyright © 2017年 basemusi. All rights reserved.
//

#ifndef objc_h
#define objc_h

#import <Foundation/Foundation.h>

@interface ObjCpp : NSObject
-(NSMutableArray*)scale:(float*)input :(const int)size/* :(NSArray*) array*/;
-(NSMutableArray*)beats:(float*)input :(const int)size/* :(NSArray*) array*/;
@end

#endif
