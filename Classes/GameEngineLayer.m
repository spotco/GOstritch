#import "GameEngineLayer.h"

@implementation GameEngineLayer

static float cur_pos_x = 0;
static float cur_pos_y = 0;
static NSString *my_map_file_name;
static NSString *my_map_file_type;


+(CCScene *) scene_with:(NSString *) map_file_name of_type:(NSString *) map_file_type{
    my_map_file_name = map_file_name;
    my_map_file_type = map_file_type;
    
    [Resource init_bg1_textures];
	[[CCDirector sharedDirector] setDisplayFPS:NO];
	CCScene *scene = [CCScene node];
	BGLayer *bglayer = [BGLayer node];
	//[scene addChild:bglayer];
	GameEngineLayer *layer = [GameEngineLayer node];
	
    [scene addChild: layer];
	return scene;
}


-(id) init{
	if( (self=[super init])) {
        game_control_state = [[GameControlState alloc] init];
        game_render_state = [[GameRenderState alloc] init];
        
		CGPoint player_start_pt = [self loadMap];
        player = [Player init_at:player_start_pt];
        
		[self addChild:player z:[GameRenderImplementation GET_RENDER_PLAYER_ORD]];
		[self schedule:@selector(update:)];
		self.isTouchEnabled = YES;
        
        
        [GameRenderImplementation update_camera_on:self state:game_render_state];
        
        
		[self runAction:[CCFollow actionWithTarget:(player) worldBoundary:[Common hitrect_to_cgrect:[self get_world_bounds]]]];
	}
	return self;
}

-(HitRect) get_world_bounds {
    float max_x = 0;
    float max_y = 0;
    for (Island* i in islands) {
        max_x = MAX(max_x, i.endX);
        max_y = MAX(max_y, i.endY);
    }
    return [Common hitrect_cons_x1:-100 y1:-100 wid:max_x+600 hei:max_y+600];
}


-(CGPoint) loadMap{
	Map *map = [MapLoader load_map:my_map_file_name oftype: my_map_file_type];
    
    islands = map.n_islands;
    int ct = [Island link_islands:islands];
    if (ct == map.assert_links) {
        NSLog(@"Successfully linked islands, %i links.",ct);
    } else {
        NSLog(@"ERROR: expected %i links, got %i.",map.assert_links,ct);
    }
    
    for (Island* i in islands) {
        if (i.can_land) {
            [self addChild:i z:[GameRenderImplementation GET_RENDER_ISLAND_ORD]];
        } else {
            [self addChild:i z:[GameRenderImplementation GET_RENDER_FG_ISLAND_ORD]];
        }
	}
    
    game_objects = map.game_objects;
    for (GameObject* o in game_objects) {
        [self addChild:o z:[GameRenderImplementation GET_RENDER_GAMEOBJ_ORD]];
    }
    
    return map.player_start_pt;
}

-(void)update:(ccTime)dt {	
    [GamePhysicsImplementation player_move:player with_islands:islands];
    [GameControlImplementation control_update_player:player state:game_control_state islands:islands objects:game_objects];
    [player update];
    
    [self check_game_state];	
    [self update_static_x:player.position.x y:player.position.y];
    [self update_game_obj];
    [GameRenderImplementation update_render_on:self player:player islands:islands objects:game_objects state:game_render_state];
}

-(void)update_game_obj {
    for (GameObject* o in game_objects) {
        [o update:player];
    }
}

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [t locationInView:[t view]];
    }
    [GameControlImplementation touch_begin:game_control_state at:touch];
}

-(void) ccTouchesEnded:(NSSet*)pTouches withEvent:(UIEvent*)event {
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [t locationInView:[t view]];
    }
    [GameControlImplementation touch_end:game_control_state at:touch];
}

-(void)check_game_state {
    if (![Common hitrect_touch:[self get_world_bounds] b:[player get_hit_rect]]) {
        [player reset];
        
        [game_render_state dealloc];
        game_render_state = [[GameRenderState alloc] init];
        [GameRenderImplementation update_camera_on:self state:game_render_state];
        for (GameObject* o in game_objects) {
            [o set_active:YES];
        }
	}
}

-(void)update_static_x:(float)pos_x y:(float)pos_y {
    cur_pos_x = pos_x;
	cur_pos_y = pos_y;
}

+(float) get_cur_pos_x {
	return cur_pos_x;
}

+(float) get_cur_pos_y {
	return cur_pos_y;
}

- (void) dealloc{
    for (Island* i in islands) {
        [i dealloc];
    }
    islands = nil;
    [player dealloc];
	[Resource dealloc_textures];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
	[super dealloc];
}

-(void)draw {
    [super draw];
    glColor4ub(255,0,0,100);
    glLineWidth(2.0f);
    HitRect re = [player get_hit_rect]; 
    CGPoint *verts = [Common hitrect_get_pts:re];
    ccDrawPoly(verts, 4, YES);
    free(verts);
     
     /*for (GameObject* o in game_objects) {
         CGRect pathBox = [o get_hit_rect];
         CGPoint verts[4] = {
             ccp(pathBox.origin.x, pathBox.origin.y),
             ccp(pathBox.origin.x + pathBox.size.width, pathBox.origin.y),
             ccp(pathBox.origin.x + pathBox.size.width, pathBox.origin.y + pathBox.size.height),
             ccp(pathBox.origin.x, pathBox.origin.y + pathBox.size.height)
         };
         ccDrawPoly(verts, 4, YES);
     }*/
 }


@end
