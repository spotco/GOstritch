#import "EnemyBomb.h"
#import "GameEngineLayer.h"
#import "Player.h" 

@interface BombSparkParticle : Particle {
    CGPoint vel;
    int ct;
}
+(BombSparkParticle*)cons_pt:(CGPoint)pt v:(CGPoint)v;
@end

@implementation BombSparkParticle
+(BombSparkParticle*)cons_pt:(CGPoint)pt v:(CGPoint)v {
    return [[BombSparkParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]] cons_pt:pt v:v];
}
-(id)cons_pt:(CGPoint)pt v:(CGPoint)v {
    [self setPosition:pt];
    vel = v;
    ct = 15;
    [self setScale:float_random(0.5, 0.9)];
    [self setColor:ccc3(251, 232, 52)];
    return self;
}
-(void)update:(GameEngineLayer *)g {
    [self setPosition:CGPointAdd(position_, vel)];
    [self setOpacity:255*(ct/15.0)];
    ct--;
}
-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD];
}
-(BOOL)should_remove {
    return ct <= 0;
}
@end



@implementation EnemyBomb

#define DEFAULT_SCALE 1.5

+(EnemyBomb*)cons_pt:(CGPoint)pt v:(CGPoint)vel {
    return [[EnemyBomb node] cons_pt:pt v:vel];
}

-(id)cons_pt:(CGPoint)pt v:(CGPoint)vel {
    [self setPosition:pt];
    active = YES;
    body = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_BOMB]];
    [body setAnchorPoint:ccp(15/31.0,16/45.0)];
    [body setPosition:ccp(0,20)];
    
    v = vel;
    vtheta = 20;
    
    [self addChild:body];
    [body setScale:DEFAULT_SCALE];
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    ct++;
    if (knockout) {
        [self setPosition:CGPointAdd(position_, v)];
        [body setOpacity:150];
        [body setRotation:body.rotation+25];
        if (ct > 20) {
            [g add_particle:[ExplosionParticle cons_x:position_.x y:position_.y]];
            
            [AudioManager playsfx:SFX_EXPLOSION];
            [g remove_gameobject:self];
        }
        
    } else if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        if (player.dashing) {
            v = ccp(player.vx*1.4,player.vy*1.4);
            knockout = YES;
            ct = 0;
            
        } else {
            [player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
            [g add_particle:[ExplosionParticle cons_x:position_.x y:position_.y]];
            
            [AudioManager playsfx:SFX_EXPLOSION];
            [g remove_gameobject:self];
        }
        
    } else if ([self has_hit_ground:g]) {
        [g add_particle:[ExplosionParticle cons_x:position_.x y:position_.y]];
        [AudioManager playsfx:SFX_EXPLOSION];
        [g remove_gameobject:self];
        
    } else {
        [self move:g];
        v.y-=0.25;
        v.y = MAX(-10,v.y);
        ct%2==0?[g add_particle:[BombSparkParticle cons_pt:[self get_tip] v:ccp(float_random(-5,5),float_random(-5, 5))]]:0;
        [body setRotation:body.rotation+vtheta];
        
    }
}

-(void)move:(GameEngineLayer*)g {
    [self setPosition:CGPointAdd(position_, v)];
}

-(BOOL)has_hit_ground:(GameEngineLayer*)g {
    line_seg mv = [Common cons_line_seg_a:position_ b:CGPointAdd(position_, v)];
    for (Island* i in g.islands) {
        line_seg li = [i get_line_seg];
        CGPoint ins = [Common line_seg_intersection_a:li b:mv];
        if (ins.x != [Island NO_VALUE]) {
            return YES;
        }
    }
    return NO;
}

#define TIPSCALE 70

-(CGPoint)get_tip {
    float arad = -[Common deg_to_rad:[body rotation]]+45;
    return ccp(position_.x+cosf(arad)*TIPSCALE*0.65,position_.y+sinf(arad)*TIPSCALE);
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:position_.x-20 y1:position_.y-20 wid:40 hei:40];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_PLAYER_ON_FG_ORD];
}

@end
