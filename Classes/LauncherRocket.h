#import "GameObject.h"

@interface LauncherRocket : GameObject {
    CGPoint v;
    BOOL kill;
    int ct,remlimit;
}

+(LauncherRocket*)cons_at:(CGPoint)pt vel:(CGPoint)vel;
-(void)update_position;
-(id)set_remlimit:(int)t;

@end

@interface RelativePositionLauncherRocket : LauncherRocket {
    CGPoint rel_pos,player_pos;
}
+(RelativePositionLauncherRocket*)cons_at:(CGPoint)pt player:(CGPoint)player vel:(CGPoint)vel;

@end