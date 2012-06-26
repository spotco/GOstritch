//
//  Map.m
//  GOstrich
//
//  Created by Chengcheng Hao on 6/20/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "Map.h"

@implementation Map

@synthesize n_islands, game_objects;

-(id) init{
    n_islands = [[NSMutableArray alloc] init];
    game_objects = [[NSMutableArray alloc] init];
    
    return self;
    
}



@end
