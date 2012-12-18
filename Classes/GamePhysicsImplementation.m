#import "GamePhysicsImplementation.h"

//Used in move along island
#define ABS_MAX_SPEED 20
#define SLOPE_ACCEL 0.5
#define FRICTION 0.96
#define TO_GROUND_ROTATION_SPEED 0.3



//Used in freefall
#define CENTERING_UP_VEC_SPD 0.07
#define MAX_LOSS 0.3

@implementation GamePhysicsImplementation


+(void)player_move:(Player*)player with_islands:(NSMutableArray*)islands {
    if (player.current_swingvine != NULL) {
        return;
    }
    
    if (player.current_island == NULL) {
        player.position = [GamePhysicsImplementation player_free_fall:player islands:islands];
    } else {
        player.position = [GamePhysicsImplementation player_move_along_island:player islands:islands];
    }
}


+(CGPoint)player_move_along_island:(Player*)player islands:(NSMutableArray*)islands {
    float MIN_SPEED = [player get_current_params].cur_min_speed;
    
    Island *i = player.current_island;
    Vec3D *tangent_vec = [i get_tangent_vec];
    
    if (i.ndir < 0) {
        player.scaleY = -1;
        player.last_ndir = -1;
    } else {
        player.scaleY = 1;
        player.last_ndir = 1;
    }
    player.scaleX = 1;
    
    if (tangent_vec.y < 0) {
        float ang = [tangent_vec get_angle_in_rad];
        if (ang < -M_PI_2) {
            ang = ang + M_PI;
        }
        float pct = ABS(ang/M_PI_2);
        
        player.vx += SLOPE_ACCEL *pct;
        player.vy += SLOPE_ACCEL *pct;
        
        MIN_SPEED += (ABS_MAX_SPEED - MIN_SPEED)*(pct);
    }
    
    float mov_speed = sqrtf(powf(player.vx, 2) + powf(player.vy, 2));
    
    if (mov_speed > ABS_MAX_SPEED) {
        mov_speed = ABS_MAX_SPEED;
    }
    if (mov_speed > MIN_SPEED) {
        player.vx *= FRICTION;
        player.vy *= FRICTION;
    }
    if (mov_speed < MIN_SPEED) {
        float acc = (MIN_SPEED - mov_speed)/5;
        player.vx += acc;
        player.vy += acc;
    }
    
    float t = [i get_t_given_position:player.position];
    float t_final = t+mov_speed;
    CGPoint position_final = [i get_position_given_t:t_final];
    
    Vec3D *tmp = player.up_vec;
    player.up_vec = [[Vec3D Z_VEC] crossWith:tangent_vec];
    [player.up_vec normalize];
    [player.up_vec scale:i.ndir];
    [tmp dealloc];
    
    float tar_rad = -[tangent_vec get_angle_in_rad];
    float tar_deg = [Common rad_to_deg:tar_rad];
    float dir = [Common shortest_dist_from_cur:player.rotation to:tar_deg];
    player.rotation += dir*TO_GROUND_ROTATION_SPEED;
    
    
    if (position_final.x == [Island NO_VALUE] || position_final.y == [Island NO_VALUE]) {
        if (i.next != NULL) {
            float t_sum = mov_speed;
            t_sum -= [i get_t_given_position:ccp(i.endX,i.endY)] - t;
            player.current_island = i.next;
            if ([player.current_island get_position_given_t:t_sum].x != [Island NO_VALUE] && [player.current_island get_position_given_t:t_sum].y != [Island NO_VALUE]) {
                position_final = [player.current_island get_position_given_t:t_sum];
            } else {
                position_final = ccp(player.current_island.endX,player.current_island.endY);
            }
        } else {
            position_final = ccp(player.position.x + tangent_vec.x*mov_speed, player.position.y + tangent_vec.y*mov_speed);
            player.current_island = NULL;
            player.vx = tangent_vec.x * mov_speed;
            player.vy = tangent_vec.y * mov_speed;
        }
    }
    
    [tangent_vec dealloc];
    return position_final;
}

+(CGPoint)player_free_fall:(Player*)player islands:(NSMutableArray*)islands {
    float GRAVITY = [player get_current_params].cur_gravity;
    if (player.floating) {
        GRAVITY = GRAVITY * 0.55;
    }
    
    if (player.last_ndir == -1 && player.vx < 0) {
        player.scaleX = -1;
    } else if (player.last_ndir == 1) {
        player.scaleX = 1;
    }
    player.scaleY = 1;
    
    float cur_ang = [Common rad_to_deg:[player.up_vec get_angle_in_rad]];
    float tar_ang = 90;
    float rot_by = [Common shortest_dist_from_cur:cur_ang to:tar_ang]*CENTERING_UP_VEC_SPD;
    rot_by = [Common deg_to_rad:rot_by];
    Vec3D *tmp = player.up_vec;
    
    Vec3D *rot_vec = [tmp rotate_vec_by_rad:rot_by];
    player.up_vec = rot_vec;
    [tmp dealloc];
    
    CGPoint player_pre = player.position;
    CGPoint player_post = ccp(player.position.x+player.vx,player.position.y+player.vy);
    line_seg player_mov = [Common cons_line_seg_a:player_pre b:player_post];
    Vec3D *player_mov_vec = [Vec3D init_x:player_mov.b.x - player_mov.a.x y:player_mov.b.y - player_mov.a.y z:0];
    
    Island* contact_island = NULL;
    CGPoint contact_intersection;
    line_seg contact_segment;
    
    for (Island *i in islands) {     
        line_seg island_seg = [i get_line_seg];
        CGPoint intersection = [Common line_seg_intersection_a:player_mov b:island_seg];
        Vec3D* inormal_vec = [i get_normal_vecC];
        if (i.can_land && intersection.x != [Island NO_VALUE] && intersection.y != [Island NO_VALUE] && ABS([Vec3D rad_angle_between_a:player_mov_vec and_b:inormal_vec]) >= M_PI / 2) {
            contact_island = i;
            contact_intersection = intersection;
            contact_segment = island_seg;
        }
    }
    [player_mov_vec dealloc];
    
    if (contact_island != NULL) {
        player.current_island = contact_island;
        player.position = contact_intersection;
        
        Vec3D *a = [Vec3D init_x:player_mov.b.x - player_mov.a.x y:player_mov.b.y - player_mov.a.y z:0];
        Vec3D *b = [Vec3D init_x:contact_segment.b.x - contact_segment.a.x y:contact_segment.b.y - contact_segment.a.y z:0];
        float theta = [Vec3D rad_angle_between_a:a and_b:b];
        if (theta < M_PI) {
            player.vx *= MAX((M_PI - theta)/(M_PI),MAX_LOSS);
            player.vy *= MAX((M_PI - theta)/(M_PI),MAX_LOSS);
        } else {
            player.vx *= MAX_LOSS;
            player.vy *= MAX_LOSS;
        }
        [a dealloc];
        [b dealloc];
        
    } else {
        float grav_const = GRAVITY;
        player.vx += grav_const * player.up_vec.x;
        player.vy += grav_const * player.up_vec.y;
        //player.vy += grav_const;
    }
    
    return player_post;
}


@end
