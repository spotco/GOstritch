#import "GameEngineLayer.h"
#import "BGLayer.h"

@implementation GameEngineLayer

@synthesize paused;
@synthesize game_objects,islands;

+(CCScene *) scene_with:(NSString *) map_file_name {
    [Resource init_bg1_textures];
	[[CCDirector sharedDirector] setDisplayFPS:NO];
	CCScene *scene = [CCScene node];
    
    GameEngineLayer *layer = [GameEngineLayer init_from_file:map_file_name];
	BGLayer *bglayer = [BGLayer init_with_gamelayer:layer];
    UILayer* uilayer = [UILayer init_with_gamelayer:layer];
    
    //[scene addChild:bglayer];
    [scene addChild: layer];
    [scene addChild:uilayer];

    
	return scene;
}

+(GameEngineLayer*)init_from_file:(NSString*)file {
    GameEngineLayer *g = [GameEngineLayer node];
    [g initialize:file];
    return g;
}


-(void)initialize:(NSString*)map_filename {
    game_control_state = [[GameControlState alloc] init];
    game_render_state = [[GameRenderState alloc] init];
    
    CGPoint player_start_pt = [self loadMap:map_filename];
    map_start_pt = player_start_pt;
    player = [Player init_at:player_start_pt];
    
    [self addChild:player z:[GameRenderImplementation GET_RENDER_PLAYER_ORD]];
    [self schedule:@selector(update)];
    
    self.isTouchEnabled = YES;
    
    current_mode = GameEngineLayerMode_GAMEPLAY;
    
    [GameRenderImplementation update_camera_on:self state:game_render_state];
    
    follow_action = [CCFollow actionWithTarget:(player) worldBoundary:[Common hitrect_to_cgrect:[self get_world_bounds]]];
    [self runAction:follow_action];
}

-(HitRect) get_world_bounds {
    float max_x = 0;
    float max_y = 0;
    for (Island* i in islands) {
        max_x = MAX(max_x, i.endX);
        max_y = MAX(max_y, i.endY);
    }
    return [Common hitrect_cons_x1:-100 y1:0 wid:max_x+600 hei:max_y+600];
}


-(CGPoint) loadMap:(NSString*)filename {
	GameMap map = [MapLoader load_map:filename oftype:@"map"];
    
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
        [self addChild:o z:[o get_render_ord]];
    }
    
    return map.player_start_pt;
}

-(void)update {
    if (paused) {
        //[self update_game_obj];
        return;
    }
    
    if (current_mode == GameEngineLayerMode_GAMEPLAY) {
        [GamePhysicsImplementation player_move:player with_islands:islands];
        [GameControlImplementation control_update_player:player state:game_control_state islands:islands objects:game_objects];
        [player update:self];
         
        
        [self check_game_state];	
        [self update_game_obj];
        [GameRenderImplementation update_render_on:self player:player islands:islands objects:game_objects state:game_render_state];
        
    } else if (current_mode == GameEngineLayerMode_ENDOUT) {
        if ([Common hitrect_touch:[player get_hit_rect] b:[self get_viewbox]]) {
            [GamePhysicsImplementation player_move:player with_islands:islands];
            [player update:self];  
        } else {
            [self end_game];
            exit(0);
        }

    }
    
}

-(HitRect)get_viewbox {
    return [Common hitrect_cons_x1:-self.position.x-[CCDirector sharedDirector].winSize.width/2
                                y1:-self.position.y-[CCDirector sharedDirector].winSize.height/2
                               wid:[CCDirector sharedDirector].winSize.width*2.5
                               hei:[CCDirector sharedDirector].winSize.height*2.5];
}

-(void)update_game_obj {
    for (GameObject* o in game_objects) {
        GameObjectReturnCode c = [o update:player g:self];
        
        if (c == GameObjectReturnCode_ENDGAME) {
            current_mode = GameEngineLayerMode_ENDOUT;
            [self stopAction:follow_action];
        }
    }
}

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {
    if (paused) {
        return;
    }
    
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [t locationInView:[t view]];
    }
    [GameControlImplementation touch_begin:game_control_state at:touch];
}

-(void) ccTouchesEnded:(NSSet*)pTouches withEvent:(UIEvent*)event {
    if (paused) {
        return;
    }
    
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [t locationInView:[t view]];
    }
    [GameControlImplementation touch_end:game_control_state at:touch];
}

-(void)check_game_state {
    if (![Common hitrect_touch:[self get_world_bounds] b:[player get_hit_rect]]) {
        [self player_reset];
	}
}

-(void)player_reset {
    [player reset];
    [game_render_state dealloc];
    game_render_state = [[GameRenderState alloc] init];
    [GameRenderImplementation update_camera_on:self state:game_render_state];
    for (GameObject* o in game_objects) {
        [o set_active:YES];
    }
}

-(CGPoint)get_pos {
    return player.position;
}

-(void) end_game { //TODO -- ACTUALLY DEALLOC SHIT
    [self removeAllChildrenWithCleanup:YES];
    [[CCDirector sharedDirector] end];
}

-(void)draw {
    [super draw];
    //return;
    
    glColor4ub(255,0,0,100);
    glLineWidth(1.0f);
    HitRect re = [player get_hit_rect]; 
    CGPoint *verts = [Common hitrect_get_pts:re];
    ccDrawPoly(verts, 4, YES);
    
    if (player.current_island == NULL) {
        CGPoint a = ccp(verts[2].x,verts[2].y);
        Vec3D *dv = [Vec3D init_x:player.vx y:player.vy z:0];
        [dv normalize];
        [dv scale:50];
        CGPoint b = ccp(a.x+dv.x,a.y+dv.y);
        [dv dealloc];
        ccDrawLine(a, b);
    }
    free(verts);
    
    for (GameObject* o in game_objects) {
        HitRect pathBox = [o get_hit_rect];
        verts = [Common hitrect_get_pts:pathBox];
        ccDrawPoly(verts, 4, YES);
        free(verts);
    }
    
    HitRect viewbox = [self get_viewbox];
    verts = [Common hitrect_get_pts:viewbox];
    ccDrawPoly(verts, 4, YES);
    free(verts);
 }


@end
