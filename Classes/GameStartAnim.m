#import "GameStartAnim.h"

#define ANIM_LENGTH 75.0

@implementation GameStartAnim

+(GameStartAnim*)init_with_callback:(CallBack*)cb {
    GameStartAnim *n = [GameStartAnim node];
    n.anim_complete = cb;
    [n initanim];
    [GEventDispatcher add_listener:n];
    return n;
}

-(void)initanim {
    readyimg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_STARTGAME_READY]];
    goimg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_STARTGAME_GO]];
    
    [self addChild:readyimg];
    [self addChild:goimg];
    [self setPosition:ccp([[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width/2)];
    
    [readyimg setOpacity:0];
    [goimg setOpacity:0];
    
    ct = ANIM_LENGTH;
}

-(void)update {
    ct--;
    if (ct <= 0) {
        [self anim_finished];
        return;
    }
    
    if (ct > ANIM_LENGTH/2) {
        float o = ct-ANIM_LENGTH/2;
        o = (o/(ANIM_LENGTH/2))*200+55;
        
        [goimg setOpacity:0];
        [readyimg setOpacity:(int)o];
    } else {
        float o = ct;
        o = (o/(ANIM_LENGTH/2))*200+55;
        
        [readyimg setOpacity:0];
        [goimg setOpacity:(int)o];
    }
}

@end
