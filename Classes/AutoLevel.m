#import "AutoLevel.h"
#import "GameEngineLayer.h"


@implementation AutoLevel

+(AutoLevel*)init_with_glayer:(GameEngineLayer*)glayer {
    AutoLevel* a = [AutoLevel node];
    [a initialize:glayer];
    return a;
}

-(void)initialize:(GameEngineLayer*)glayer {
    tglayer = glayer;
    
    NSArray *to_load = [[NSArray arrayWithObjects: @"connect1", @"connect2", @"connect1",@"connect2", @"connect1", nil] retain];
    map_sections = [[NSMutableArray alloc] init];
    
    for (NSString* i in to_load) {
        [map_sections addObject:[MapSection init_from_name:i]];
    }
    [to_load release];
    cur_x = ((MapSection*)[map_sections objectAtIndex:0]).map.connect_pts_x1;
    cur_y = ((MapSection*)[map_sections objectAtIndex:0]).map.connect_pts_y1;
    
    for (MapSection *m in map_sections) {
        [AutoLevel transform_map:m.map by_x:cur_x by_y:cur_y];
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
        }
        
        cur_x = (m.map.connect_pts_x2 - m.map.connect_pts_x1)+cur_x;
        cur_y = (m.map.connect_pts_y2 - m.map.connect_pts_y1)+cur_y;
    }
}

+(void)transform_map:(GameMap)map by_x:(float)tx by_y:(float)ty {
    for (Island* i in map.n_islands) {
        [i setPosition:ccp(i.position.x+tx,i.position.y+ty)];
        i.startX +=tx;
        i.startY +=ty;
        i.endX +=tx;
        i.endY +=ty;
    }
    for (GameObject* o in map.game_objects) {
        [o setPosition:ccp(o.position.x-tx,o.position.y-ty)];
    }
}
@end


