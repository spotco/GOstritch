
#import <Foundation/Foundation.h>

@interface GameRenderState : NSObject {
    float cx,cy,cz,ex,ey,ez;
    
    float prevx,prevy;
}


@property(readwrite,assign) float cx,cy,cz,ex,ey,ez;

@property(readwrite,assign) float prevx,prevy;


@end
