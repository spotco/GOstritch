#import "MinionRobot.h"
#import "GameEngineLayer.h"

@implementation MinionRobot

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
    self.scaleX = -1;
    self.movedir = -1;
    [self setAnchorPoint:ccp(0.5,0)];
    [self setIMGWID:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"].size.width];
    [self setIMGHEI:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"].size.height];
    return self;
}

+(CCSprite*)spriteWithTexture:(CCTexture2D*)tex rect:(CGRect)rect {
    MinionRobot *t = [MinionRobot node];
    CCSprite *body = [CCSprite spriteWithTexture:tex rect:rect];
    t.body = body;
    body.position = ccp(0,t.IMGHEI/2);
    [t addChild:body];
    return t;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
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
    
    if (player.dashing && [Common hitrect_touch:[self get_hit_rect_rescale:0.8] b:[player get_hit_rect]]) {
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
        
    } else if (!player.dead && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [player add_effect:[HitEffect init_from:[player get_default_params] time:40]];
        [DazedParticle init_effect:g tar:player time:40];

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
    [up scale:float_random(10, 15)];
    
    player.current_island = NULL;
    player.vx = 0;
    player.vy = up.y;
    
    
    [up dealloc];
    
}

-(void)animmode_normal {[body setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"]];}
-(void)animmode_angry {[body setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot_angry"]];}
-(void)animmode_dead {[body setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot_dead"]];}
-(int)get_render_ord {return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];}

@end
