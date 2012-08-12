#import "GameEngineLayer.h"
#import "BGLayer.h"
#import "UILayer.h"

@implementation GameEngineLayer

@synthesize current_mode;
@synthesize game_objects,islands;
@synthesize player;
@synthesize load_game_end_menu;

/**
 TODO --
 -LevelEditor fixes:
    -birdflock broken
    -faster scrolling
    -shift all to right
 -Game fixes:
    zoom up when going downhill
    add ground details to level
 **/


+(CCScene *) scene_with:(NSString *) map_file_name {
    [Resource init_bg1_textures];

	CCScene *scene = [CCScene node];
    
    GameEngineLayer *glayer = [GameEngineLayer init_from_file:map_file_name];
	BGLayer *bglayer = [BGLayer init_with_gamelayer:glayer];
    UILayer* uilayer = [UILayer init_with_gamelayer:glayer];
    [glayer set_bg_update_callback:bglayer];
    [glayer set_ui_update_callback:uilayer];
    
    
    [scene addChild:bglayer];
    [scene addChild:glayer];
    [scene addChild:uilayer];
    
    [uilayer start_initial_anim];
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
    [self init_bones];
    particles = [[NSMutableArray array] retain];
    map_start_pt = player_start_pt;
    player = [Player init_at:player_start_pt];
    
    [self addChild:player z:[GameRenderImplementation GET_RENDER_PLAYER_ORD]];
    self.isTouchEnabled = YES;
    
    current_mode = GameEngineLayerMode_GAMEPLAY;
    
    [GameRenderImplementation update_camera_on:self state:game_render_state];
    
    follow_action = [CCFollow actionWithTarget:player worldBoundary:[Common hitrect_to_cgrect:[self get_world_bounds]]];
    [self runAction:follow_action];
    
    [self schedule:@selector(update)];
}

-(void)init_bones {
    bones = [[[NSMutableDictionary alloc]init]retain]; //bid -> status
    
    for (GameObject *i in game_objects) {
        if ([i class] == [DogBone class]) {
            DogBone *c = (DogBone*)i;
            NSNumber *bid = [NSNumber numberWithInt:c.bid];
            if ([bones objectForKey:bid]) {
                NSLog(@"ERROR:duplicate (bone)id");
            } else {
                [bones setObject:[NSNumber numberWithInt:Bone_Status_TOGET] forKey:bid];
            }
        }
    }
    NSLog(@"Bones loaded (%i bones total)",[bones count]);
    
//    for(NSNumber* bid in [bones allKeys]) {
//        NSLog(@"testloop:%i",bid.intValue);
//    }
}

-(void)set_bid_tohasget:(int)tbid {
    
    for(NSNumber* bid in [bones allKeys]) {
        if (bid.intValue == tbid) {
            [bones setObject:[NSNumber numberWithInt:Bone_Status_HASGET] forKey:bid];
            return;
        }
    }
    
    NSLog(@"ERROR: bid_tohasget_set failed, tar:%i",tbid);
}

-(void)set_checkpoint_to:(CGPoint)pt {
    player.start_pt = pt;
    
    for(NSNumber* bid in [bones allKeys]) {
        int status = ((NSNumber*)[bones objectForKey:bid]).intValue;
        if (status == Bone_Status_HASGET) {
            [bones setObject:[NSNumber numberWithInt:Bone_Status_SAVEDGET] forKey:bid];
        }
    }
}

-(void)set_bg_update_callback:(NSObject*)tar {
    bg_update.target = tar;
    bg_update.selector = @selector(update);
    [Common run_callback:bg_update];
}

-(void)set_ui_update_callback:(NSObject*)tar {
    ui_update.target = tar;
    ui_update.selector = @selector(update);
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

-(void)player_reset {
    [player reset];
    [game_render_state dealloc];
    game_render_state = [[GameRenderState alloc] init];
    [GameRenderImplementation update_camera_on:self state:game_render_state];
    for (GameObject* o in game_objects) {
        [o reset];
    }
    current_mode = GameEngineLayerMode_GAMEPLAY;
    
    for(NSNumber* bid in [bones allKeys]) {
        int status = ((NSNumber*)[bones objectForKey:bid]).intValue;
        if (status == Bone_Status_HASGET) {
            [bones setObject:[NSNumber numberWithInt:Bone_Status_TOGET] forKey:bid];
        }
    }
}

-(void)update {
    //[self print_bonestatus];
    if (current_mode == GameEngineLayerMode_PAUSED) {
        return;
    } else if (current_mode == GameEngineLayerMode_GAMEPLAY || current_mode == GameEngineLayerMode_OBJECTANIM) {
        [GamePhysicsImplementation player_move:player with_islands:islands];
        [GameControlImplementation control_update_player:player state:game_control_state islands:islands objects:game_objects];
        [player update:self];
        
        [self check_game_state];	
        [self update_game_obj];
        [self update_particles];
        [GameRenderImplementation update_render_on:self player:player islands:islands objects:game_objects state:game_render_state];
        [Common run_callback:bg_update];
        [Common run_callback:ui_update];
    } else if (current_mode == GameEngineLayerMode_ENDOUT) {
                
        if ([Common hitrect_touch:[player get_hit_rect] b:[self get_viewbox]]) {
            [GamePhysicsImplementation player_move:player with_islands:islands];
            [player update:self];  
            [self update_particles];
        } else {
            [Common run_callback:load_game_end_menu];
            current_mode = GameEngineLayerMode_ENDED;
        }
    }
    
}

-(void)add_particle:(Particle*)p {
    [particles addObject:p];
    [self addChild:p z:[p get_render_ord]];
}

-(void)update_particles {
    NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in particles) {
        [i update];
        if ([i should_remove]) {
            [self removeChild:i cleanup:NO];
            [toremove addObject:i];
        }
    }
    
    [particles removeObjectsInArray:toremove];
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
    if (current_mode != GameEngineLayerMode_GAMEPLAY) {
        return;
    }
    
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [t locationInView:[t view]];
    }
    [GameControlImplementation touch_begin:game_control_state at:touch];
}

-(void) ccTouchesEnded:(NSSet*)pTouches withEvent:(UIEvent*)event {
    if (current_mode != GameEngineLayerMode_GAMEPLAY) {
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

-(CGPoint)get_pos {
    return player.position;
}

-(void)dealloc {
    [self unschedule:@selector(update)];
    [player cleanup_anims];
    [self removeAllChildrenWithCleanup:YES];
    for (Island *i in islands) {
        [i cleanup_anims];
    }
    [islands removeAllObjects];
    [game_objects removeAllObjects];
    [particles removeAllObjects];
    [bones removeAllObjects];
    
    [islands release];
    [game_objects release];
    [particles release];
    [bones release];
    
    
    [super dealloc];
}


-(level_bone_status)get_bonestatus {
    struct level_bone_status n;
    n.togets = n.savedgets = n.hasgets = n.alreadygets = 0;
    for (NSNumber* bid in bones) {
        NSNumber* status = [bones objectForKey:bid];
        if (status.intValue == Bone_Status_TOGET) {
            n.togets++;
        } else if (status.intValue == Bone_Status_SAVEDGET) {
            n.savedgets++;
        } else if (status.intValue == Bone_Status_HASGET) {
            n.hasgets++;
        } else if (status.intValue == Bone_Status_ALREADYGET) {
            n.alreadygets++;
        }
    }
    return n;
}

+(void)print_bonestatus:(level_bone_status)b {
    NSLog(@"TOGET:%i SAVEDGET:%i HASGET:%i ALREADYGET:%i",b.togets,b.savedgets,b.hasgets,b.alreadygets);
}

-(void)draw {
    [super draw];
    return;
    
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
