//
//  MapLoader.h
//  GOstrich
//
//  Created by Chengcheng Hao on 6/20/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "Line_Island.h"
#import "Island.h"

@interface MapLoader : NSObject

+(bool) load_map: (NSString *)map_file_name oftype:(NSString *) map_file_type;

@end
