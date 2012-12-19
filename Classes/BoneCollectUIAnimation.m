
#import "BoneCollectUIAnimation.h"

#define CTMAX 50

@implementation BoneCollectUIAnimation

+(BoneCollectUIAnimation*)init_start:(CGPoint)start end:(CGPoint)end {
    BoneCollectUIAnimation *b = [BoneCollectUIAnimation node];
    [b cons_start:start end:end];
    [GEventDispatcher add_listener:b];
    return b;
}

-(void)cons_start:(CGPoint)tstart end:(CGPoint)tend {
    [self addChild:[CCSprite spriteWithTexture:[Resource get_aa_tex:TEX_GOLDEN_BONE]]];
    start = tstart;
    end = tend;
    [self setPosition:start];
    ct = CTMAX;
}

-(void)update {
    float pct = (CTMAX - ((float)ct))/CTMAX;
    CGPoint tar = ccp((end.x - start.x)*pct + start.x, (end.y-start.y)*pct + start.y);
    [self setPosition:tar];
    [self setOpacity:((int)((1-pct)*255))];
    
    float tarscale = 2;
    if (ct > 35) {
        tarscale = ((15-(ct-35))/15.0)+1;
    } else {
        tarscale = 2*ct/35.0;
    }
    [self setScale:tarscale];    
    
    ct--;
}

- (void)setOpacity:(GLubyte)opacity {
	[super setOpacity:opacity];
	for(CCSprite *sprite in [self children]) {
		sprite.opacity = opacity;
	}
}

@end
