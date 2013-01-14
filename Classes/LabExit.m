#import "LabExit.h"

@implementation LabExit

+(LabExit*)cons_pt:(CGPoint)pt {
    return [[LabExit node] init_pt:pt];
}

-(id)init_pt:(CGPoint)pt {
    return [super init_pt:pt];
}

-(void)entrance_event {
    [GEventDispatcher push_event:[GEvent init_type:GEventType_EXIT_TO_DEFAULTAREA]];
}


@end
