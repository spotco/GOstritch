#import "GameRenderImplementation.h"

#define RENDER_FG_ISLAND_ORD 3
#define RENDER_PLAYER_ORD 2
#define RENDER_ISLAND_ORD 1
#define RENDER_GAMEOBJ_ORD 0

#define YDIR_ZOOMSCALE 50.0
#define YDIR_DEFAULT 80.0
#define YDIR_ZOOMMAX 180.0

#define VERT_CAMERA_OFFSET_SPD 65

@implementation GameRenderImplementation

+(void)update_render_on:(CCLayer*)layer 
                player:(Player*)player 
                islands:(NSMutableArray*)islands 
                objects:(NSMutableArray*)objects 
                state:(GameRenderState*)state    {
    
    float g_dist = [GameRenderImplementation calc_g_dist:player islands:islands];
    //NSLog(@"GDIST:%f",g_dist);
    [GameRenderImplementation update_zoom:player layer:layer state:state g_dist:g_dist];
    
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

+(float)calc_g_dist:(Player*)player islands:(NSMutableArray*)islands {
    if (player.current_island != NULL) {
        return 0;
    }
    
    float max = INFINITY;
    CGPoint pos = player.position;
    for (Island* i in islands) {
        float ipos = [i get_height:pos.x];
        if (ipos != [Island NO_VALUE] && pos.y > ipos) {
            max = MIN(max,pos.y - ipos);
        }
    }
    return max;
}

+(void)update_zoom:(Player*)player layer:(CCLayer*)layer state:(GameRenderState*)state g_dist:(float)g_dist {
    /*TODO:magic constants here, have them linked to GameRenderState constants*/
    float tar = 140;
    if (player.current_island != NULL && ABS(((int)player.rotation)%360 - (-90)) < 10) {
        if (player.current_island.ndir == 1) {
            tar = -50;
        }
    }
    state.ex+=(tar-state.ex)/VERT_CAMERA_OFFSET_SPD;
    state.cx = state.ex;
    
    /*TODO: make this parameterized*/
    float default_zoom = 50;
    float cur_spd = [player get_current_params].cur_min_speed;
    float min = 6;
    float max = 14;
    
    if (cur_spd > min) {
        if (cur_spd > max) {
            default_zoom = 200;
        } else {
            default_zoom = MAX(default_zoom,(200-50)*(cur_spd-min)/8+50);
        }
    }
    
    if (state.ez > default_zoom) {
        state.ez--;
    } else if (state.ez < default_zoom) {
        state.ez++;
    }
    
    //state.cy = 80-130;
    if (g_dist > 0) {
        
        float tmp = g_dist > 500.0 ? 500.0 : g_dist;
        
        float tar_yoff = 80.0 + (tmp / 500.0)*60.0;
            
        //NSLog(@"tar_yoff:%f",tar_yoff);
        if (state.cy > YDIR_DEFAULT-tar_yoff) {
            state.cy -= (state.cy - (YDIR_DEFAULT-tar_yoff))/YDIR_ZOOMSCALE;
        } else {
            state.cy += ((YDIR_DEFAULT-tar_yoff)-state.cy)/YDIR_ZOOMSCALE;
        }
        
    } else {
        if (state.cy < YDIR_DEFAULT) {
            state.cy += (YDIR_DEFAULT-state.cy)/ (YDIR_ZOOMSCALE/2.0);
        }
    }
    state.ey = state.cy;
        
    [GameRenderImplementation update_camera_on:layer state:state];
}

int zct = 0;

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
