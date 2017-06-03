//
//  objcpp.m
//  rapid_medley
//
//  Created by base64 on 2017/05/14.
//  Copyright © 2017年 basemusi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "objc.h"
#import "cpp.hpp"

@implementation ObjCpp {
    Cpp *cpp;
}

-(id)init {
    self = [super init];
    cpp = new Cpp();
    return self;
}

-(void)dealloc {
 delete cpp;
}

-(NSMutableArray*)beats:(float*)input :(int)size{
    int* temp = cpp->beats(input, size);
    NSMutableArray* ret = [NSMutableArray array];
    for (int i=0;temp[i]>=0;i++){
        [ret addObject:@(temp[i])];
    }
    free(temp);
    return ret;
}


-(NSMutableArray*)scale:(float*)input :(int)size{
    float* temp = cpp->scale(input, size);
    
    NSMutableArray* ret = [NSMutableArray array];
    for (int i=0;i<size/512 -1;i++){
        [ret addObject:@(temp[i])];
    }
    free(temp);
    //float hoge = *temp;
    return ret;
}



@end
