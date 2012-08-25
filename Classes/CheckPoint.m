#import "CheckPoint.h"
#import "GameEngineLayer.h"

@implementation CheckPoint

+(CheckPoint*)init_x:(float)x y:(float)y {
    CheckPoint *p = [CheckPoint node];
    p.position = ccp(x,y);

    [p init_img];
    
    p.active = YES;
    
    return p;
}

float texwid,texhei;

+(CCSprite*)makeimg:(CCTexture2D*)tex {
    CCSprite *i = [CCSprite spriteWithTexture:tex];
    i.position = ccp(0,[i boundingBoxInPixels].size.height / 2.0);
    return i;
}

-(CGPoint)get_center {
    HitRect r = [self get_hit_rect];
    return ccp((r.x2-r.x1)/2+r.x1,(r.y2-r.y1)/2+r.y1);
}

-(void)init_img {
    CCTexture2D *tex1 = [Resource get_tex:TEX_CHECKPOINT_1];
    CCTexture2D *tex2 = [Resource get_tex:TEX_CHECKPOINT_2];
    inactive_img = [CheckPoint makeimg:tex1];
    active_img = [CheckPoint makeimg:tex2];
    [self addChild:inactive_img];
    [self addChild:active_img];
    inactive_img.visible = YES;
    active_img.visible = NO;
    
    texwid = [tex1 contentSizeInPixels].width;
    texhei = [tex1 contentSizeInPixels].height;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:position_.x-texwid/2 y1:position_.y wid:texwid hei:texhei];
}

-(GameObjectReturnCode)update:(Player*)player g:(GameEngineLayer *)g{
    [super update:player g:g];
    if (self.active && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]] && ![self is_activated]) {
        self.active = NO;
        inactive_img.visible = NO;
        active_img.visible = YES;
        
        CGPoint center = [self get_center];
        [g set_checkpoint_to:center];
        for(int i = 0; i < 5; i++) {
            [g add_particle:[FireworksParticleA init_x:center.x y:center.y vx:float_random(-3,3) vy:float_random(9,14) ct:arc4random_uniform(20)+10]];
        }
    }
    
    return GameObjectReturnCode_NONE;
}

-(BOOL)is_activated {
    return active_img.visible;
}


@end
