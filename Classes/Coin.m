#import "Coin.h"

@implementation Coin

+(Coin*)init_x:(float)posx y:(float)posy {
    Coin *new_coin = [Coin node];
    new_coin.active = YES;
    new_coin.position = ccp(posx,posy);
    
    CCTexture2D *texture = [Resource get_tex:@"golden_bone"];
    CCSprite *img = [CCSprite spriteWithTexture:texture];
    [new_coin addChild:img];
    
    //NSLog(@"%f,%f",new_coin.position.x,new_coin.position.y);
    return new_coin;
}

/*-(void) draw {
    [super draw];
	glColor4ub(255,0,0,100);
    glLineWidth(1.0f);
    ccDrawCircle(ccp(0,0), 10, 0, 10, NO);
}*/

-(CGRect)get_hit_rect {
    return CGRectMake([self position].x-10,[self position].y-10,20,20);
}

-(void)update:(Player*)player {
    if (!active) {
        return;
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
    
    
    if (CGRectIntersectsRect([self get_hit_rect],[player get_hit_rect])) {
        player.vx *= 1.5;
        player.vy *= 1.2;
        [self set_active:NO];
    }
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
