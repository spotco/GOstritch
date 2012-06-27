//
//  MapLoader.h
//  GOstrich
//
//  Created by Chengcheng Hao on 6/20/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "LineIsland.h"
#import "CurveIsland.h"
#import "Island.h"
#import "Map.h"
#import "Coin.h"

@interface MapLoader : NSObject

+(Map *) load_map: (NSString *)map_file_name oftype:(NSString *) map_file_type;
+(NSArray *) load_themes_info;

@end
