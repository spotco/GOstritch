#import "UILayer.h"
#import "Player.h"

@implementation UILayer

+(UILayer*)init_with_gamelayer:(GameEngineLayer *)g {
    UILayer* u = [UILayer node];
    [GEventDispatcher add_listener:u];
    [u set_gameengine:g];
    [u initialize];
    return u;
}


-(void)initialize {
    [self init_ingame_ui];
    [self init_pause_menu];
    [self init_game_end_menu];
    [self init_ui_ingame_animations];
    self.isTouchEnabled = YES;
}

-(void)init_ui_ingame_animations {
    ingame_ui_anims = [[NSMutableArray array] retain];
}

-(void)load_game_end_menu {
    game_end_menu_layer.isTouchEnabled = NO;
    ingame_ui.visible = NO;
    [[[CCDirector sharedDirector] runningScene] addChild:game_end_menu_layer];
}

-(void)init_game_end_menu {
    ccColor4B c = {0,0,0,200};
    CGSize s = [[UIScreen mainScreen] bounds].size;
    game_end_menu_layer= [CCLayerColor layerWithColor:c width:s.height height:s.width];
    game_end_menu_layer.anchorPoint = ccp(0,0);
    [game_end_menu_layer retain];
    
    CCSprite *backimg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_PAUSEMENU_RETURN]];
    CCSprite *backimgzoom = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_PAUSEMENU_RETURN]];
    [UILayer set_zoom_pos_align:backimg zoomed:backimgzoom scale:1.4];
    
    CCMenuItemImage *back = [CCMenuItemImage itemFromNormalSprite:backimg 
                                                   selectedSprite:backimgzoom
                                                           target:self 
                                                         selector:@selector(nextlevel)];
    back.position = ccp(s.height/2,s.width/2);
    
    CCMenu* gameendmenu = [CCMenu menuWithItems:back, nil];
    gameendmenu.position = ccp(0,0);
    
    [game_end_menu_layer addChild:gameendmenu];
}

-(void)nextlevel {
    [[CCDirector sharedDirector] replaceScene:[GameEngineLayer scene_with:@"cave_test"]];
}

-(void)start_initial_anim {
    game_engine_layer.current_mode = GameEngineLayerMode_UIANIM;
    
    ingame_ui.visible = NO;
    curanim = [GameStartAnim init_with_callback:[Common cons_callback:self sel:@selector(end_initial_anim)]];
    [self addChild:curanim];
}
     
 -(void)end_initial_anim {
     game_engine_layer.current_mode = GameEngineLayerMode_GAMEPLAY;
     ingame_ui.visible = YES;
     [self removeChild:curanim cleanup:YES];
 }


-(void)init_ingame_ui {
    CCSprite *pauseicon = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_PAUSEICON]];
    CCSprite *pauseiconzoom = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_PAUSEICON]];
    [UILayer set_zoom_pos_align:pauseicon zoomed:pauseiconzoom scale:1.4];
    
    CCMenuItemImage *ingamepause = [CCMenuItemImage itemFromNormalSprite:pauseicon
                                                          selectedSprite:pauseiconzoom
                                                                  target:self 
                                                                selector:@selector(pause)];
    ingamepause.position = ccp([[UIScreen mainScreen] bounds].size.height - pauseicon.boundingBox.size.width +20, 
                               [[UIScreen mainScreen] bounds].size.width - pauseicon.boundingBox.size.height +20);
    
    CCMenuItemImage *count_disp_bg = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_COINCOUNT]]
                                                             selectedSprite:[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_COINCOUNT]]];
    count_disp_bg.anchorPoint = ccp(0,0);
    count_disp_bg.position = ccp(0,[[UIScreen mainScreen] bounds].size.width - count_disp_bg.boundingBox.size.height);
    
    
    //CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"test" fntFile:@"markerfelt32.fnt"]; TODO -- DO BITMAP FONT
    count_disp = [CCLabelTTF labelWithString:@"0" 
                                           fontName:@"Marker Felt" 
                                           fontSize:25];
    count_disp.color = ccc3(255,0,0);
    
    
    CCMenuItemLabel *cd_holder = [CCMenuItemLabel itemWithLabel:count_disp
                                         target:NULL 
                                       selector:NULL];
    
    cd_holder.anchorPoint = ccp(0,0);
    cd_holder.position = ccp(0 + 37,[[UIScreen mainScreen] bounds].size.width - count_disp.boundingBox.size.height-10);
    
    
    
    
    ingame_ui = [CCMenu menuWithItems:ingamepause,count_disp_bg,cd_holder, nil];
    ingame_ui.anchorPoint = ccp(0,0);
    ingame_ui.position = ccp(0,0);
    [self addChild:ingame_ui];
    
}

-(void)init_pause_menu {
    ccColor4B c = {0,0,0,200};
    CGSize s = [[UIScreen mainScreen] bounds].size;
    pauselayer= [CCLayerColor layerWithColor:c width:s.height height:s.width];
    pauselayer.anchorPoint = ccp(0,0);
    [pauselayer retain];
    
    CCSprite *playimg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_PAUSEMENU_PLAY]];
    CCSprite *playimgzoom = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_PAUSEMENU_PLAY]];
    [UILayer set_zoom_pos_align:playimg zoomed:playimgzoom scale:1.4];
    
    CCMenuItemImage *play = [CCMenuItemImage itemFromNormalSprite:playimg 
                                                   selectedSprite:playimgzoom
                                                           target:self 
                                                         selector:@selector(unpause)];
    play.position = ccp(s.height/2,s.width/2);
    
    CCSprite *backimg = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_PAUSEMENU_BACK]];
    CCSprite *backimgzoom = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_PAUSEMENU_BACK]];
    [UILayer set_zoom_pos_align:backimg zoomed:backimgzoom scale:1.4];
    CCMenuItemImage *back = [CCMenuItemImage itemFromNormalSprite:backimg 
                                                   selectedSprite:backimgzoom 
                                                           target:self 
                                                         selector:@selector(exit_to_menu)];
    back.position = ccp(s.height/2-100,s.width/2);
    
    CCMenu* pausemenu = [CCMenu menuWithItems:play,back, nil];
    pausemenu.position = ccp(0,0);
    
    [pauselayer addChild:pausemenu];
}

+(void)set_zoom_pos_align:(CCSprite*)normal zoomed:(CCSprite*)zoomed scale:(float)scale {
    zoomed.scale = scale;
    zoomed.position = ccp((-[zoomed contentSize].width * zoomed.scale + [zoomed contentSize].width)/2
                         ,(-[zoomed contentSize].height * zoomed.scale + [zoomed contentSize].height)/2);
}

-(void)set_gameengine:(GameEngineLayer*)ref {
    game_engine_layer = ref;
}

-(void)start_bone_collect_anim {
    BoneCollectUIAnimation* b = [BoneCollectUIAnimation init_start:[UILayer player_approx_position:game_engine_layer] end:ccp(0,[[UIScreen mainScreen] bounds].size.width)];
    [self addChild:b];
    [ingame_ui_anims addObject:b];
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_GAME_TICK) {
        [self update];
    } else if (e.type == GEventType_LOAD_LEVELEND_MENU) {
        [self load_game_end_menu];
    } else if (e.type == GEventType_COLLECT_BONE) {
        [self start_bone_collect_anim];
    }
}

-(void)update {
    level_bone_status b = [game_engine_layer get_bonestatus];
    NSString* tmp = [NSString stringWithFormat:@"%i",b.hasgets+b.savedgets];
    if (![[count_disp string] isEqualToString:tmp]) {
        [count_disp setString:tmp];
    }
    NSMutableArray *toremove = [NSMutableArray array];
    for (UIIngameAnimation *i in ingame_ui_anims) {
        if (i.ct <= 0) {
            [self removeChild:i cleanup:NO];
            [toremove addObject:i];
        }
    }
    [ingame_ui_anims removeObjectsInArray:toremove];
    [toremove removeAllObjects];
}



-(void)exit_to_menu {
    [GEventDispatcher push_event:[GEvent init_type:GEventType_QUIT]];
}


-(void)pause {
    [GEventDispatcher push_event:[GEvent init_type:GEventType_PAUSE]];
    
    if (pauselayer.parent == NULL) {
        ingame_ui.visible = NO;
        [[CCDirector sharedDirector] pause];
        [[[CCDirector sharedDirector] runningScene] addChild:pauselayer];
    }
}
                         
-(void)unpause {
    [GEventDispatcher push_event:[GEvent init_type:GEventType_UNPAUSE]];
    
    if (pauselayer.parent != NULL) {        
        ingame_ui.visible = YES;
        [[CCDirector sharedDirector] resume];
        [[[CCDirector sharedDirector] runningScene] removeChild:pauselayer cleanup:NO];
    }
 }

-(void)dealloc {
    [ingame_ui_anims removeAllObjects];
    [ingame_ui_anims release];
    [pauselayer release];
    [game_end_menu_layer removeAllChildrenWithCleanup:YES];
    [game_end_menu_layer release];
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

+(CGPoint)player_approx_position:(GameEngineLayer*)game_engine_layer {
    CGPoint center = [game_engine_layer convertToWorldSpace:game_engine_layer.player.position];
    CGPoint scrn = ccp(-game_engine_layer.camera_state.x,-game_engine_layer.camera_state.y);
    
    center.x += scrn.x/1.3;
    center.y += scrn.y/1.3;
    
    if (game_engine_layer.player.current_island != NULL) {
        Vec3D* nvec = [game_engine_layer.player.current_island get_normal_vecC];
        Vec3D* normal = [Vec3D init_x:nvec.x y:nvec.y z:nvec.z];
        [normal scale:10];
        center.x += normal.x;
        center.y += normal.y;
        [normal dealloc];
    } else {
        center.x += 10;
        center.y += 10;
    }
    
    return center;
    
}


-(void)draw {
    [super draw];
//    glColor4f(1.0, 0, 0, 1.0);
//    ccDrawLine(ccp(0, 160),ccp(480,160));
//    ccDrawLine(ccp(240, 0),ccp(240,320));
}

@end