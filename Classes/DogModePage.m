#import "DogModePage.h"
#import "AudioManager.h" 

@implementation DogModePage

-(void)cons_starting_at:(CGPoint)tstart {
    [super cons_starting_at:tstart];
    
    [self addChild:[Common cons_label_pos:[Common screen_pctwid:0.5 pcthei:0.85] 
                                    color:ccc3(0, 0, 0) 
                                 fontsize:50 
                                      str:@"Dog Select"]];
    
    /*TODO: subclass and make interactive*/
    MainMenuPageZoomButton* dog1ic = [[MainMenuPageZoomButton cons_texture:[Resource get_tex:TEX_UI_GAMEOVER_LOGO] 
                                                                        at:ccp([Common SCREEN].width/2,[Common SCREEN].height*0.3) 
                                                                        fn:[Common cons_callback:self sel:@selector(dog1)]] set_zoom:1.1];
    [self add_interactive_item:dog1ic];
    
    anims = [[NSMutableArray alloc] init];
    dogsimgs = [[NSMutableArray alloc] init];
    [self temp_make_dog_tex:TEX_DOG_RUN_2 pos:ccp(40,120) sel:@selector(dog2)];
    [self temp_make_dog_tex:TEX_DOG_RUN_3 pos:ccp(130,180) sel:@selector(dog3)];
    [self temp_make_dog_tex:TEX_DOG_RUN_4 pos:ccp(200,200) sel:@selector(dog4)];
    [self temp_make_dog_tex:TEX_DOG_RUN_5 pos:ccp(320,100) sel:@selector(dog5)];
    [self temp_make_dog_tex:TEX_DOG_RUN_6 pos:ccp(380,185) sel:@selector(dog6)];
    [self temp_make_dog_tex:TEX_DOG_RUN_7 pos:ccp(150,70) sel:@selector(dog7)];
}

-(void)temp_make_dog_tex:(NSString*)tex pos:(CGPoint)pos sel:(SEL)sel {
    CCSprite *s = [CCSprite node];
    [s setContentSize:CGSizeMake(71, 66)];
    CCAction *anim = [self init_run_anim:tex];
    [s runAction:anim];
    MainMenuPageZoomButton *t = [MainMenuPageZoomButton cons_spr:s at:pos fn:[Common cons_callback:self sel:sel]];
    [self add_interactive_item:t];
    
    [dogsimgs addObject:s];
    [anims addObject:anim];
    
}

-(void)dog1 {[AudioManager playsfx:SFX_BARK];[Player set_character:TEX_DOG_RUN_1];[GEventDispatcher push_event:[GEvent init_type:GEventType_CHANGE_CURRENT_DOG]];}
-(void)dog2 {[AudioManager playsfx:SFX_BARK];[Player set_character:TEX_DOG_RUN_2];[GEventDispatcher push_event:[GEvent init_type:GEventType_CHANGE_CURRENT_DOG]];}
-(void)dog3 {[AudioManager playsfx:SFX_BARK];[Player set_character:TEX_DOG_RUN_3];[GEventDispatcher push_event:[GEvent init_type:GEventType_CHANGE_CURRENT_DOG]];}
-(void)dog4 {[AudioManager playsfx:SFX_BARK];[Player set_character:TEX_DOG_RUN_4];[GEventDispatcher push_event:[GEvent init_type:GEventType_CHANGE_CURRENT_DOG]];}
-(void)dog5 {[AudioManager playsfx:SFX_BARK];[Player set_character:TEX_DOG_RUN_5];[GEventDispatcher push_event:[GEvent init_type:GEventType_CHANGE_CURRENT_DOG]];}
-(void)dog6 {[AudioManager playsfx:SFX_BARK];[Player set_character:TEX_DOG_RUN_6];[GEventDispatcher push_event:[GEvent init_type:GEventType_CHANGE_CURRENT_DOG]];}
-(void)dog7 {[AudioManager playsfx:SFX_BARK];[Player set_character:TEX_DOG_RUN_7];[GEventDispatcher push_event:[GEvent init_type:GEventType_CHANGE_CURRENT_DOG]];}

-(CCAction*)init_run_anim:(NSString*)tar {
	CCTexture2D *texture = [Resource get_tex:tar];
	NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"run_0"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"run_1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"run_2"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:tar idname:@"run_3"]]];
	return [[Common make_anim_frames:animFrames speed:float_random(0.1, 0.3)] retain];
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:NO];
    for (CCSprite *s in dogsimgs) {
        [s stopAllActions];
    }
    for(CCAction* a in anims) {
        [a release];
    }
    [anims removeAllObjects];
    [dogsimgs removeAllObjects];
    [anims release];
    [dogsimgs release];
    [super dealloc];
}

@end
