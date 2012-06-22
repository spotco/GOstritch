#import "CurveIsland.h"

@implementation CurveIsland

@synthesize theta_i,theta_f;

+(CurveIsland*) init_pt_i:(CGPoint)pt_i pt_f:(CGPoint)pt_f theta_i:(float)theta_i theta_f:(float)theta_f  {
    CurveIsland *n = [CurveIsland node];
    n.startX = pt_i.x;
    n.startY = pt_i.y;
    n.endX = pt_f.x;
    n.endY = pt_f.y;
    n.theta_i = theta_i;
    n.theta_f = theta_f;
    return n;
}

-(float)get_height:(float)pos {
    if (pos > endX || pos < startX) {
        return -1;
    } else {
        float pos_theta = ((pos - startX) / (endX - startX)) * (theta_f - theta_i) + theta_i;
        return (endY - startY)*sinf(pos_theta)+startY;
    }
}

-(void) draw {
    [super draw];
    float min_range = startX;
    float max_range = endX;
    CGPoint points[100];
    
    for (int i = 0; i < 100; i++) {
        float px = startX + i*(max_range-min_range)/100;
        points[i] = ccp(px,[self get_height:px]);
        //NSLog(@"%f,%f",points[i].x,points[i].y);
    }
    glPointSize(3);
    glColor4ub(255,0,0,255);
    ccDrawPoints( points, 100);
}

/*CGPoint points[100];
 int j = 0;
 for(int i = min_range; i<max_range;i+=(int)((max_range-min_range)/100)) {
 points[j]=ccp(i-[self position].x,[self get_height:(float)i]-[self position].y);
 j++;
 }
 glPointSize(3);
 glColor4ub(255,0,0,255);
 ccDrawPoints( points, 100);*/

@end
