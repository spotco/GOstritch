#import "SettingsPage.h"

@implementation SettingsPage

-(void)cons_starting_at:(CGPoint)tstart {
    [super cons_starting_at:tstart];
    
    [self addChild:[Common cons_label_pos:[Common screen_pctwid:0.5 pcthei:0.85] 
                                    color:ccc3(0, 0, 0) 
                                 fontsize:50 
                                      str:@"Settings"]];
}

@end
