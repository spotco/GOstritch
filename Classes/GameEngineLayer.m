#import "GameEngineLayer.h"

#define RENDER_PLAYER_ORD 2
#define RENDER_ISLAND_ORD 1
#define RENDER_GAMEOBJ_ORD 0

@implementation GameEngineLayer

static float cur_pos_x = 0;
static float cur_pos_y = 0;
static NSString *my_map_file_name;
static NSString *my_map_file_type;

/**
 TODO:
    -Fix curve island offset bug (when not starting at 0 or PI*n)
    -Additonal curve island based on circle
    -Jump normal to current island direction
    -Running vertically/upsidedown
    -Curve island rendering
    -Ghost (stack loading, curl)
    -Vertical line join fallthrough bug
 **/

<<<<<<< HEAD
+(CCScene *) scene_with:(NSString *) map_file_name of_type:(NSString *) map_file_type{
    my_map_file_name = map_file_name;
    my_map_file_type = map_file_type;
    [Resource init_textures];
	[[CCDirector sharedDirector] setDisplayFPS:NO];
=======
+(CCScene *) scene{
	[Resource init_bg1_textures];
    [[CCDirector sharedDirector] setDisplayFPS:NO];
>>>>>>> 1ddcec1d4e7a3960a02b18a468027bbcbfc4a8a6
	CCScene *scene = [CCScene node];
	BGLayer *bglayer = [BGLayer node];
	[scene addChild:bglayer];
	GameEngineLayer *layer = [GameEngineLayer node];

	
    [scene addChild: layer];
	return scene;
}


-(id) init{
	if( (self=[super init])) {
		player_start_pt = [self loadMap];
        player = [Player init];
        player.position = player_start_pt;
        
		[self addChild:player z:RENDER_PLAYER_ORD];
		player.vy = 0;
		player.vx = 0;
		[self schedule:@selector(update:)];
		self.isTouchEnabled = YES;
        
		[self.camera setCenterX:150 centerY:40 centerZ:0];
        [self.camera setEyeX:150 eyeY:40 eyeZ:20];
        
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

<<<<<<< HEAD
-(void) loadMap{
	Map *map = [MapLoader load_map:my_map_file_name oftype: my_map_file_type];
=======
-(CGPoint) loadMap{
	Map *map = [MapLoader load_map:@"island2" oftype:@"map"];
>>>>>>> 1ddcec1d4e7a3960a02b18a468027bbcbfc4a8a6
    
    islands = map.n_islands;
    for (Island* i in islands) {
		[self addChild:i z:1];
	}
    
    game_objects = map.game_objects;
    for (GameObject* o in game_objects) {
        [self addChild:o z:0];
    }
    
    return map.player_start_pt;
}

-(void)update:(ccTime)dt {
	float pos_x = player.position.x;
	float pos_y = player.position.y;
	
    [self check_sort_islands_given:pos_x and:pos_y];
    [self player_control_update:[Player  player_move:player with_islands:islands]];
    
    [self check_game_state];	
    [self update_static_x:pos_x y:pos_y];
    [self update_game_obj];
    
}

-(void)update_game_obj {
    for (GameObject* o in game_objects) {
        [o update:player];
    }
}

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {
	is_touch = YES;
    player.touch_count = 5;
}

-(void) ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
}

-(void) ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	is_touch = NO;
}

-(void)check_game_state {
    //if (!CGRectIntersectsRect([self get_world_bounds],[player get_hit_rect])) { 
	if (player.position.y < 0) {
        player.position = player_start_pt;
        player.touch_count = 0;
        player.vx = 0;
        player.vy = 0;
        for (GameObject* o in game_objects) {
            [o set_active:YES];
        }
	}
}

-(void)player_control_update:(BOOL)is_contact {
    if (player.vx < 3) {
        player.vx += 0.1;
    }
    if (is_contact) {
        player.airjump_count = MAX(player.airjump_count,1);
    }
    
    if (is_touch) {
        player.touch_count+=0.5;
        player.vx = MAX(player.vx*0.99,4);
    } else if (player.touch_count != 0) {
        if (is_contact) {
            player.vy = MIN(player.touch_count,15);
        } else if (player.airjump_count > 0) {
            player.airjump_count--;
            player.vy = MIN(player.touch_count,15);
        }
        player.touch_count = 0;
    }
    
    if (!is_touch) {
        player.vx = MIN(player.vx*1.01,8);
    }
}

-(void)check_sort_islands_given:(float)pos_x and:(float)pos_y {
	float tmp = FLT_MAX;//if islands out of order, sort
	for (Island* i in islands) {
		float h = [i get_height:pos_x];
		if (h > tmp) {
			[self sort_islands];
			break;
		}
		tmp = h;
	}
}

-(void)sort_islands {
	[islands sortUsingComparator:^(id a, id b) {
		float first = [a get_height:player.position.x];
		float second = [b get_height:player.position.x];
		if (first < second) {
			return NSOrderedDescending;
		} else if (first > second) {
			return NSOrderedAscending;
		} else {
			return NSOrderedSame;
		}
	}];
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
