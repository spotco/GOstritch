#import "CopterRobotLoader.h"
#import "GameEngineLayer.h"

@implementation CopterRobotLoader

+(CopterRobotLoader*)cons_x:(float)x y:(float)y {
    return [[CopterRobotLoader node] cons_at:ccp(x,y)];
}

-(CopterRobotLoader*)cons_at:(CGPoint)pos {
    [self setPosition:pos];
    self.active = NO;
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!self.active && player.position.x > position_.x) {
        active = YES;
        [GEventDispatcher push_event:[[GEvent cons_type:GEventType_BOSS1_ACTIVATE] add_pt:player.position]];
        [g add_gameobject:[CopterRobot cons_with_playerpos:player.position]];
    }
}

-(void)reset {
    [super reset];
    self.active = NO;
}


@end
