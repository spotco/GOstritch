#import "Coin.h"

@implementation Coin

+(Coin*)init_x:(float)posx y:(float)posy {
    Coin *new_coin = [Coin node];
    new_coin.position = ccp(posx,posy);
    return new_coin;
}

-(void) draw {
    [super draw];
	glColor4ub(255,255,0,100);
    glLineWidth(1.0f);
    ccDrawCircle(ccp(0,0), 10, 0, 10, NO);
}

-(CGRect)get_hit_rect {
    return CGRectMake([self position].x-10,[self position].y-10,20,20);
}

-(void)update:(Player*)player  {
    
}

@end
