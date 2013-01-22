#import "PlayerEffectParams.h"
#import "GEventDispatcher.h"

@class FlashEffect;

@interface HitEffect : PlayerEffectParams

+(HitEffect*)init_from:(PlayerEffectParams*)base time:(int)time;
@property(readwrite,assign) player_anim_mode tmode;
@end


@interface FlashHitEffect : HitEffect
+(FlashHitEffect*)init_from:(PlayerEffectParams*)base time:(int)time;
@end