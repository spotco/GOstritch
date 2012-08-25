#import <Foundation/Foundation.h>
#import "Player.h"
#import "Island.h"
#import "GameObject.h"
#import "Common.h"
#import "PlayerEffectParams.h"
#import "DashEffect.h"

@interface GameControlImplementation:NSObject

+(void)control_update_player:(Player*)player 
                     islands:(NSMutableArray*)islands 
                     objects:(NSMutableArray*)game_objects;

+(void)touch_begin:(CGPoint)pt;
+(void)touch_move:(CGPoint)pt;
+(void)touch_end:(CGPoint)pt;

@end
