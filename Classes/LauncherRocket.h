#import "GameObject.h"

@interface LauncherRocket : GameObject {
    CGPoint v;
    BOOL kill;
    int ct;
}

+(LauncherRocket*)cons_at:(CGPoint)pt vel:(CGPoint)vel;

@end