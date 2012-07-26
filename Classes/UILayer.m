#import "UILayer.h"
#import "GameEngineLayer.h"

@implementation UILayer

+(UILayer*)init_with_gamelayer:(GameEngineLayer *)g {
    UILayer* u = [UILayer node];
    [u set_gameengine:g];
    return u;
}

-(id) init{
	if( (self = [super init])) {        
        [self init_ingame_ui];
        
        [self init_pause_menu];
        
        self.isTouchEnabled = YES;
	}
	return self;
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
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"0" 
                                           fontName:@"Marker Felt" 
                                           fontSize:25];
    label.color = ccc3(255,0,0);
    count_disp = [CCMenuItemLabel itemWithLabel:label
                                         target:NULL 
                                       selector:NULL];
    
    count_disp.anchorPoint = ccp(0,0);
    count_disp.position = ccp(0 + 37,[[UIScreen mainScreen] bounds].size.width - count_disp.boundingBox.size.height-10);
    
    
    
    
    ingame_ui = [CCMenu menuWithItems:ingamepause,count_disp_bg,count_disp, nil];
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
    
    CCMenu* pausemenu = [CCMenu menuWithItems:play, nil];
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

int tapcount = 0;

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {
    tapcount++;
    [count_disp setString:[NSString stringWithFormat:@"%i",tapcount]];
}


-(void)pause {
    if (!game_engine_layer.paused) {
        game_engine_layer.paused = YES;
        ingame_ui.visible = NO;
        [[CCDirector sharedDirector] pause];
        [[[CCDirector sharedDirector] runningScene] addChild:pauselayer];
    }
}
                         
-(void)unpause {
    if (game_engine_layer.paused) {
        game_engine_layer.paused = NO;
        ingame_ui.visible = YES;
        [[CCDirector sharedDirector] resume];
        [[[CCDirector sharedDirector] runningScene] removeChild:pauselayer cleanup:NO];
    }
 }

@end