#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"

#define BGMUSIC_GAMELOOP1 @"gameloop1.mp3"
#define BGMUSIC_MENU1 @"menu1.mp3"

#define SFX_BONE @"sfx_bone.wav"
#define SFX_EXPLOSION @"sfx_explosion.wav" 
#define SFX_HIT @"sfx_hit.wav"
#define SFX_JUMP @"sfx_jump.wav"
#define SFX_SPIN @"sfx_spin.wav"
#define SFX_SPLASH @"sfx_splash.wav"
#define SFX_BIRD_FLY @"sfx_bird_fly.wav" 
#define SFX_ROCKBREAK @"sfx_rockbreak.wav"
#define SFX_ELECTRIC @"sfx_electric.wav"
#define SFX_JUMPPAD @"sfx_jumppad.wav"
#define SFX_ROCKET_SPIN @"sfx_rocket_spin.wav"
#define SFX_SPEEDUP @"sfx_speedup.wav"
#define SFX_BOP @"sfx_bop.wav"
#define SFX_CHECKPOINT @"sfx_checkpoint.wav" 
#define SFX_SWING @"sfx_swing.wav" 
#define SFX_BARK @"sfx_bark1.wav"

@interface AudioManager : NSObject

+(void)init;
+(void)play:(NSString*)tar;
+(void)playsfx:(NSString*)tar;

+(void)set_play_bgm:(BOOL)t;
+(void)set_play_sfx:(BOOL)t;

@end
