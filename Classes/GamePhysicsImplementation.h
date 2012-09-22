#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Island.h"
#import "Common.h"
#import "Player.h"
#import "PlayerEffectParams.h"

@interface GamePhysicsImplementation:NSObject

+(void)player_move:(Player*)player with_islands:(NSMutableArray*)islands;

@end
