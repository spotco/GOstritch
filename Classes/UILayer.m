#import "UILayer.h"
#import "GameEngineLayer.h"

@implementation UILayer

-(id) init{
	if( (self = [super init])) {
        CCSprite *a = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_COINCOUNT]];
        a.anchorPoint = ccp(0,0);
        a.position = ccp(0,[[UIScreen mainScreen] bounds].size.width - a.boundingBox.size.height);
        coincount = a;
        [self addChild:a];
        
        CCSprite *b = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_PAUSEICON]];
        b.anchorPoint = ccp(0,0);
        b.position = ccp([[UIScreen mainScreen] bounds].size.height - b.boundingBox.size.width , 
        [[UIScreen mainScreen] bounds].size.width - b.boundingBox.size.height);
        [self addChild:b];
        pausebutton = b;
        
        
        CCSprite *c = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_PAUSEMENU]];
        c.anchorPoint = ccp(0,0);
        c.position = ccp(0,0);
        c.visible = NO;
        menu = c;
        [self addChild:c];
        
        self.isTouchEnabled = YES;
	}
	return self;
}

CCSprite *coincount;
CCSprite *menu;
CCSprite *pausebutton;

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {
    BOOL toggle = NO;
    if (menu.visible) {
        toggle = YES;
    }
    
    for (UITouch* t in pTouches) {
        CGPoint loc = [t locationInView:[t view]];
        loc.y = -loc.y + [[UIScreen mainScreen] bounds].size.width;
        
        if (CGRectContainsPoint([pausebutton boundingBox], loc)) {
            toggle = YES;
        }
    
    }
    
    if (toggle) {
        menu.visible = [GameEngineLayer singleton_toggle_pause];
        //coincount.visible = !menu.visible;
        pausebutton.visible = !menu.visible;
        
    }
    
}

@end