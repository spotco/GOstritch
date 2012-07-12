#import "GameRenderImplementation.h"

#define RENDER_FG_ISLAND_ORD 3
#define RENDER_PLAYER_ORD 2
#define RENDER_ISLAND_ORD 1
#define RENDER_GAMEOBJ_ORD 0

#define VERT_CAMERA_OFFSET_SPD 65

@implementation GameRenderImplementation

+(void)update_render_on:(CCLayer*)layer 
                player:(Player*)player 
                islands:(NSMutableArray*)islands 
                objects:(NSMutableArray*)objects 
                state:(GameRenderState*)state    {
    
    [GameRenderImplementation update_zoom:player layer:layer state:state];
    
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

+(void)update_zoom:(Player*)player layer:(CCLayer*)layer state:(GameRenderState*)state {
    float tar = 100;
    if (player.current_island != NULL && ABS(((int)player.rotation)%360 - (-90)) < 10) {
        if (player.current_island.ndir == 1) {
            tar = -50;
        }
    }
    state.ex+=(tar-state.ex)/VERT_CAMERA_OFFSET_SPD;
    state.cx = state.ex;
    
    [GameRenderImplementation update_camera_on:layer state:state];
}

+(void)update_camera_on:(CCLayer*)layer state:(GameRenderState*)state {
    [layer.camera setCenterX:state.cx centerY:state.cy centerZ:state.cz];
    [layer.camera setEyeX:state.ex  eyeY:state.ey eyeZ:state.ez];
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
