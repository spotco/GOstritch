#import "GameControlImplementation.h"

@implementation GameControlImplementation

+(void)control_update_player:(Player*)player 
                       state:(GameControlState*)state 
                     islands:(NSMutableArray*)islands 
                     objects:(NSMutableArray*)game_objects {
}

+(void)touch_begin:(GameControlState*)state at:(CGPoint)pt {
    [state start_touch:pt];
    
}

+(void)touch_end:(GameControlState*)state at:(CGPoint)pt {
    CGPoint last_touch = state.last_touch;
    [state end_touch];
    
    float dist = sqrtf(powf(pt.y-last_touch.y, 2) + powf(pt.x - last_touch.x, 2));
    NSLog(@"dist:%f",dist);
    
}

/*-(void)player_control_update {
    
     if (player.vx < 3) {
     player.vx += 0.1;
     }
     if (is_contact) {
     player.airjump_count = MAX(player.airjump_count,1);
     }
     
     if (is_touch) {
     player.touch_count+=0.5;
     player.vx = MAX(player.vx*0.99,4);
     } else if (player.touch_count != 0) { 
     if (is_contact && player.current_island != NULL) {
     
     float JUMP_POWER = 17.5;
     float FORWARD_JUMP_SCALE = 0.4;
     
     Vec3D *up = player.up_vec;
     Vec3D *tangent = [player.current_island get_tangent_vec];
     [tangent scale:FORWARD_JUMP_SCALE];
     Vec3D *combined = [up add:tangent];
     [combined normalize];
     
     [tangent dealloc];
     
     player.position = [player.up_vec transform_pt:player.position];
     player.vx = combined.x*JUMP_POWER;
     player.vy = combined.y*JUMP_POWER;
     
     [combined dealloc];
     
     player.current_island = NULL;
     } else if (player.airjump_count > 0) {
     player.airjump_count--;
     player.vy = MIN(player.touch_count,15);
     }
     player.touch_count = 0;
     }
     
     if (!is_touch) {
     player.vx = MIN(player.vx*1.01,8);
     }
}*/

@end
