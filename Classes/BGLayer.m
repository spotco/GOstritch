
#import "BGLayer.h"
#import "GameEngineLayer.h"


@implementation BGLayer


+(BGLayer*)init_with_gamelayer:(GameEngineLayer*)g {
    BGLayer *l = [BGLayer node];
    [l set_gameengine:g];
    return l;
}

-(id) init{
	if( (self = [super init])) {
		bg_elements = [self loadBg];
		for (CCSprite* i in bg_elements) {
			[self addChild:i];
		}
	}
	return self;
}

-(void)set_gameengine:(GameEngineLayer*)ref {
    game_engine_layer = ref;
}


-(NSMutableArray*) loadBg {
	NSMutableArray *a = [[NSMutableArray alloc] init];
    
    if ([GameMain GET_USE_BG]) {
        bgsky = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_SKY] scrollspd_x:0 scrollspd_y:0];
        bghills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_3] scrollspd_x:0.025 scrollspd_y:0.02];
        bgclouds = [CloudGenerator init_from_tex:[Resource get_tex:TEX_CLOUD] scrollspd_x:0.1 scrollspd_y:0.025 baseHeight:250];
        bgtrees = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_2] scrollspd_x:0.075 scrollspd_y:0.04];
        bgclosehills = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_1] scrollspd_x:0.1 scrollspd_y:0.05];
        [a addObject:bgsky];
        [a addObject:bghills];
        [a addObject:bgclouds];
        [a addObject:bgtrees];
        [a addObject:bgclosehills];
    }
    
    return a;
}

#define SCROLL_LIMIT 3000.0

-(void)update {
    float posx = [game_engine_layer get_pos].x;
    float posy = [game_engine_layer get_pos].y;
    
    float dx = posx - lastx;
    float dy = posy - lasty;
    
    curx += dx;
    cury = MAX(0,MIN(3000,cury+dy));
    
    lastx = posx;
    lasty = posy;
    
	for (BackgroundObject* s in bg_elements) {
        [s update_posx:curx posy:cury];
	}
    
    //TODO -- day/night effect
    /*
    ct--;
    if (ct > 0) {
        [bgsky setColor:ccc3(ct,MAX(ct,20),MAX(ct,50))];
        [bghills setColor:ccc3(MAX(70,ct),MAX(ct,70),MAX(ct,70))];
        [bgclouds setColor:ccc3(MAX(150,ct),MAX(ct,150),MAX(ct,200))];
        [bgtrees setColor:ccc3(MAX(110,ct),MAX(ct,110),MAX(ct,110))];
        [bgclosehills setColor:ccc3(MAX(150,ct),MAX(ct,150),MAX(ct,150))];
        
        [game_engine_layer setColor:ccc3(MAX(200,ct),MAX(200,ct),MAX(200,ct))];
    }
     */
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:YES];
    [bg_elements removeAllObjects];
    [bg_elements release];
    [super dealloc];
}

@end
