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
	[scene addChild:bglayer];
	GameEngineLayer *layer = [GameEngineLayer node];
	
    [scene addChild: layer];
	return scene;
}


-(id) init{
	if( (self=[super init])) {
        game_control_state = [[GameControlState alloc] init];
		player_start_pt = [self loadMap];
        player = [Player init];
        player.position = player_start_pt;
        
		[self addChild:player z:[GameRenderImplementation GET_RENDER_PLAYER_ORD]];
		player.vy = 0;
		player.vx = 0;
		[self schedule:@selector(update:)];
		self.isTouchEnabled = YES;
        
		[self.camera setCenterX:100 centerY:40 centerZ:0];
        [self.camera setEyeX:100 eyeY:40 eyeZ:50];
        
        
		[self runAction:[CCFollow actionWithTarget:(player) worldBoundary:[self get_world_bounds] ]];
	}
	return self;
}

-(CGRect) get_world_bounds {
    float max_x = 0;
    float max_y = 0;
    for (Island* i in islands) {
        max_x = MAX(max_x, i.endX);
        max_y = MAX(max_y, i.endY);
    }
    return CGRectMake(-100, -100, max_x+600, max_y+600);
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
	float pos_x = player.position.x;
	float pos_y = player.position.y;
	
    [game_control_state update];
    [GamePhysicsImplementation player_move:player with_islands:islands];
    //[GameControlImplementation control_update_player:player islands:islands objects:game_objects];
    
    [self check_game_state];	
    [self update_static_x:pos_x y:pos_y];
    [self update_game_obj];
    [GameRenderImplementation update_render_on:self player:player islands:islands objects:game_objects];
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


//-(void) ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {}

-(void)check_game_state {
    if (!CGRectIntersectsRect([self get_world_bounds],[player get_hit_rect])) { 
        player.position = player_start_pt;
        player.vx = 0;
        player.vy = 0;
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

/*-(void)draw {
     [super draw];
     glColor4ub(255,0,0,100);
     glLineWidth(2.0f);
     CGRect pathBox = [player get_hit_rect];
     CGPoint verts[4] = {
         ccp(pathBox.origin.x, pathBox.origin.y),
         ccp(pathBox.origin.x + pathBox.size.width, pathBox.origin.y),
         ccp(pathBox.origin.x + pathBox.size.width, pathBox.origin.y + pathBox.size.height),
         ccp(pathBox.origin.x, pathBox.origin.y + pathBox.size.height)
     };
     ccDrawPoly(verts, 4, YES);
     
     for (GameObject* o in game_objects) {
     CGRect pathBox = [o get_hit_rect];
     CGPoint verts[4] = {
         ccp(pathBox.origin.x, pathBox.origin.y),
         ccp(pathBox.origin.x + pathBox.size.width, pathBox.origin.y),
         ccp(pathBox.origin.x + pathBox.size.width, pathBox.origin.y + pathBox.size.height),
         ccp(pathBox.origin.x, pathBox.origin.y + pathBox.size.height)
     };
     ccDrawPoly(verts, 4, YES);
     }
 }*/


@end
