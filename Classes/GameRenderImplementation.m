#import "GameRenderImplementation.h"
#import "GameEngineLayer.h"

#define RENDER_PLAYER_ON_FG_ORD 7
#define RENDER_ABOVE_FG_ORD 6
#define RENDER_FG_ISLAND_ORD 5
#define RENDER_PLAYER_ORD 4
#define RENDER_PLAYER_SHADOW_ORD 3
#define RENDER_BTWN_ISLAND_PLAYER 2
#define RENDER_ISLAND_ORD 1
#define RENDER_GAMEOBJ_ORD 0
#define VERT_CAMERA_OFFSET_SPD 65

@implementation GameRenderImplementation

+(void)update_render_on:(GameEngineLayer*)layer {
    Player* player = layer.player;
    
    [GameRenderImplementation update_zoom:layer];
    
    BOOL player_on_fg_island = (player.current_island != NULL) && (!player.current_island.can_land);
    if (player_on_fg_island) {
        if (player.zOrder != RENDER_PLAYER_ON_FG_ORD) {
            [layer reorderChild:player z:RENDER_PLAYER_ON_FG_ORD];
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

#define INIT_X 140
#define INIT_Y 80
#define INIT_Z 50
+(void)reset_camera:(CameraZoom*)c {
    c->x = INIT_X;
    c->y = INIT_Y;
    c->z = INIT_Z;
}

#define ZOOMSPD 50.0
//#define YDIR_DEFAULT 80.0
#define YDIR_ZOOMMAX 180.0
//480x320 
+(void)update_zoom:(GameEngineLayer*)layer {
    float g_dist = [GameRenderImplementation calc_g_dist:layer.player islands:layer.islands];
    CameraZoom state = layer.camera_state; 
    
    if (![Common fuzzyeq_a:layer.camera_state.x b:layer.tar_camera_state.x delta:0.1]) {
        state.x += (layer.tar_camera_state.x - layer.camera_state.x)/ZOOMSPD;
    }
    
    if (![Common fuzzyeq_a:layer.camera_state.y b:layer.tar_camera_state.y delta:0.1]) {
        state.y += (layer.tar_camera_state.y - layer.camera_state.y)/ZOOMSPD;
    }
    
    if (![Common fuzzyeq_a:layer.camera_state.z b:layer.tar_camera_state.z delta:0.1]) {
        state.z += (layer.tar_camera_state.z - layer.camera_state.z)/ZOOMSPD;
    }
    
    
    float YDIR_DEFAULT = layer.tar_camera_state.y;
    if (g_dist > 0) {
        float tmp = g_dist > 500.0 ? 500.0 : g_dist;
        float tar_yoff = 80.0 + (tmp / 500.0)*60.0;
        
        if (state.y > YDIR_DEFAULT-tar_yoff) {
            state.y -= (state.y - (YDIR_DEFAULT-tar_yoff))/ZOOMSPD;
        } else {
            state.y += ((YDIR_DEFAULT-tar_yoff)-state.y)/ZOOMSPD;
        }
        
    } else {
        if (state.y < YDIR_DEFAULT) {
            state.y += (YDIR_DEFAULT-state.y)/ (ZOOMSPD/2.0);
        }
    }
    
    [layer set_camera:state];
        
    [GameRenderImplementation update_camera_on:layer zoom:layer.camera_state];
}

+(void)update_camera_on:(CCLayer*)layer zoom:(CameraZoom)state {    
    [layer.camera setCenterX:state.x+50 centerY:state.y centerZ:0];
    [layer.camera setEyeX:state.x+50  eyeY:state.y eyeZ:state.z+60];
}

+(int)GET_RENDER_FG_ISLAND_ORD { return RENDER_FG_ISLAND_ORD; }
+(int)GET_RENDER_PLAYER_ORD { return RENDER_PLAYER_ORD; }
+(int)GET_RENDER_ISLAND_ORD { return RENDER_ISLAND_ORD; }
+(int)GET_RENDER_GAMEOBJ_ORD { return RENDER_GAMEOBJ_ORD; }
+(int)GET_RENDER_BTWN_PLAYER_ISLAND { return RENDER_BTWN_ISLAND_PLAYER; }

+(int)GET_RENDER_PLAYER_ON_FG_ORD { return RENDER_PLAYER_ON_FG_ORD; }
+(int)GET_RENDER_ABOVE_FG_ORD { return RENDER_ABOVE_FG_ORD; }
+(int)GET_RENDER_PLAYER_SHADOW_ORD { return RENDER_PLAYER_SHADOW_ORD; }

@end
