//
//  Map.h
//  GOstrich
//
//  Created by Chengcheng Hao on 6/20/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Map : NSObject{
    NSMutableArray *n_islands, *game_objects;
    CGPoint player_start_pt;
}

@property(readwrite, assign) NSMutableArray *n_islands, *game_objects;
@property(readwrite,assign) CGPoint player_start_pt;

@end
