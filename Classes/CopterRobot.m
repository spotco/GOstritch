#import "CopterRobot.h"
#import "GameEngineLayer.h"

@implementation CopterRobot

#define ARM_DEFAULT_POSITION ccp(-30,-50)

+(CopterRobot*)cons_x:(float)x y:(float)y {
    return [[CopterRobot node] init_at:ccp(x,y)];
}

-(CopterRobot*)init_at:(CGPoint)pos {
    [self setPosition:pos];
    self.active = NO;
    [self init_anims];
    [self setScaleX:-1];
    player_pos = CGPointZero;
    initial_pos = pos;
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!self.active && player.position.x > position_.x) {
        active = YES;
        player_pos = player.position;
        [self set_pos_rel:ccp(-1000,1000)];
        [GEventDispatcher push_event:[[GEvent init_type:GEventType_BOSS1_ACTIVATE] add_pt:player_pos]];
        
    } else if (self.active) {
        player_pos = player.position;
        [self set_pos_rel:ccp(100,100)];
    }
}

-(void)reset {
    [super reset];
    self.active = NO;
    player_pos = CGPointZero;
    [self setPosition:initial_pos];
}

-(void)set_pos_rel:(CGPoint)pos {
    [self setPosition:ccp(pos.x+player_pos.x,pos.y+player_pos.y)];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:position_.x-40 y1:position_.y-60 wid:80 hei:80];
}

-(void)init_anims {
    body = [CCSprite spriteWithTexture:[Resource get_aa_tex:TEX_ENEMY_COPTER] 
                                  rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"body"]];
    [self addChild:body];
    
    aux_prop = [CCSprite node];
    [aux_prop runAction:[self init_anim:[NSArray arrayWithObjects:@"aux_prop_0",@"aux_prop_1",@"aux_prop_2",nil] speed:0.05]];
    [aux_prop setPosition:ccp(-80,-10)];
    [self addChild:aux_prop];
    
    main_prop = [CCSprite node];
    [main_prop runAction:[self init_anim:[NSArray arrayWithObjects:@"main_prop_0",@"main_prop_1",nil] speed:0.05]];
    [main_prop setPosition:ccp(-5,75)];
    [self addChild:main_prop];
    
    main_nut = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER] 
                                      rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"main_bolt"]];
    [main_nut setPosition:ccp(7,77)];
    [self addChild:main_nut];
    
    aux_nut = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER] 
                                     rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"aux_bolt"]];
    [aux_nut setPosition:ccp(-80,-10)];
    [self addChild:aux_nut];
    
    arm = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER] 
                                 rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"arm"]];
    [arm setPosition:ARM_DEFAULT_POSITION];
    [self addChild:arm];
}

-(CCAction*)init_anim:(NSArray*)a speed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_ENEMY_COPTER];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a) [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:k]]];
    return [Common make_anim_frames:animFrames speed:speed];
}

@end
