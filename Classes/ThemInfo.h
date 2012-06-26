//
//  ThemInfo.h
//  GOstrich
//
//  Created by Pingyang He on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemInfo : NSObject{
    NSString *pic_name, *map_name, *map_type;
}

@property (readwrite, assign) NSString *pic_name, *map_name, *map_type;

@end
