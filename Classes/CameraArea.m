#import "CameraArea.h"
#import "GameEngineLayer.h"

@implementation CameraArea

+(CameraArea*)init_x:(float)x y:(float)y wid:(float)wid hei:(float)hei zoom:(CameraZoom)czoom {
    CameraArea* a = [CameraArea node];
    [a init_x:x y:y width:wid height:hei];
    [a set_tar:czoom];
    return a;
}

+(void)normal_to_gl_coord:(CameraZoom*)glzd {
    float scrwid = [[UIScreen mainScreen] bounds].size.height;
    float scrhei = [[UIScreen mainScreen] bounds].size.width;
    
    glzd->x = scrwid/2 - glzd->x;
    glzd->y = scrhei/2 - glzd->y;
}

-(void)set_tar:(CameraZoom)c {
    [CameraArea normal_to_gl_coord:&c]; //NSLog(@"(%f,%f,%f)",c.x,c.y,c.z);
    tar = c;
}

-(GameObjectReturnCode)update:(Player *)player g:(GameEngineLayer *)g {
    if (!active) {
        return GameObjectReturnCode_NONE;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [g set_target_camera:tar];
    }
    
    return GameObjectReturnCode_NONE;
}

@end
