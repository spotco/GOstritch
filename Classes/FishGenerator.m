#import "FishGenerator.h"

#define SPAWN_MARGIN 25
#define SPAWN_WAIT_BASE 100

#define FISH_GRAVITY 0.1
#define FISH_VEL_VARIANCE 5
#define FISH_XVEL_OFFSET -2
#define FISH_YVEL_OFFSET 3

@interface Fish: CCSprite {
    float vx,vy;
    int wait;
}
-(void)update:(float)bwidth hei:(float)hei;
@end

@implementation Fish
-(id)init{
    wait = rand()%((int)SPAWN_MARGIN*5);
    return [super init];
}
-(void)update:(float)bwidth hei:(float)hei {    
    if(wait > 0) {
        wait--;
        if (wait == 0) {
            float npos = rand()%((int)(bwidth-SPAWN_MARGIN*2));
            npos+=SPAWN_MARGIN;
            [self setVisible:YES];
            [self setPosition:ccp(npos,hei)];
            vx = (rand()%FISH_VEL_VARIANCE)+FISH_XVEL_OFFSET;
            vy = rand()%FISH_VEL_VARIANCE+FISH_YVEL_OFFSET;
        }
        return;
    }
    
    [self setPosition:ccp(position_.x+vx,position_.y+vy)];
    vy-=FISH_GRAVITY;
    
    if(position_.y < hei) {
        [self setPosition:ccp(0,0)];
        [self setVisible:NO];
        wait = SPAWN_WAIT_BASE;
    }
    
    Vec3D *dv = [Vec3D init_x:vx y:vy z:0];
    [dv normalize];
    float rot = -[Common rad_to_deg:[dv get_angle_in_rad]];
    rotation_ = rot;
    [dv dealloc];
}
-(void)dealloc {
    [self stopAllActions];
    [super dealloc];
}
@end

@implementation FishGenerator

+(FishGenerator*)init_ofwidth:(float)wid basehei:(float)hei {
    FishGenerator *n = [FishGenerator node];
    n.anchorPoint = ccp(0,0);
    [n init_given_width:wid basehei:hei];
    return n;
}

-(void)init_given_width:(float)wid basehei:(float)hei {
    bwidth = wid;
    bheight = hei;
    
    CCTexture2D *tex = [Resource get_aa_tex:TEX_FISH_SS];
    NSMutableArray *names = [NSMutableArray arrayWithObjects:@"green_%i",@"purple_%i",@"red_%i",@"yellow_%i", nil];
    fishes = [NSMutableArray array];
    [fishes retain];
    
    for (NSString* n in names) {
        CCSprite *f = [self fish_from_formatstring:n and_tex:tex];
        [self addChild:f];
        [fishes addObject:f];
    } 
}


-(CCSprite*)fish_from_formatstring:(NSString*)tar and_tex:(CCTexture2D*)tex {
    CCSprite *n = [Fish node];
    NSMutableArray *animFrames = [NSMutableArray array];
    for(int i = 1; i <= 3; i++) {
        CCSpriteFrame *c = [CCSpriteFrame frameWithTexture:tex rect:[FishGenerator fish_ss_spritesheet_rect_tar:[NSString stringWithFormat:tar,i]]];
        [animFrames addObject:c];
    }
    [n runAction:[Common make_anim_frames:animFrames speed:0.1]];
    n.scale = 0.5;
    n.position = ccp(0,-100);
    return n;
}

-(void)update {
    for (Fish* i in fishes) {
        [i update:bwidth hei:bheight];
    }
}

#define FISH_SS_FILENAME @"fish_ss"
static NSDictionary *fish_ss_plist_dict = NULL;
+(CGRect)fish_ss_spritesheet_rect_tar:(NSString*)tar {
    if (fish_ss_plist_dict == NULL) {
        fish_ss_plist_dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:FISH_SS_FILENAME ofType:@"plist"]];
    }
    return [Common ssrect_from_dict:fish_ss_plist_dict tar:tar];
}

-(void)dealloc {
    [fishes removeAllObjects];
    [fishes release]; //GO FISHIES GO HOME
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end