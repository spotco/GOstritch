#import "Coin.h"

@implementation Coin

+(Coin*)init_x:(float)posx y:(float)posy {
    Coin *new_coin = [Coin node];
    new_coin.position = ccp(posx,posy);
    return new_coin;
}

-(void) draw {
    [super draw];
    glColor4f(0.0,1.0f,0,1.0f);
    ccDrawCircle(ccp(0,0), 10, 0, 10, NO);
}

-(void)update_given:(Player*)player  {
    
}

@end
