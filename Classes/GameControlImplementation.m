#import "GameControlImplementation.h"
#import "GameEngineLayer.h"

#define JUMP_HOLD_TIME 15
#define JUMP_POWER 8.5
#define JUMP_FLOAT_SCALE 1

@implementation GameControlImplementation

static BOOL queue_swipe = NO;
static CGPoint swipe_dir;
static BOOL queue_jump = NO;
static int jump_hold_timer = 0;

static BOOL is_touch_down = NO;
static int touch_timer = 0;
static int touch_move_counter = 0;
static float touch_dist_sum = 0;
static CGPoint prev;

+(void)touch_begin:(CGPoint)pt {
    is_touch_down = YES;
    touch_move_counter = 0;
    touch_dist_sum = 0;
    touch_timer = 0;
    prev = pt;
    
    queue_jump = YES;
}

static float avg_x;
static float avg_y;

+(void)touch_move:(CGPoint)pt {
    touch_move_counter++;
    touch_dist_sum += [Common distanceBetween:prev and:pt];
    
    avg_x += pt.x-prev.x;
    avg_y -= pt.y-prev.y;
    
    if(touch_move_counter == 3) {
        float avg = touch_dist_sum/touch_move_counter;
        if (avg > 5) {
            Vec3D* v = [Vec3D init_x:avg_x/touch_move_counter y:avg_y/touch_move_counter z:0];
            [v normalize];
            
            if (ABS([v get_angle_in_rad]) < M_PI*(3.0/4.0)) {
                queue_swipe = YES;
                swipe_dir = ccp(ABS(v.x),v.y);
            }
            [v dealloc];
        }
        touch_move_counter = 0;
        touch_dist_sum = 0;
        avg_x = 0;
        avg_y=0;
    }
    
    prev = pt;
}

+(void)touch_end:(CGPoint)pt {
    is_touch_down = NO;
    touch_timer = 0;
}


+(void)control_update_player:(GameEngineLayer*)g {
    Player* player = g.player;
    
    if (player.dead){
        return;
    }
    
    if (player.current_swingvine != NULL && (queue_jump || queue_swipe)) {
        CGPoint t_vel = [player.current_swingvine get_tangent_vel];
        [player.current_swingvine temp_disable];
        player.current_swingvine = NULL;
        player.up_vec.y = 1;
        player.up_vec.x = 0;
        
        player.vx = t_vel.x;
        player.vy = t_vel.y;
        
        [[player get_current_params] add_airjump_count];
    }
    
    if (player.current_island != NULL) { //reset jump count on ground
        [[player get_current_params] add_airjump_count];
    }
    
    if (queue_swipe == YES && player.current_island == NULL && [player get_current_params].cur_dash_count > 0) {
        [[player get_current_params] decr_dash_count];
        [player add_effect:[DashEffect init_from:[player get_default_params] vx:swipe_dir.x vy:swipe_dir.y]];
    }
    queue_swipe = NO;
    
    
    if (queue_jump == YES) { //initial jump
        
        if (player.dashing) {
            [player remove_temp_params:g]; //note bug here is dashing then jump into ndir -1 wall, fix by removing dash param
        }
        
        if (player.current_island != NULL) {
            [GameControlImplementation player_jump_from_island:player];
            jump_hold_timer = JUMP_HOLD_TIME;
            [[player get_current_params] decr_airjump_count];
            
        } else if ([player get_current_params].cur_airjump_count > 0) {
            [GameControlImplementation player_double_jump:player];
            jump_hold_timer = JUMP_HOLD_TIME;
            [[player get_current_params] decr_airjump_count];
            
        }
    }
    queue_jump = NO;
    
    
    
    if (is_touch_down && jump_hold_timer > 0) { //hold to jump higher
        jump_hold_timer--;
        float pct_left = ((float)jump_hold_timer)/((float)JUMP_HOLD_TIME);
        float scale = JUMP_FLOAT_SCALE;
        player.vx += player.up_vec.x *pct_left*scale;
        player.vy += player.up_vec.y *pct_left*scale;
        player.floating = NO;
    } 
    
    if (player.current_island != NULL) {
        touch_timer = 0;
    } else if (is_touch_down) {
        touch_timer++;
    }
        
    if (is_touch_down && touch_timer > 25 && player.current_island == NULL) { //hold to float
        player.floating = YES;
    } else {
        player.floating = NO;
    }
}

+(void)player_double_jump:(Player*)player {    
    player.vx += player.up_vec.x*JUMP_POWER;
    player.vy = player.up_vec.y*JUMP_POWER;
    player.current_swingvine = NULL;
}

+(void)reset_control_state {
    queue_swipe = NO;
    queue_jump = NO;
    jump_hold_timer = 0;
    
    is_touch_down = NO;
    touch_timer = 0;
    touch_move_counter = 0;
    touch_dist_sum = 0;
}



+(void)player_jump_from_island:(Player*)player {
    float mov_speed = sqrtf(powf(player.vx, 2) + powf(player.vy, 2));
    
    Vec3D *tangent = [player.current_island get_tangent_vec];
    Vec3D *up = [[Vec3D Z_VEC] crossWith:tangent];
    [tangent normalize];
    [up normalize];
    if (player.current_island.ndir == -1) {
        [up scale:-1];
    }
    
    [tangent scale:mov_speed];
    [up scale:JUMP_POWER];
    

    Vec3D *combined = [up add:tangent];
    Vec3D *cur_tangent_vec = [player.current_island get_tangent_vec];
    Vec3D *calc_up = [[Vec3D Z_VEC] crossWith:cur_tangent_vec];
    [calc_up scale:2];
    player.position = [calc_up transform_pt:player.position];
    
    
    //combined.x = MAX(tangent.x,combined.x);
    
    player.vx = combined.x;
    player.vy = combined.y;
    player.current_island = NULL;
    player.current_swingvine = NULL;
    
    [calc_up dealloc];
    [up dealloc];
    [combined dealloc];
    [tangent dealloc];
    [cur_tangent_vec dealloc];
    
}

@end
