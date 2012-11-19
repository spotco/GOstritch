#import "AutoLevel.h"
#import "GameEngineLayer.h"
#import "DogBone.h"

@implementation AutoLevel

+(AutoLevel*)init_with_glayer:(GameEngineLayer*)glayer {
    AutoLevel* a = [AutoLevel node];
    [a initialize:glayer];
    return a;
}

-(void)initialize:(GameEngineLayer*)glayer {
    tglayer = glayer;
    
    NSArray *to_load = [[NSArray arrayWithObjects: @"connect1", @"connect2", nil] retain];
    map_sections = [[NSMutableArray alloc] init];
    
    for (NSString* i in to_load) {
        [map_sections addObject:[MapSection init_from_name:i]];
    }
    [to_load release];
    cur_x = ((MapSection*)[map_sections objectAtIndex:0]).map.connect_pts_x1;
    cur_y = ((MapSection*)[map_sections objectAtIndex:0]).map.connect_pts_y1;
    
    for (MapSection *m in map_sections) {
        [self load_map_section:m];
    }
}

-(void)load_map_section:(MapSection*)m {
    [m offset_x:cur_x y:cur_y];
    [tglayer.islands addObjectsFromArray:m.map.n_islands];
    [Island link_islands:tglayer.islands];
    
    for (Island* i in m.map.n_islands) {
        if (i.can_land == NO) {
            [tglayer addChild:i z:[GameRenderImplementation GET_RENDER_FG_ISLAND_ORD]];
        } else if ([i isKindOfClass:[BridgeIsland class]]) {
            [tglayer addChild:i z:[GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND]];
        } else {
            [tglayer addChild:i z:[GameRenderImplementation GET_RENDER_ISLAND_ORD]];
        }
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

-(GameObjectReturnCode)update:(Player *)player g:(GameEngineLayer *)g {
    CGPoint pos = player.position;
    int left = 99;
    for (MapSection *i in map_sections) {
        MapSection_Position ip = [i get_position_status:pos];
        if (ip == MapSection_Position_CURRENT) {
            left = [map_sections count]-1-[map_sections indexOfObject:i];
        }
    }
    
    if (left <= 1) {
        MapSection *n = [MapSection init_from_name:@"connect1"];
        [map_sections addObject:n];
        [self load_map_section:n];
    }
    
    return GameObjectReturnCode_NONE;
}

-(void)dealloc {
    [map_sections removeAllObjects];
    [map_sections release];
    [super dealloc];
}
@end


