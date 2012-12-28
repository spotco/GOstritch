#import "AutoLevel.h"
#import "GameEngineLayer.h"
#import "DogBone.h"

@implementation AutoLevel

+(NSArray*)random_set1 {
    static NSArray *set1_levels;
    if (!set1_levels){
        set1_levels = [[NSArray alloc] initWithObjects:
            @"autolevel_1_1",@"autolevel_1_2",@"autolevel_1_3",@"autolevel_1_4",@"autolevel_1_5",@"autolevel_1_6",@"autolevel_1_7",@"autolevel_1_8",
            //@"autolevel_1_2",
        nil];
        //set1_levels = [[NSArray alloc] initWithObjects:@"test", nil];
    }
    return set1_levels;
}

+(AutoLevel*)init_with_glayer:(GameEngineLayer*)glayer {
    AutoLevel* a = [AutoLevel node];
    [a cons:glayer];
    [GEventDispatcher add_listener:a];
    return a;
}

-(void)cons:(GameEngineLayer*)glayer {
    tglayer = glayer;
    ct = 0;
    
    NSArray *to_load = [[NSArray arrayWithObjects: @"autolevel_start", nil] retain];
    map_sections = [[NSMutableArray alloc] init];
    stored = [[NSMutableArray alloc] init];
    
    for (NSString* i in to_load) {
        [map_sections addObject:[MapSection init_from_name:i]];
    }
    [to_load release];
    cur_x = ((MapSection*)[map_sections objectAtIndex:0]).map.connect_pts_x1;
    cur_y = ((MapSection*)[map_sections objectAtIndex:0]).map.connect_pts_y1;
    
    for (MapSection *m in map_sections) {
        [self load_map_section:m];
    }
    
    for (NSString* i in [AutoLevel random_set1]) {
        [MapLoader precache_map:i];
    }
}

-(void)load_map_section:(MapSection*)m {
    [m offset_x:cur_x y:cur_y];
    [tglayer.islands addObjectsFromArray:m.map.n_islands];
    
    [Island link_islands:tglayer.islands];
    
    for (Island* i in m.map.n_islands) {
        [tglayer addChild:i z:[i get_render_ord]];
    }
    
    [tglayer.game_objects addObjectsFromArray:m.map.game_objects];
    for (GameObject* o in m.map.game_objects) {
        [tglayer addChild:o z:[o get_render_ord]];
        if ([o class] == [DogBone class]) {
            [tglayer add_bone:(DogBone*)o autoassign:YES];
        }
    }
    
    cur_x = (m.map.connect_pts_x2 - m.map.connect_pts_x1)+cur_x;
    cur_y = (m.map.connect_pts_y2 - m.map.connect_pts_y1)+cur_y;
}

-(void)remove_map_section:(MapSection*)m {
    [map_sections removeObject:m];
    [tglayer.islands removeObjectsInArray:m.map.n_islands];
    for (Island* i in m.map.n_islands) {
        if (tglayer.player.current_island == i) { NSLog(@"REMOVING CURRENT PLAYER ISLAND, VERY BAD!!"); }
        [tglayer removeChild:i cleanup:YES];
    }
    [tglayer.game_objects removeObjectsInArray:m.map.game_objects];
    for(GameObject* o in m.map.game_objects) {
        [tglayer removeChild:o cleanup:YES];
    }
    [m release];
}

-(void)cleanup:(CGPoint)player_startpt {
    NSMutableArray *toremove = [[NSMutableArray alloc] init];
    for(MapSection *i in map_sections) {
        MapSection_Position ip = [i get_position_status:player_startpt];
        if (ip == MapSection_Position_PAST) {
            [toremove addObject:i];
        }
    }
    
    for(MapSection *m in toremove) {
        for(GameObject *o in m.map.game_objects) {
            [tglayer.game_objects removeObject:o];
            [tglayer removeChild:o cleanup:YES];
            
        }
        for(Island *i in m.map.n_islands) {
            [tglayer.islands removeObject:i];
            [tglayer removeChild:i cleanup:YES];
            
        }
        [m release];
    }
    [map_sections removeObjectsInArray:toremove];
    
    for(MapSection *m in stored) {
        [m release];
    }
    [stored removeAllObjects];
    
    [toremove removeAllObjects];
    [toremove dealloc];
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_CHECKPOINT) {
        [self cleanup:tglayer.player.start_pt];
    }
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    CGPoint pos = player.position;
    NSMutableArray *tostore = [[NSMutableArray alloc] init];
    int left = 99;
    for (MapSection *i in map_sections) {
        MapSection_Position ip = [i get_position_status:pos];
        if (ip == MapSection_Position_CURRENT) {
            left = [map_sections count]-1-[map_sections indexOfObject:i];
        } else if (ip == MapSection_Position_PAST) {
            [tostore addObject:i];
        }
    }
    
    if ([tostore count] > 0) {
        [map_sections removeObjectsInArray:tostore];
        for (MapSection *i in tostore) {
            [stored addObject:i];
            for (GameObject *o in i.map.game_objects) {
                [g removeChild:o cleanup:NO];
                [g.game_objects removeObject:o];
            }
            for (Island *o in i.map.n_islands) {
                [g removeChild:o cleanup:NO];
                [g.islands removeObject:o];
            }
        }
    }
    
    if (left <= 1) {
        MapSection *n = [MapSection init_from_name:[self get_random_map]];
        [map_sections addObject:n];
        [self load_map_section:n];
        ct++;
    }
    
    [tostore removeAllObjects];
    [tostore dealloc];
    //NSLog(@"SECTIONS:%i ISLANDS:%i GAMEOBJS:%i",[map_sections count], [tglayer.islands count], [tglayer.game_objects count]);
    return;
}

-(void)reset {
    for (int i = stored.count-1; i>=0; i--) {
        MapSection *t = [stored objectAtIndex:i];
        [stored removeObjectAtIndex:i];
        [map_sections insertObject:t atIndex:0];
        
        for (GameObject *o in t.map.game_objects) {
            [tglayer addChild:o];
            [tglayer.game_objects addObject:o];
        }
        for (Island *o in t.map.n_islands) {
            [tglayer addChild:o];
            [tglayer.islands addObject:o];
        }
        
    }
    [super reset];
}

-(NSString*)get_random_map {
    NSArray* tlvls = [AutoLevel random_set1];
    return [tlvls objectAtIndex:arc4random_uniform([tlvls count])];
}

-(void)dealloc {
    for (MapSection *m in map_sections) {
        [m release];
    }
    for (MapSection *m in stored) {
        [m release];
    }
    [stored removeAllObjects];
    [stored release];
    [map_sections removeAllObjects];
    [map_sections release];
    [super dealloc];
}
@end


