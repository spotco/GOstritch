#import <Foundation/Foundation.h>
#import "Player.h"
#import "Island.h"
#import "GameObject.h"
#import "Common.h"
#import "PlayerEffectParams.h"
#import "DashEffect.h"
@class GameEngineLayer;

@interface GameControlImplementation:NSObject

+(void)control_update_player:(GameEngineLayer*)g;
+(void)reset_control_state;

+(void)touch_begin:(CGPoint)pt;
+(void)touch_move:(CGPoint)pt;
+(void)touch_end:(CGPoint)pt;

@end
