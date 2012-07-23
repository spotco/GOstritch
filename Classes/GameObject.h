
#import "CCNode.h"
#import "Player.h"
#import "GameRenderImplementation.h"

@interface GameObject : CCNode {
    BOOL active;
    CCSprite *img;
}

typedef enum {
    GameObjectReturnCode_NONE,
    GameObjectReturnCode_ENDGAME
} GameObjectReturnCode;

@property(readwrite,assign) BOOL active;
@property(readwrite,assign) CCSprite *img;

-(GameObjectReturnCode)update:(Player*)player;
-(HitRect) get_hit_rect;
-(void)set_active:(BOOL)t_active;
-(int)get_render_ord;

@end
