#import "MinionRobot.h"
#import "GameEngineLayer.h"

@implementation MinionRobot

#define DEFAULT_SCALE 0.83

@synthesize body;

+(MinionRobot*)cons_x:(float)x y:(float)y {
    MinionRobot *r = [MinionRobot spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROBOT] 
                                               rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"]];
    [r setPosition:ccp(x,y)];
    [r setStarting_position:ccp(x,y)];
    r.active = YES;
    return r;
}

-(id)init {
    self = [super init];
    self.scaleX = -DEFAULT_SCALE;
    self.movedir = -1;
    [self setIMGWID:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"].size.width*DEFAULT_SCALE];
    [self setIMGHEI:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"].size.height*DEFAULT_SCALE];
    return self;
}

+(CCSprite*)spriteWithTexture:(CCTexture2D*)tex rect:(CGRect)rect {
    MinionRobot *t = [MinionRobot node];
    CCSprite *body = [CCSprite spriteWithTexture:tex rect:rect];
    t.body = body;
    body.position = ccp(0,t.IMGHEI/2);
    [t addChild:body];
    [body setScale:DEFAULT_SCALE];
    [t setScale:DEFAULT_SCALE];
    return t;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!has_shadow) {
       [g add_gameobject:[ObjectShadow cons_tar:self]];
        has_shadow = YES;
    }
    
    self.vx = 0;
    [super update:player g:g];
    
    BOOL see = player.position.x < position_.x;
    
    if (busted) {
        if (self.current_island == NULL) {
            body.rotation+=25;
        }
        return;
    } else {
        [self animmode_angry];
    }
    
    if (see && self.current_island != NULL) {
        [self jump_from_island];
    }
    
    if (!player.dead && player.current_island == NULL && player.vy <= 0 && [Common hitrect_touch:[self get_full_hit_rect] b:[player get_jump_rect]]) {
        busted = YES;
        self.vy = -ABS(self.vy);
        [self animmode_dead];
        
        int ptcnt = arc4random_uniform(4)+4;
        for(float i = 0; i < ptcnt; i++) {
            [g add_particle:[BrokenMachineParticle init_x:position_.x
                                                        y:position_.y
                                                       vx:float_random(-5, 5)
                                                       vy:float_random(-3, 10)]];
        }
        player.vy = 8;
        [AudioManager playsfx:SFX_BOP];
    
    } else if (player.dashing && [Common hitrect_touch:[self get_hit_rect_rescale:0.8] b:[player get_hit_rect]]) {
        busted = YES;
        self.vy = -ABS(self.vy);
        [self animmode_dead];
        
        int ptcnt = arc4random_uniform(4)+4;
        for(float i = 0; i < ptcnt; i++) {
            [g add_particle:[BrokenMachineParticle init_x:position_.x
                                                            y:position_.y
                                                           vx:float_random(-5, 5) 
                                                           vy:float_random(-3, 10)]];
        }
        [AudioManager playsfx:SFX_ROCKBREAK];
        
    } else if (!player.dead && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [player add_effect:[HitEffect init_from:[player get_default_params] time:40]];
        [DazedParticle init_effect:g tar:player time:40];
        [AudioManager playsfx:SFX_HIT];

    }
}

-(void)reset {
    [super reset];
    [self setPosition:self.starting_position];
    [self animmode_normal];
    self.movex = 0;
    busted = NO;
    body.rotation = 0;
}

-(void)jump_from_island {
    id<PhysicsObject> player = self;
    Vec3D *up = [Vec3D init_x:0 y:1 z:0];
    [up scale:float_random(10, 11)];
    
    player.current_island = NULL;
    player.vx = 0;
    player.vy = up.y;
    
    
    [up dealloc];
    
}

-(HitRect)get_full_hit_rect { return [Common hitrect_cons_x1:position_.x-20 y1:position_.y wid:50 hei:80];}
-(void)animmode_normal {[body setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"]];}
-(void)animmode_angry {[body setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot_angry"]];}
-(void)animmode_dead {[body setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot_dead"]];}
-(int)get_render_ord {return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];}

@end
