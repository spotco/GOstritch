#import "CharacterSelectPage.h"

@implementation CharacterSelectPage

+(CCScene*)scene {
    CCScene* cn = [CCScene node];
    CharacterSelectPage *p = [CharacterSelectPage node];
    [p initialize];
    [cn addChild:p];
    return cn;
}

-(void)initialize {
    CCSprite *bg_img = [CCSprite spriteWithFile:@"Front-Page_background.png"];
    bg_img.position = ccp([UIScreen mainScreen].bounds.size.height/2, [UIScreen mainScreen].bounds.size.width/2);
    [self addChild:bg_img];
    
    CCLabelTTF *text = [CCLabelTTF labelWithString:@"SELECT CHARACTER" 
                                    fontName:@"Marker Felt" 
                                    fontSize:25];
    text.color = ccc3(255,0,0);
    [text setPosition:ccp(50,200)];
    [text setAnchorPoint:ccp(0,0)];
    [self addChild:text];
    
    
    CCMenuItem *d1 = [MenuCommon make_button_img:@"select_dog1_small.png" imgsel:@"select_dog1_big.png" onclick_target:self selector:@selector(dog1)];
    [d1 setPosition:ccp(-150,0)];
    CCMenuItem *d2 = [MenuCommon make_button_img:@"select_dog3_small.png" imgsel:@"select_dog3_big.png" onclick_target:self selector:@selector(dog2)];
    [d2 setPosition:ccp(-100,0)];
    CCMenuItem *d3 = [MenuCommon make_button_img:@"select_dog3_small.png" imgsel:@"select_dog3_big.png" onclick_target:self selector:@selector(dog3)];
    [d3 setPosition:ccp(-50,0)];
    CCMenuItem *d4 = [MenuCommon make_button_img:@"select_dog4_small.png" imgsel:@"select_dog4_big.png" onclick_target:self selector:@selector(dog4)];
    [d4 setPosition:ccp(0,0)];
    CCMenuItem *d5 = [MenuCommon make_button_img:@"select_dog5_small.png" imgsel:@"select_dog5_big.png" onclick_target:self selector:@selector(dog5)];
    [d5 setPosition:ccp(50,0)];
    CCMenuItem *d6 = [MenuCommon make_button_img:@"select_dog6_small.png" imgsel:@"select_dog6_big.png" onclick_target:self selector:@selector(dog6)];
    [d6 setPosition:ccp(100,0)];

    
    
    [self addChild:[CCMenu menuWithItems:d1,d2,d3,d4,d5,d6, nil]];
}

-(void)dog1{ [Player set_character:TEX_DOG_RUN_1]; [self start_game]; }
-(void)dog2{ [Player set_character:TEX_DOG_RUN_2]; [self start_game]; }
-(void)dog3{ [Player set_character:TEX_DOG_RUN_3]; [self start_game]; }
-(void)dog4{ [Player set_character:TEX_DOG_RUN_4]; [self start_game]; }
-(void)dog5{ [Player set_character:TEX_DOG_RUN_5]; [self start_game]; }
-(void)dog6{ [Player set_character:TEX_DOG_RUN_6]; [self start_game]; }

-(void)start_game {
    [[[CCDirector sharedDirector] runningScene] removeAllChildrenWithCleanup:YES];
    [[CCDirector sharedDirector] replaceScene:[GameEngineLayer scene_with_autolevel]];
}

@end
