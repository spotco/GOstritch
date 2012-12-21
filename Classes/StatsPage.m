#import "StatsPage.h"

@implementation StatsPage

-(void)cons_starting_at:(CGPoint)tstart {
    [super cons_starting_at:tstart];
    
    [self addChild:[Common cons_label_pos:[Common screen_pctwid:0.5 pcthei:0.85] 
                                    color:ccc3(0, 0, 0) 
                                 fontsize:50 
                                      str:@"Stats"]];
    
    
    [self addChild:[Common cons_label_pos:[Common screen_pctwid:0.5 pcthei:0.5] 
                                    color:ccc3(0, 0, 0) 
                                 fontsize:25 
                                      str:[NSString stringWithFormat:@"Total Bones Collected: %i",
                                           [DataStore get_int_for_key:STO_totalbones_INT]]]];
    
    [self addChild:[Common cons_label_pos:[Common screen_pctwid:0.5 pcthei:0.3] 
                                    color:ccc3(0, 0, 0) 
                                 fontsize:25 
                                      str:[NSString stringWithFormat:@"Max Bones Collected: %i",
                                           [DataStore get_int_for_key:STO_maxbones_INT]]]];
}

@end
