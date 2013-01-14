#import "GameObject.h"
#import "GEventDispatcher.h"

@interface LabEntrance : GameObject {
    GameObject *afg_area;
    gl_render_obj back_body,ceil_edge,ceil_body;
    BOOL activated;
}

+(LabEntrance*)cons_pt:(CGPoint)pt;
-(id)init_pt:(CGPoint)pt;
-(BOOL)get_do_render;
-(void)entrance_event;
@end

@interface LabEntranceFG : GameObject {
    gl_render_obj front_body;
    LabEntrance* base;
    
}
+(LabEntranceFG*)cons_pt:(CGPoint)pt base:(LabEntrance*)base;
@end
