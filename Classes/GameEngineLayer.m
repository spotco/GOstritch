#import "GameEngineLayer.h"

#define PLAYER_START_X 50
#define PLAYER_START_Y 50

@implementation GameEngineLayer

static float cur_pos_x = 0;
static float cur_pos_y = 0;

/**
 TODO:
    -Fix curve fallthrough bug
    -Fix island join bug
    -Fix curve island offset bug (when not starting at 0 or PI*n
    -Refactor player move code
    -Fix line island top part-alignment rendering problem
    -Running vertically/upsidedown
 **/

+(CCScene *) scene{
    [Resource init_textures];
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
		//[self loadMap];
        [self load_test_map];
        player = [Player init];
		[self addChild:player];
		player.position = ccp(PLAYER_START_X,PLAYER_START_Y);
		player.vy = 0;
		player.vx = 1;
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

-(void) load_test_map {
    islands = [[NSMutableArray alloc] init];
    game_objects = [[NSMutableArray alloc] init];
    [islands addObject:[CurveIsland init_pt_i:ccp(50,0) pt_f:ccp(500,200) theta_i:0 theta_f:M_PI*(0.5)]];
    [islands addObject:[CurveIsland init_pt_i:ccp(500,200) pt_f:ccp(1000,400) theta_i:0 theta_f:M_PI*(0.5)]];
    [islands addObject:[CurveIsland init_pt_i:ccp(1000,400) pt_f:ccp(1500,690) theta_i:0 theta_f:M_PI*(0.5)]];
    [islands addObject:[LineIsland init_pt1:ccp(0,0) pt2:ccp(1700,200)]];
    for (Island* i in islands) {
		[self addChild:i];
	}
}

/*load the map and items in the map
 */
-(void) loadMap{
	Map *map = [MapLoader load_map:@"island1" oftype:@"map"];
    
    islands = map.n_islands;
    for (Island* i in islands) {
		[self addChild:i];
	}
    
    game_objects = map.game_objects;
    for (GameObject* o in game_objects) {
        [self addChild:o];
    }
}

-(void)update:(ccTime)dt {
	float pos_x = player.position.x;
	float pos_y = player.position.y;
	
    [self check_sort_islands_given:pos_x and:pos_y];
	CGPoint pos_f = [self player_move_x:pos_x y:pos_y];
	player.position=pos_f;
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
    if (!CGRectIntersectsRect([self get_world_bounds],[player get_hit_rect])) { 
		player.position = ccp(PLAYER_START_X,PLAYER_START_Y);
        player.touch_count = 0;
        player.vx = 0;
        player.vy = 0;
        for (GameObject* o in game_objects) {
            o.active = YES;
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

//calculates and returns position of player in next update "step"
-(CGPoint)player_move_x:(float)pos_x y:(float) pos_y {
    float pre_y = pos_y;//ydir movement check, get y(pre +vy) and y(post +vy)
	float post_y = pos_y+player.vy;
	BOOL is_contact = NO;
	Island *contact_island;
	
	for (Island* i in islands) {//if island height at pos_x overlaps ypre->ypost, CONTACT and select island
		float h = [i get_height:pos_x];
		if (h != -1 && h <= pre_y && h >= post_y) {
			is_contact = YES;
			post_y = h;
			contact_island = i;
			break;
		}
	}
	if (is_contact) { //if found contact through ydir-search
		float rise_one = [contact_island get_height:(pos_x+1)] - [contact_island get_height:pos_x];
		float dx = player.vx*cos(atan(rise_one));
		float mov_h = [contact_island get_height:(pos_x+dx)]; //calculate slide movement on slope
		if (mov_h != -1 && [contact_island get_height:(pos_x+player.vx)] != -1) { //if on slope and enough forward room, apply movement up slope
			pos_x = pos_x + dx;
			pos_y = mov_h;
		} else { //else if at edge
			pos_x = pos_x + player.vx;
			pos_y=post_y;
		}
		//float ang = atan((contact_island.endY-contact_island.startY)/(contact_island.endX-contact_island.startX))*(180/M_PI);
		float ang = [contact_island get_angle:pos_x];
        player.rotation = -ang; //rotate 
		player.vy = 0;
	} else {
		pos_y+=player.vy; //move before incrementing velocity OR ELSE
		player.vy-=0.5;
		
		player.rotation = player.rotation*0.9;//not touching anything, center rotation animation
		
		float pre_x = pos_x;//move xdir by vx, check pre and post
		float post_x = pos_x+player.vx;
		BOOL has_hit_x = NO;
		for (Island* i in islands) { //use 2-line segment intersection to see if any x-dir conflicts
			//CGPoint intersection = [Common line_seg_intersection_a1:ccp(pre_x,pos_y) a2:ccp(post_x,pos_y) b1:ccp(i.startX,i.startY) b2:ccp(i.endX,i.endY)];
            CGPoint intersection = [Common line_seg_intersection_a1:ccp(pre_x,pos_y) a2:ccp(post_x,pos_y) b1:ccp(pre_x, [i get_height:pre_x]) b2:ccp(post_x,[i get_height:post_x])];
			if (intersection.x != -1 && intersection.y != -1) {//if conflict, set position at conflict_x,contact_island_height(x)
				pos_x = intersection.x; 
				pos_y = [i get_height:intersection.x];
				has_hit_x = YES;
				break;
			}
		}
		
		if (!has_hit_x) {//else if no conflict, full vx move
			pos_x = post_x;
		}
    }
    [self player_control_update:is_contact];
    return ccp(pos_x,pos_y);
}

+(NSMutableArray*) loadGameObjects {
    NSMutableArray *gameObjArray = [[NSMutableArray alloc] init];
    [gameObjArray addObject:[Coin init_x:368 y:150]];
    [gameObjArray addObject:[Coin init_x:800 y:200]];
    return gameObjArray;
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


@end
