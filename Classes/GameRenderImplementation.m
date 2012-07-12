#import "GameRenderImplementation.h"

#define RENDER_FG_ISLAND_ORD 3
#define RENDER_PLAYER_ORD 2
#define RENDER_ISLAND_ORD 1
#define RENDER_GAMEOBJ_ORD 0

@implementation GameRenderImplementation

+(void)update_render_on:(CCLayer*)layer 
                player:(Player*)player 
                islands:(NSMutableArray*)islands 
                objects:(NSMutableArray*)objects {
    
    
    BOOL player_on_fg_island = (player.current_island != NULL) && (!player.current_island.can_land);
    if (player_on_fg_island) {
        if (player.zOrder != RENDER_FG_ISLAND_ORD+1) {
            [layer reorderChild:player z:RENDER_FG_ISLAND_ORD+1];
        }
    } else {
        if (player.zOrder != RENDER_PLAYER_ORD) {
            [layer reorderChild:player z:RENDER_PLAYER_ORD];
        }
    }
}



+(int)GET_RENDER_FG_ISLAND_ORD { 
    return RENDER_FG_ISLAND_ORD; 
}
+(int)GET_RENDER_PLAYER_ORD { 
    return RENDER_PLAYER_ORD; 
}

+(int)GET_RENDER_ISLAND_ORD {
    return RENDER_ISLAND_ORD;
}

+(int)GET_RENDER_GAMEOBJ_ORD {
    return RENDER_GAMEOBJ_ORD;
}

@end
