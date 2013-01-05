#import "MapSection.h"

#define DOTMAP @"map"

@implementation MapSection
@synthesize map;

+(MapSection*)init_from_name:(NSString*)name {
    MapSection* m = [[MapSection alloc] init];
    [m cons:name];
    return m;
}

-(void)cons:(NSString*)name {
    map = [MapLoader load_map:name];
    [MapSection transform_map:map by_x:-map.connect_pts_x1 by_y:-map.connect_pts_y1];
    offset_x = 0;
    offset_y = 0;
    [self alloc_debugid];
}

-(MapSection_Position)get_position_status:(CGPoint)p {
    CGRange range = [self get_range];
    float min = range.min;
    float max = range.max;
    
    if (p.x >= min && p.x <= max) {
        return MapSection_Position_CURRENT;
    } else if (p.x < min) {
        return MapSection_Position_AHEAD;
    } else if (p.x > max) {
        return MapSection_Position_PAST;
    } else {
        NSLog(@"mapsection code error");
        return MapSection_Position_CURRENT;
    }
}

-(CGPoint)get_offset {
    return ccp(offset_x,offset_y);
}

-(CGRange)get_range {
    struct CGRange r;
    r.min = offset_x;
    r.max = offset_x + (map.connect_pts_x2 - map.connect_pts_x1);
    return r;
}

-(void)offset_x:(float)x y:(float)y {
    offset_x += x;
    offset_y += y;
    [MapSection transform_map:map by_x:x by_y:y];
}

+(void)transform_map:(GameMap)map by_x:(float)tx by_y:(float)ty {
    for (Island* i in map.n_islands) {
        [i setPosition:ccp(i.position.x+tx,i.position.y+ty)];
        i.startX +=tx;
        i.startY +=ty;
        i.endX +=tx;
        i.endY +=ty;
    }
    for (GameObject* o in map.game_objects) {
        [o setPosition:ccp(o.position.x+tx,o.position.y+ty)];
    }
}

-(void)dealloc {
    //NSLog(@"dealloc mapsection");
    [map.game_objects removeAllObjects];
    [map.n_islands removeAllObjects];
    [map.game_objects release];
    [map.n_islands release];
    [super dealloc];
}

static int debugct = 0;
-(void)alloc_debugid {
    debugid = debugct;
    debugct++;
}
-(int)get_debugid {
    return debugid;
}

@end