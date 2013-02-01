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
-(id)cons_pt:(CGPoint)pt v:(CGPoint)vel;
-(void)move:(GameEngineLayer*)g;
@end