#import "GameEngineLayer.h"
#import "BGLayer.h"
#import "UILayer.h"
#import "BridgeIsland.h"

@implementation GameEngineLayer

@synthesize current_mode;
@synthesize game_objects,islands;
@synthesize player;
@synthesize load_game_end_menu;
@synthesize camera_state,tar_camera_state;
@synthesize follow_action;

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

+(CCScene*) scene_with_autolevel {
    CCScene* scene = [GameEngineLayer scene_with:@"connector"];
    GameEngineLayer* glayer = [scene.children objectAtIndex:1];
    
    GameObject* nobj = [AutoLevel init_with_glayer:glayer];
    [glayer.game_objects addObject:nobj];
    [glayer addChild:nobj];
    
    [glayer stopAction:glayer.follow_action];
    glayer.follow_action = [[CCFollow actionWithTarget:glayer.player] retain];
    [glayer runAction:glayer.follow_action];
    
    
	return scene;
}

+(GameEngineLayer*)init_from_file:(NSString*)file {
    GameEngineLayer *g = [GameEngineLayer node];
    [g initialize:file];
    return g;
}

-(void)initialize:(NSString*)map_filename {
    if (particles_tba == NULL) {
        particles_tba = [[NSMutableArray alloc] init];
    }
    
    CGPoint player_start_pt = [self loadMap:map_filename];
    [self update_islands];
    [self init_bones];
    particles = [[NSMutableArray array] retain];
    map_start_pt = player_start_pt;
    player = [Player init_at:player_start_pt];
    
    [self addChild:player z:[GameRenderImplementation GET_RENDER_PLAYER_ORD]];
    self.isTouchEnabled = YES;
    
    current_mode = GameEngineLayerMode_GAMEPLAY;
    
    [self reset_camera];
    
    follow_action = [CCFollow actionWithTarget:player worldBoundary:[Common hitrect_to_cgrect:[self get_world_bounds]]];
    [self runAction:follow_action];
    
    [self schedule:@selector(update)];
}

-(void)reset_camera {
    [GameRenderImplementation reset_camera:&camera_state];
    [GameRenderImplementation reset_camera:&tar_camera_state];
    [GameRenderImplementation update_camera_on:self zoom:camera_state];
}

-(void)set_target_camera:(CameraZoom)tar {
    tar_camera_state = tar;
}

-(void)set_camera:(CameraZoom)tar {
    camera_state = tar;
}

-(void)init_bones {
    bones = [[[NSMutableDictionary alloc]init]retain]; //bid -> status
    for (GameObject *i in game_objects) {
        if ([i class] == [DogBone class]) {
            [self add_bone:(DogBone*)i autoassign:NO];
        }
    }
    NSLog(@"Bones loaded (%i bones total)",[bones count]);
}

-(void)add_bone:(DogBone*)c autoassign:(BOOL)aa {
    NSNumber *bid;
    if (aa == YES) {
        
        int max = 0;
        for (NSNumber* i in bones) {
            max = MAX(i.intValue,max);
        }
        bid = [NSNumber numberWithInt:max+1];
        c.bid = max+1;
    } else {
        bid = [NSNumber numberWithInt:c.bid];
    }
    
    if ([bones objectForKey:bid]) {
        NSLog(@"ERROR:duplicate (bone)id");
    } else {
        [bones setObject:[NSNumber numberWithInt:Bone_Status_TOGET] forKey:bid];
    }
}

-(void)set_bid_tohasget:(int)tbid {
    for(NSNumber* bid in [bones allKeys]) {
        if (bid.intValue == tbid) {
            //NSLog(@"getbid:%i",tbid);
            [bones setObject:[NSNumber numberWithInt:Bone_Status_HASGET] forKey:bid];
            [Common run_callback:bone_collect_ui_animation];
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

-(void)cleanup_autolevel {
    for (int i = 0; i < [game_objects count]; i++) {
        GameObject* o = [game_objects objectAtIndex:i];
        if ([o class] == [AutoLevel class]) {
            [((AutoLevel*)o) cleanup:player.start_pt];
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
    
    bone_collect_ui_animation.target = tar;
    bone_collect_ui_animation.selector = @selector(start_bone_collect_anim);
}

-(HitRect) get_world_bounds {
    float min_x = 5000;
    float min_y = 5000;
    float max_x = -5000;
    float max_y = -5000;
    for (Island* i in islands) {
        max_x = MAX(MAX(max_x, i.endX),i.startX);
        max_y = MAX(MAX(max_y, i.endY),i.startY);
        min_x = MIN(MIN(min_x, i.endX),i.startX);
        min_y = MIN(MIN(min_y, i.endY),i.startY);
    }
    for(GameObject* o in game_objects) {
        max_x =MAX(max_x, o.position.x);
        max_y = MAX(max_y, o.position.y);
        min_x = MIN(min_x, o.position.x);
        min_y =MIN(min_y, o.position.y);
    }
    HitRect r = [Common hitrect_cons_x1:min_x y1:min_y-200 x2:max_x+1000 y2:max_y+2000];
    return r;
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
        if (i.can_land == NO) {
            [self addChild:i z:[GameRenderImplementation GET_RENDER_FG_ISLAND_ORD]];
        } else if ([i isKindOfClass:[BridgeIsland class]]) {
            [self addChild:i z:[GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND]];
        } else {
            [self addChild:i z:[GameRenderImplementation GET_RENDER_ISLAND_ORD]];
        }
	}
    
    game_objects = map.game_objects;
    for (GameObject* o in game_objects) {
        [self addChild:o z:[o get_render_ord]];
    }
    
    World1ParticleGenerator *w1 = [World1ParticleGenerator init];
    [game_objects addObject:w1];
    [self addChild:w1];
    
    return map.player_start_pt;
}

-(void)player_reset {
    [player reset];
    [self reset_camera];
    [GameControlImplementation reset_control_state];
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
    if (current_mode == GameEngineLayerMode_PAUSED) {
        return;
        
    } else if (current_mode == GameEngineLayerMode_GAMEPLAY || current_mode == GameEngineLayerMode_OBJECTANIM) {
        [GamePhysicsImplementation player_move:player with_islands:islands];
        [GameControlImplementation control_update_player:self];
        [player update:self];
        
        [self check_game_state];	
        [self update_game_obj];
        [self update_particles];
        [self push_added_particles];
        [self update_islands];
        [GameRenderImplementation update_render_on:self];
        [self cleanup_autolevel];
        [Common run_callback:bg_update];
        [Common run_callback:ui_update];
        
    } else if (current_mode == GameEngineLayerMode_ENDOUT) {
        if ([Common hitrect_touch:[player get_hit_rect] b:[self get_viewbox]]) {
            [GamePhysicsImplementation player_move:player with_islands:islands];
            [player update:self];  
            [self min_update_game_obj];
            [self update_particles];
            [self push_added_particles];
            
        } else {
            [Common run_callback:load_game_end_menu];
            current_mode = GameEngineLayerMode_ENDED;
            
        }
        
    } else {
        [self min_update_game_obj];
        [self update_particles];
        [self push_added_particles];
    }
}



-(void)update_islands {
    for (Island* i in islands) {
        [i update:self];
    }
}

static NSMutableArray* particles_tba;

-(void)add_particle:(Particle*)p {
    [particles_tba addObject:p];
    

}

-(void)push_added_particles {
    for (Particle *p in particles_tba) {
        [particles addObject:p];
        [self addChild:p z:[p get_render_ord]];
    }
    [particles_tba removeAllObjects];
}

-(void)update_particles {
    NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in particles) {
        [i update:self];
        if ([i should_remove]) {
            [self removeChild:i cleanup:NO];
            [toremove addObject:i];
        }
    }
    [particles removeObjectsInArray:toremove];
}

-(HitRect)get_viewbox {
    return [Common hitrect_cons_x1:-self.position.x-[CCDirector sharedDirector].winSize.width
                                y1:-self.position.y-[CCDirector sharedDirector].winSize.height
                               wid:[CCDirector sharedDirector].winSize.width*4
                               hei:[CCDirector sharedDirector].winSize.height*4];
}

-(void)min_update_game_obj {
    for(GameObject* i in game_objects) {
        [i min_update:player g:self];
    }
}

-(void)update_game_obj {
    for(int i = 0; i < [game_objects count]; i++) {
        GameObject *o = [game_objects objectAtIndex:i];
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
    [GameControlImplementation touch_begin:touch];
}

-(void)ccTouchesMoved:(NSSet *)pTouches withEvent:(UIEvent *)event {
    if (current_mode != GameEngineLayerMode_GAMEPLAY) {
        return;
    }
    
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [t locationInView:[t view]];
    }
    [GameControlImplementation touch_move:touch];
}



-(void) ccTouchesEnded:(NSSet*)pTouches withEvent:(UIEvent*)event {
    if (current_mode != GameEngineLayerMode_GAMEPLAY) {
        return;
    }
    
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [t locationInView:[t view]];
    }
    [GameControlImplementation touch_end:touch];
}

-(void)check_game_state {
    if (![Common hitrect_touch:[self get_world_bounds] b:[player get_hit_rect]]) {
        //NSLog(@"fall out, player:%@ worldrect:%@",NSStringFromCGPoint(player.position),NSStringFromCGRect([Common hitrect_to_cgrect:[self get_world_bounds]]));
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

-(void)setColor:(ccColor3B)color {
	for(CCSprite *sprite in islands) {
        [sprite setColor:color];
	}
    for(CCSprite *sprite in game_objects) {
        [sprite setColor:color];
    }
    [player setColor:color];
}

-(void)draw {
    [super draw];
    
    if (![GameMain GET_DRAW_HITBOX]) {
        return;
    }
    
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
