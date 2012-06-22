#import "Coin.h"

@implementation Coin

+(Coin*)init_x:(float)posx y:(float)posy {
    Coin *new_coin = [Coin node];
    new_coin.active = YES;
    new_coin.position = ccp(posx,posy);
    NSLog(@"%f,%f",new_coin.position.x,new_coin.position.y);
    return new_coin;
}

-(void) draw {
    if (!active) {
        return;
    }
    [super draw];
   
	glColor4ub(255,0,0,100);
    glLineWidth(1.0f);
    ccDrawCircle(ccp(0,0), 10, 0, 10, NO);
}

-(CGRect)get_hit_rect {
    return CGRectMake([self position].x-10,[self position].y-10,20,20);
}

-(void)update:(Player*)player {
    if (!active) {
        return;
    }
    if (CGRectIntersectsRect([self get_hit_rect],[player get_hit_rect])) {
        player.vx *= 0.5;
        player.vy *= 0.7;
        active = NO;
    }
}

@end
