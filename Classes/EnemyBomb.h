#import "GameObject.h"
#import "PhysicsEnabledObject.h"

@interface EnemyBomb : GameObject {
    CCSprite *body;
    CGPoint v;
    float vtheta;
    int ct;
    BOOL knockout;
}

+(EnemyBomb*)cons_pt:(CGPoint)pt v:(CGPoint)vel;
@end

//TODO--relativeposition bomb