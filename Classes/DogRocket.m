#import "DogRocket.h"

@implementation DogRocket

+(DogRocket*)init_x:(float)x y:(float)y {
    DogRocket *new_rocket = [DogRocket node];
    new_rocket.active = YES;
    new_rocket.position = ccp(x,y);
    
    CCTexture2D *texture = [Resource get_tex:TEX_DOG_ROCKET];
    new_rocket.img = [CCSprite spriteWithTexture:texture];
    [new_rocket addChild:new_rocket.img];
    
    return new_rocket;
}

//TODO -- launch in direction of slope
-(GameObjectReturnCode)update:(Player*)player {
    if (!active) {
        return GameObjectReturnCode_NONE;
    }
    
    float rot = [self rotation];
    if (anim_toggle) {
        rot+=0.5;
        if (rot > 10) {
            anim_toggle = !anim_toggle;
        }
    } else {
        rot-=0.5;
        if (rot < -10) {
            anim_toggle = !anim_toggle;
        }
    }
    [self setRotation:rot];
    
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        PlayerEffectParams *e = [DogRocketEffect init_from:[player get_default_params]];
        player.vx += ABS(player.vy);
        player.vy = 0;
        [player add_effect:e];
        NSLog(@"FUCKr:%i",[player get_current_params].time_left);
        [self set_active:NO];
    }
    
    return GameObjectReturnCode_NONE;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-10 y1:[self position].y-10 wid:20 hei:20];
}

-(void)set_active:(BOOL)t_active {
    if (t_active) {
        visible_ = YES;
    } else {
        visible_ = NO;
    }
    active = t_active;
}

@end
