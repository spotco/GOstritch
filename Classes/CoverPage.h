//
//  CoverPage.h
//  GOstrich
//
//  Created by Pingyang He on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameEngineLayer.h"

@interface CoverPage : CCLayer{
 
    /*CCSprite *titleBoard;
    CCSprite *playButton;
    CCSprite *scoreButton;
    CCSprite *settingButton;
    NSMutableArray *tappableCCSprites;
    CCSprite *currentlyTapped;
    NSDictionary *untappedImg;
    NSDictionary *tappedImg;
    
    int playButtonShiftX;
    int playButtonShiftY;
    int settingButtonShiftX;
    int scoreButtonShiftY;*/
    
    CCMenu *front_menu;
    CCSprite *bg_img;
    
}

+(CCScene *) scene;

//create and return background layer
/*-(void) init_bg_layer;

//setup sprite with given properties and return the sprite
-(CCSprite *) getSpritesWithFile:(NSString *) fileName atPositionX:(int) x andY:(int)y;

-(void)setupImages;*/

@end
