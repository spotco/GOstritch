#import "DogBone.h"
#import "PlayerEffectParams.h"
#import "GameEngineLayer.h"

@implementation DogBone

@synthesize bid;

+(DogBone*)init_x:(float)posx y:(float)posy bid:(int)bid {
    DogBone *new_coin = [DogBone node];
    new_coin.active = YES;
    [new_coin init:ccp(posx,posy)];
    new_coin.bid = bid;
    
    CCTexture2D *texture = [Resource get_aa_tex:TEX_GOLDEN_BONE];
    new_coin.img = [CCSprite spriteWithTexture:texture];
    [new_coin addChild:new_coin.img];
    
    return new_coin;
}

-(void)init:(CGPoint)start {
    [self setPosition:start];
    initial_pos = start;
    follow = NO;
}

-(void)setPosition:(CGPoint)position {
    initial_pos = position;
    [super setPosition:position];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-10 y1:[self position].y-10 wid:20 hei:20];
}

-(GameObjectReturnCode)update:(Player*)player g:(GameEngineLayer *)g{
    [super update:player g:g];
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
    
    float maxdist = 150;
    float dist = [Common distanceBetween:position_ and:player.position];
    [self setPosition:ccp(position_.x + vx, position_.y+vy)];
    if (!follow && player.dashing && dist < maxdist) {
        follow = YES;
    }
    
    if (follow) {
        Vec3D* vel = [Vec3D init_x:player.position.x-position_.x y:player.position.y-position_.y z:0];
        [vel normalize];
        [vel scale:sqrtf(powf(player.vx, 2) + powf(player.vy, 2))*1.2];
        vx = vel.x;
        vy = vel.y;
        [vel dealloc];
    } else {
        vx = 0;
        vy = 0;
    }
    
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [g set_bid_tohasget:bid];
        [self set_active:NO];
    }
    
    return GameObjectReturnCode_NONE;
}

-(void)set_active:(BOOL)t_active {
    if (t_active) {
        visible_ = YES;
    } else {
        visible_ = NO;
    }
    active = t_active;
}

-(void)reset {
    [super reset];
    [self setPosition:initial_pos];
    follow = NO;
    vx = 0;
    vy = 0;
}

@end
