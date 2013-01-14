
#import "BGLayer.h"
#import "GameEngineLayer.h"


@implementation BGLayer


+(BGLayer*)init_with_gamelayer:(GameEngineLayer*)g {
    BGLayer *l = [BGLayer node];
    [GEventDispatcher add_listener:l];
    [l set_gameengine:g];
    [l update];
    return l;
}

-(id) init{
	if( (self = [super init])) {
        
        all_objsets = [[NSMutableArray alloc] init];
        
		normal_bg_elements = [self load_normal_bg];
        for (BackgroundObject* i in normal_bg_elements) {
			[self addChild:i];
		}
        
        lab_bg_elements = [self load_lab_bg];
        for (BackgroundObject* i in lab_bg_elements) {
			[self addChild:i];
            [i setVisible:NO];
		}
        
        [all_objsets addObject:normal_bg_elements];
        [all_objsets addObject:lab_bg_elements];
	}
	return self;
}

-(void)set_gameengine:(GameEngineLayer*)ref {
    game_engine_layer = ref;
}

-(NSMutableArray*) load_lab_bg {
    NSMutableArray *a = [[NSMutableArray alloc] init];
    if ([GameMain GET_USE_BG]) {
        [a addObject:[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_LAB_BG] scrollspd_x:0.1 scrollspd_y:0]];
    }
    
    return a;
}


-(NSMutableArray*) load_normal_bg {
	NSMutableArray *a = [[NSMutableArray alloc] init];
    
    if ([GameMain GET_USE_BG]) {
        [a addObject:[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_SKY] scrollspd_x:0 scrollspd_y:0]];
        [a addObject:[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_3] scrollspd_x:0.025 scrollspd_y:0.02]];
        [a addObject:[CloudGenerator init_from_tex:[Resource get_tex:TEX_CLOUD] scrollspd_x:0.1 scrollspd_y:0.025 baseHeight:250]];
        [a addObject:[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_2] scrollspd_x:0.075 scrollspd_y:0.04]];
        [a addObject:[BackgroundObject backgroundFromTex:[Resource get_tex:TEX_BG_LAYER_1] scrollspd_x:0.1 scrollspd_y:0.05]];
    }
    
    return a;
}

static const float FADECTR_MAX = 10;

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_GAME_TICK) {
        [self update];
        
    } else if (e.type == GEventType_ENTER_LABAREA) {
        visible_set = lab_bg_elements;
        [self set_visible_objset:visible_set tar:YES];
        [self set_opacity_objset:visible_set tar:255];
        fadectr = FADECTR_MAX;
        
    } else if (e.type == GEventType_EXIT_TO_DEFAULTAREA) {
        visible_set = normal_bg_elements;
        [self set_visible_objset:visible_set tar:YES];
        [self set_opacity_objset:visible_set tar:255];
        fadectr = FADECTR_MAX;
        
    } else if (e.type == GEventType_GAME_RESET) {
        [self set_visible_objset:lab_bg_elements tar:NO];
        visible_set = normal_bg_elements;
        [self set_visible_objset:visible_set tar:YES];
        [self set_opacity_objset:visible_set tar:255];
        fadectr = 0;
        
    }
}

#define SCROLL_LIMIT 3000.0

-(void)update {
    if (fadectr > 0) {
        fadectr--;
        if (fadectr == 0) {
            for (NSMutableArray* a in all_objsets) {
                if (a != visible_set) {
                    [self set_visible_objset:a tar:NO];
                }
            }
            
        } else {
            for (NSMutableArray* a in all_objsets) {
                if (a != visible_set) {
                    [self set_opacity_objset:a tar:(fadectr/FADECTR_MAX)*255];
                } else {
                    [self set_opacity_objset:a tar:255 - (fadectr/FADECTR_MAX)*100];
                }
                
            }
            
            
        }
    }
    
    float posx = game_engine_layer.player.position.x;
    float posy = game_engine_layer.player.position.y;
    
    float dx = posx - lastx;
    float dy = posy - lasty;
    
    curx += dx;
    cury = MAX(0,MIN(SCROLL_LIMIT,cury+dy));
    
    lastx = posx;
    lasty = posy;
    
	[self update_objset:normal_bg_elements];
    [self update_objset:lab_bg_elements];
    
}

-(void)update_objset:(NSMutableArray*)a {
	for (BackgroundObject* s in a) {
        [s update_posx:curx posy:cury];
	}
}

-(void)set_visible_objset:(NSMutableArray*)a tar:(BOOL)t {
	for (BackgroundObject* s in a) {
        [s setVisible:t];
	}
}

-(void)set_opacity_objset:(NSMutableArray*)a tar:(int)t {
    for (BackgroundObject* s in a) {
        [s setOpacity:t];
    }
}



-(void)dealloc {
    [all_objsets removeAllObjects];
    [all_objsets release];
    [self removeAllChildrenWithCleanup:YES];
    [normal_bg_elements removeAllObjects];
    [normal_bg_elements release];
    [lab_bg_elements removeAllObjects];
    [lab_bg_elements release];
    [super dealloc];
}

@end


/*ct--; //TODO -- day/night effect
 if (ct > 0) {
 [bgsky setColor:ccc3(ct,MAX(ct,20),MAX(ct,50))];
 [bghills setColor:ccc3(MAX(70,ct),MAX(ct,70),MAX(ct,70))];
 [bgclouds setColor:ccc3(MAX(150,ct),MAX(ct,150),MAX(ct,200))];
 [bgtrees setColor:ccc3(MAX(110,ct),MAX(ct,110),MAX(ct,110))];
 [bgclosehills setColor:ccc3(MAX(150,ct),MAX(ct,150),MAX(ct,150))];
 [game_engine_layer setColor:ccc3(MAX(200,ct),MAX(200,ct),MAX(200,ct))];
 }*/