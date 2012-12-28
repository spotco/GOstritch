#import "GameEngineLayer.h"
#import "BGLayer.h"
#import "UILayer.h"
#import "BridgeIsland.h"
#import "FlashEffect.h"

/*
//TRMV
@interface BatchDrawer : CCSprite
@end
@implementation BatchDrawer
-(void)draw {
    [super draw];
    [LineIsland batch_draw];
}
@end
*/
 
@implementation GameEngineLayer

@synthesize current_mode;
@synthesize game_objects,islands;
@synthesize player;
@synthesize camera_state,tar_camera_state;
@synthesize follow_action;

/* static initializers */

+(CCScene *) scene_with:(NSString *)map_file_name lives:(int)lives {
    CCScene *scene = [CCScene node];
    GameEngineLayer *glayer = [GameEngineLayer layer_from_file:map_file_name lives:lives];
	BGLayer *bglayer = [BGLayer init_with_gamelayer:glayer];
    UILayer* uilayer = [UILayer init_with_gamelayer:glayer];
    
    [scene addChild:bglayer];
    [scene addChild:glayer];
    [scene addChild:uilayer];
    
    [uilayer start_initial_anim];
	return scene;
}
+(CCScene*) scene_with_autolevel_lives:(int)lives {
    CCScene* scene = [GameEngineLayer scene_with:@"connector" lives:lives];
    GameEngineLayer* glayer = [scene.children objectAtIndex:1];
    GameObject* nobj = [AutoLevel init_with_glayer:glayer];
    [glayer.game_objects addObject:nobj];
    [glayer addChild:nobj];
    [glayer stopAction:glayer.follow_action];
    glayer.follow_action = [[CCFollow actionWithTarget:glayer.player] retain];
    [glayer runAction:glayer.follow_action];
    
	return scene;
}

+(GameEngineLayer*)layer_from_file:(NSString*)file lives:(int)lives {
    GameEngineLayer *g = [GameEngineLayer node];
    [g cons:file lives:lives];
    return g;
}

-(void)cons:(NSString*)map_filename lives:(int)starting_lives {
    if (particles_tba == NULL) {
        particles_tba = [[NSMutableArray alloc] init];
    }
    
    /*
    //TRMV
    batch_drawer = [BatchDrawer node];
    */
    [BatchDraw cons];
    batch_draw = [BatchDraw node];
    [self addChild:batch_draw];
    
    [GameControlImplementation reset_control_state];
    [GEventDispatcher add_listener:self];
    refresh_viewbox_cache = YES;
    CGPoint player_start_pt = [self loadMap:map_filename];
    
    [self init_bones];
    particles = [[NSMutableArray array] retain];
    player = [Player init_at:player_start_pt];
    
    [self addChild:player z:[GameRenderImplementation GET_RENDER_PLAYER_ORD]];
    self.isTouchEnabled = YES;
    
    current_mode = GameEngineLayerMode_GAMEPLAY;
    
    [self reset_camera];
    
    lives = starting_lives;
    
    follow_action = [CCFollow actionWithTarget:player worldBoundary:[Common hitrect_to_cgrect:[self get_world_bounds]]];
    [self runAction:follow_action];
    
    for (Island *i in islands) {
        [i update:self];
    }
    for (GameObject *o in game_objects) {
        [o check_should_render:self];
    }
    
    if ([GameMain GET_USE_NSTIMER]) {
        updater = [NSTimer scheduledTimerWithTimeInterval:[GameMain GET_TARGET_FPS] target:self selector:@selector(update) userInfo:nil repeats:YES];
    } else {
        [self schedule:@selector(update)];
    }
    self.isAccelerometerEnabled = YES;
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1/60];
}

-(CGPoint)loadMap:(NSString*)filename {
	GameMap map = [MapLoader load_map:filename];
    
    islands = map.n_islands;
    int ct = [Island link_islands:islands];
    if (ct != map.assert_links) {
        NSLog(@"ERROR: expected %i links, got %i.",map.assert_links,ct);
    }
    
    for (Island* i in islands) {
        [self addChild:i z:[i get_render_ord]];
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
    for (int i = 0; i < game_objects.count; i++) {
        GameObject *o = [game_objects objectAtIndex:i];
        [o reset];
    }
    [player reset];
    [self reset_camera];
    [GameControlImplementation reset_control_state];
    current_mode = GameEngineLayerMode_GAMEPLAY;
    
    for(NSNumber* bid in [bones allKeys]) {
        int status = ((NSNumber*)[bones objectForKey:bid]).intValue;
        if (status == Bone_Status_HASGET) {
            [bones setObject:[NSNumber numberWithInt:Bone_Status_TOGET] forKey:bid];
        }
    }
    refresh_bone_cache = YES;
}

-(void)check_falloff {
    if (![Common hitrect_touch:[self get_world_bounds] b:[player get_hit_rect]]) {
        [GEventDispatcher push_unique_event:[GEvent init_type:GEventType_PLAYER_DIE]];
	}
}

-(void)update {
    [GEventDispatcher dispatch_events];
    if (current_mode == GameEngineLayerMode_GAMEPLAY) {
        
        
        time++;
        refresh_viewbox_cache = YES;
        [GamePhysicsImplementation player_move:player with_islands:islands];
        [GameControlImplementation control_update_player:self];
        [player update:self];
        [self check_falloff];	
        [self update_game_obj];
        [self update_particles];
        [self push_added_particles];
        
        
        /*
        //TRMV
        [LineIsland batch_clear]
        */
         
        [BatchDraw clear];
        [self update_islands];
        
        [GameRenderImplementation update_render_on:self];
        [GEventDispatcher push_event:[GEvent init_type:GEventType_GAME_TICK]];
        
    } else if (current_mode == GameEngineLayerMode_UIANIM) {
        [GEventDispatcher push_event:[GEvent init_type:GEventType_UIANIM_TICK]];
        
    }
    [GEventDispatcher dispatch_events];
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_QUIT) {
        [self exit];
        [GameMain start_menu];
        
    } else if (e.type == GEventType_PLAYAGAIN_AUTOLEVEL) {
        [self exit];
        [GameMain start_game_autolevel];
        
    } else if (e.type == GEventType_CHECKPOINT) {
        [self set_checkpoint_to:e.pt];
        
    } else if (e.type == GEventType_LEVELEND) {
        [GEventDispatcher push_event:[GEvent init_type:GEventType_LOAD_LEVELEND_MENU]]; //[self stopAction:follow_action];
        
    } else if (e.type == GEventType_PAUSE) {
        current_mode = GameEngineLayerMode_PAUSED;
        
    } else if (e.type == GEventType_UNPAUSE) {
        current_mode = GameEngineLayerMode_GAMEPLAY;
        
    } else if (e.type == GEventType_PLAYER_DIE) {
        lives = lives == GAMEENGINE_INF_LIVES ? lives : lives-1;
        if (lives != GAMEENGINE_INF_LIVES && lives < 0) {
            [self game_over];
        } else {
            [self player_reset];
            [player add_effect:[FlashEffect init_from:[player get_current_params] time:35]];
        }
        
    }
}

-(void)set_records {
    level_bone_status b = [self get_bonestatus];
    int tb = b.hasgets+b.savedgets;
    [DataStore set_key:STO_totalbones_INT int_value:[DataStore get_int_for_key:STO_totalbones_INT]+tb];
    [DataStore set_key:STO_maxbones_INT int_value:MAX([DataStore get_int_for_key:STO_maxbones_INT],tb)];
}

/* event dispatch handlers */

-(void)game_over {
    current_mode = GameEngineLayerMode_GAMEOVER;
    [GEventDispatcher push_event:[GEvent init_type:GEventType_GAMEOVER]];
}
-(void)exit {
    if ([GameMain GET_USE_NSTIMER]) {
        [updater invalidate];
    } else {
        [self unscheduleAllSelectors];
    }
    [self set_records];
    [GEventDispatcher remove_all_listeners];
    [[CCDirector sharedDirector] resume];
}

/* camera interface */

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

/* bone system */

-(void)init_bones {
    bones = [[[NSMutableDictionary alloc]init]retain]; //bid -> status
    for (GameObject *i in game_objects) {
        if ([i class] == [DogBone class]) {
            [self add_bone:(DogBone*)i autoassign:NO];
        }
    }//NSLog(@"Bones loaded (%i bones total)",[bones count]);
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
            [bones setObject:[NSNumber numberWithInt:Bone_Status_HASGET] forKey:bid]; //NSLog(@"getbid:%i",tbid);
            [GEventDispatcher push_event:[GEvent init_type:GEventType_COLLECT_BONE]];
            refresh_bone_cache = YES;
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

/* helpers */
-(void)addChild:(CCNode *)node z:(NSInteger)z {
    refresh_worldbounds_cache = YES;
    [super addChild:node z:z];
}
-(void)update_islands {
    for (Island* i in islands) {
        [i update:self];
    }
}
-(void)update_game_obj {
    for(int i = 0; i < [game_objects count]; i++) {
        GameObject *o = [game_objects objectAtIndex:i];
        [o update:player g:self];
    }
}
-(level_bone_status)get_bonestatus {
    if (refresh_bone_cache == YES) {
        refresh_bone_cache = NO;
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
        cached_status = n;
    }
    return cached_status;
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

/* getters */

-(HitRect) get_world_bounds {
    if (refresh_worldbounds_cache) {
        refresh_worldbounds_cache = NO;
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
        cached_worldsbounds = r;
    }
    return cached_worldsbounds;
}
-(HitRect)get_viewbox {
    if (refresh_viewbox_cache) {
        refresh_viewbox_cache = NO;
        //TODO -- make this scale with camera zoom
        cached_viewbox = [Common hitrect_cons_x1:-self.position.x-[Common SCREEN].width*0
                                              y1:-self.position.y-[Common SCREEN].height*0
                                             wid:[Common SCREEN].width*2
                                             hei:[Common SCREEN].height*2];
    }
    return cached_viewbox;
}
-(int)get_lives { return lives; }
-(int)get_time { return time; }


/* particle system */

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
-(void) ccTouchesMoved:(NSSet *)pTouches withEvent:(UIEvent *)event {
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

-(void)dealloc {
    NSLog(@"gameengine dealloc");
    [BatchDraw clear];
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


@end
