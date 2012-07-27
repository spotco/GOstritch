
#import "BGLayer.h"
#import "GameEngineLayer.h"


@implementation BGLayer

+(BGLayer*)init_with_gamelayer:(GameEngineLayer*)g {
    BGLayer *l = [BGLayer node];
    [l set_gameengine:g];
    [l start_update];
    return l;
}

-(id) init{
	if( (self = [super init])) {
		bg_elements = [BGLayer loadBg];
		for (CCSprite* i in bg_elements) {
			[self addChild:i];
		}
	}
	return self;
}

-(void)set_gameengine:(GameEngineLayer*)ref {
    game_engine_layer = ref;
}

-(void)start_update {
    [self schedule:@selector(update)];
}


+(NSMutableArray*) loadBg {
	NSMutableArray *a = [[NSMutableArray alloc] init];
    
    [a addObject:[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_SKY] scrollspd_x:0 scrollspd_y:0]];
    [a addObject:[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_3] scrollspd_x:0.025 scrollspd_y:0.02]];
    [a addObject:[CloudGenerator init_from_tex:[Resource get_tex:TEX_CLOUD] scrollspd_x:0.1 scrollspd_y:0.025 baseHeight:250]];
    [a addObject:[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_2] scrollspd_x:0.075 scrollspd_y:0.04]];
    [a addObject:[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_1] scrollspd_x:0.1 scrollspd_y:0.05]];
    
    return a;
}

-(void)update {
    float posx = [game_engine_layer get_pos].x;
    float posy = [game_engine_layer get_pos].y;
    
	for (BackgroundObject* s in bg_elements) {
        [s update_posx:posx posy:posy];
	}
}

@end
