//
//  CoverPage.m
//  GOstrich
//
//  Created by Pingyang He on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoverPage.h"

@implementation CoverPage

-(id)init{
    self = [super init];
    if (self) {
        
        playButtonShiftX = -3;
        playButtonShiftY = -5;
        
        settingButtonShiftX = -1;
        
        scoreButtonShiftY = -1;
        
   
        tappableCCSprites = [[NSMutableArray alloc] init];
        [self setupImages];
        [self schedule:@selector(update:)];
    }
    return self;
}

-(void)dealloc{

    [titleBoard release];
    [playButton release];
    [scoreButton release];
    [settingButton release];
    [tappableCCSprites release];
    [currentlyTapped release];
    [untappedImg release];
    [tappedImg release];
    
    [super dealloc];
}

-(CCScene *) scene{
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    [[CCDirector sharedDirector] setDisplayFPS:NO];		
	CCScene *scene = [CCScene node];
          
    CCLayer *background_layer = [self createBGLayer];
    
    	   
    CoverPage *coverPage = [[CoverPage alloc]init];
    
    [scene addChild:background_layer];
    [scene addChild:coverPage];
    
    return scene;
}

//set map from ccsprite button to it's images
-(void) setupImages{
    
    NSArray *keys = [[NSArray alloc ] initWithObjects:@"playButton", @"scoreButton", @"settingButton", nil];
    NSArray *untappedObjects = [[NSArray alloc ] initWithObjects:@"Front-Page_PLAY-withoutLight.png", @"Front-Page_scores.png", @"Front-Page_option.png", nil];
    
    NSArray *tappedObjects = [[NSArray alloc ]initWithObjects:@"Front-Page_PLAY-withLight.png", @"Front-Page_scores-withlight.png", @"Front-Page_option-withlight.png", nil];
    
    untappedImg = [[NSDictionary alloc ]initWithObjects:untappedObjects forKeys:keys];
    tappedImg = [[NSDictionary alloc ] initWithObjects:tappedObjects forKeys:keys];
}

-(CCLayer *) createBGLayer{
    CCLayer *bgLayer = [[CCLayer alloc]init];
    
    
    //add background
    [bgLayer addChild:[self getSpritesWithFile: @"Front-Page_background.png" 
                                   atPositionX: 0 
                                          andY: 0]];

    //add game play button
    playButton = [self getSpritesWithFile: [untappedImg objectForKey: @"playButton"]
                              atPositionX: 330 
                                     andY: -40];
    [bgLayer addChild:playButton];
    [tappableCCSprites addObject:playButton];
    
    //add title board
    titleBoard = [self getSpritesWithFile: @"Front-Page_titile.png" 
                              atPositionX: 100 
                                     andY: 200];
    [bgLayer addChild:titleBoard];
    
    //add score board button
    scoreButton = [self getSpritesWithFile: [untappedImg objectForKey: @"scoreButton"] 
                               atPositionX: 6 
                                      andY: 6];
    [bgLayer addChild:scoreButton];
    [tappableCCSprites addObject:scoreButton];
    
    //add setting button
    settingButton = [self getSpritesWithFile: [untappedImg objectForKey: @"settingButton"] 
                                 atPositionX: 8 
                                        andY: 45];
    [bgLayer addChild:settingButton];
    [tappableCCSprites addObject:settingButton];

    
    return bgLayer;
}

-(CCSprite *) getSpritesWithFile:(NSString *) fileName 
                     atPositionX:(int) x 
                            andY:(int) y{
    CCSprite *background_sprite = [CCSprite spriteWithFile:fileName];
    background_sprite.position = ccp(x, y);
    background_sprite.anchorPoint = ccp(0, 0);
    return background_sprite;
}

-(void)update:(ccTime)dt{
    
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{


    //check if any tappable CCsprites are touched
    for(CCSprite *button in tappableCCSprites){
        if (CGRectContainsPoint(CGRectMake(0, 0, button.contentSize.width,button.contentSize.height), [button convertTouchToNodeSpace:touch])){
            if(button == playButton){
                CCTexture2D *newImage = [[CCTextureCache sharedTextureCache] addImage:[tappedImg objectForKey: @"playButton"]];
                [playButton setTexture:newImage];
                playButton.position = ccp(playButton.position.x + playButtonShiftX, playButton.position.y + playButtonShiftY);
            
            }else if(button == settingButton){
                CCTexture2D *newImage = [[CCTextureCache sharedTextureCache] addImage:[tappedImg objectForKey: @"settingButton"]];
                [settingButton setTexture:newImage];
                settingButton.position = ccp(settingButton.position.x + settingButtonShiftX, settingButton.position.y);
       
          
            }else if(button == scoreButton){
                CCTexture2D *newImage = [[CCTextureCache sharedTextureCache] addImage:[tappedImg objectForKey: @"scoreButton"]];
                [scoreButton setTexture:newImage];
                scoreButton.position = ccp(scoreButton.position.x, scoreButton.position.y + scoreButtonShiftY);
             
            }
            currentlyTapped = button;
            break;
        }
    }
    return  YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    if(currentlyTapped != NULL){//a tappable button is tapped
        
        if(currentlyTapped == playButton){
            CCTexture2D *newImage = [[CCTextureCache sharedTextureCache] addImage:[untappedImg objectForKey: @"playButton"]];
            [playButton setTexture:newImage];
            playButton.position = ccp(playButton.position.x - playButtonShiftX, playButton.position.y - playButtonShiftY);
            
            NSLog(@"playButton");
        }else if(currentlyTapped == settingButton){
            CCTexture2D *newImage = [[CCTextureCache sharedTextureCache] addImage:[untappedImg objectForKey: @"settingButton"]];
            [settingButton setTexture:newImage];
            settingButton.position = ccp(settingButton.position.x - settingButtonShiftX, settingButton.position.y);
            NSLog(@"settingButton");
        }else if(currentlyTapped == scoreButton){
            CCTexture2D *newImage = [[CCTextureCache sharedTextureCache] addImage:[untappedImg objectForKey: @"scoreButton"]];
            [scoreButton setTexture:newImage];
            scoreButton.position = ccp(scoreButton.position.x, scoreButton.position.y - scoreButtonShiftY);
            NSLog(@"scoreButton");
        }
        
        if (CGRectContainsPoint(CGRectMake(0, 0, currentlyTapped.contentSize.width,currentlyTapped.contentSize.height), [currentlyTapped convertTouchToNodeSpace:touch])){
            if(currentlyTapped == playButton){
                [[CCDirector sharedDirector] replaceScene: [GameEngineLayer scene_with:@"bigjump"]];

            }else if(currentlyTapped == settingButton){
              
            }else if(currentlyTapped == scoreButton){
             
            }
            
        }
        
        currentlyTapped = NULL;
    }
  
}

@end
