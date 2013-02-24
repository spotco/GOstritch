#import "AutoLevel.h"
#import "GameEngineLayer.h"
#import "DogBone.h"

@implementation AutoLevel

#define REMOVEBUFFER 400
#define ADDBUFFER 600

static int DEBUG_MODE = 0;

+(void)SET_DEBUG_MODE:(int)t {
    DEBUG_MODE = t;
}

static NSArray* levelset_classic;
static NSArray* levelset_filler;
static NSArray* levelset_jumppad;
static NSArray* levelset_swingvine;

static NSArray* levelset_boss1area;
static NSArray* levelset_autostart;

static NSArray* bossloadertest;

#define AUTOLEVEL_STARTLVL @"autolevel_start"

+(void)cons_levels {
    levelset_classic = [[NSArray alloc] initWithObjects:
        @"classic_bridgenbwall",
        @"classic_cavewbwall",
        @"classic_huegcave",
        @"classic_trickytreas",
    nil];
    
    levelset_filler = [[NSArray alloc] initWithObjects:
        @"filler_curvedesc",
        @"filler_islandjump",
        @"filler_rollinghills",
        @"filler_sanicloop",
        @"filler_someswings",
    nil];
    
    levelset_jumppad = [[NSArray alloc] initWithObjects:
        @"jumppad_bigjump",
        @"jumppad_bouncyroom",
        @"jumppad_crazyloop",
        @"jumppad_hiddenislands",
        @"jumppad_jumpgap",
        @"jumppad_jumpislands",
        @"jumppad_launch",
        @"jumppad_lotsobwalls",
        @"jumppad_spikeceil",
     nil];
    
    levelset_swingvine = [[NSArray alloc] initWithObjects:
        @"swingvine_swingintro",
        @"swingvine_dodgespike",
        @"swingvine_swingbreak",
        @"swingvine_bounswindodg",
    nil];
    
    levelset_autostart = [[NSArray alloc] initWithObjects:AUTOLEVEL_STARTLVL, nil];
    
    bossloadertest = [[NSArray alloc] initWithObjects:@"bossloadertest", nil];
    levelset_boss1area = [[NSArray alloc] initWithObjects:@"boss1_area", nil];
}

+(NSArray*)random_set1 {
    NSMutableArray *a = [NSMutableArray array];
    [a addObjectsFromArray:levelset_classic];
    [a addObjectsFromArray:levelset_filler];
    [a addObjectsFromArray:levelset_jumppad];
    [a addObjectsFromArray:levelset_swingvine];
    return a;
}

+(NSArray*)random_boss1test_levels {
    return bossloadertest;
}

+(NSArray*)boss1_set {
    return levelset_boss1area;
}

+(AutoLevel*)cons_with_glayer:(GameEngineLayer*)glayer {
    AutoLevel* a = [AutoLevel node];
    [a cons:glayer];
    [GEventDispatcher add_listener:a];
    return a;
}

-(void)cons:(GameEngineLayer*)glayer {
    for (NSString* i in [AutoLevel random_set1]) {
        [MapLoader precache_map:i];
    }
    tglayer = glayer;
    
    NSArray *to_load = levelset_autostart;
    map_sections = [[NSMutableArray alloc] init];
    stored = [[NSMutableArray alloc] init];
    queued_sections = [[NSMutableArray alloc] init];
    
    cur_mode = AutoLevelMode_Normal;
    
    for (NSString* i in to_load) {
        [self load_into_queue:i];
    }
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_CHECKPOINT) {
        [self cleanup_start:tglayer.player.start_pt player:tglayer.player.position];
        
    } else if (e.type == GEventType_BOSS1_ACTIVATE) {
        cur_mode = AutoLevelMode_BOSS1;
        [self remove_all_ahead_but_current:e.pt];
        [self shift_queue_into_current];
        
    } else if (e.type == GEventType_BOSS1_DEFEATED) {
        cur_mode = AutoLevelMode_Normal;
        [GEventDispatcher push_event:[[GEvent init_type:GEventType_CHECKPOINT] add_pt:e.pt]];
        [self remove_all_ahead_but_current:e.pt];
        [tglayer stopAction:tglayer.follow_action];
        tglayer.follow_action = [CCFollow actionWithTarget:tglayer.player];
        [tglayer runAction:tglayer.follow_action];
        
    }
}

-(void)remove_all_ahead_but_current:(CGPoint)pos {
    CGPoint min_cur = ccp(cur_x,cur_y);
    for (MapSection *m in queued_sections) {
        if ([m get_offset].x < min_cur.x) {
            min_cur = [m get_offset];
        }
    }
    [queued_sections removeAllObjects];
    for (int i = map_sections.count-1; i >= 0; i--) {
        if (map_sections.count-1 < i) continue;
        MapSection *m = [map_sections objectAtIndex:i];
        MapSection_Position p = [m get_position_status:pos];
        if (p != MapSection_Position_CURRENT) {
            if (p != MapSection_Position_PAST && [m get_offset].x < min_cur.x) {
                min_cur = [m get_offset];
            }
            [self remove_map_section_from_current:m];
        }
    }
    cur_x = min_cur.x;
    cur_y = min_cur.y;
    
}

-(void)load_into_queue:(NSString*)key { //load map into queue
    MapSection *m = [MapSection init_from_name:key];
    if (!has_pos_initial) {
        cur_x = m.map.connect_pts_x1;
        cur_y = m.map.connect_pts_y1;
        has_pos_initial = YES;
    }
    
    
    [m offset_x:cur_x y:cur_y];
    cur_x = (m.map.connect_pts_x2 - m.map.connect_pts_x1)+cur_x;
    cur_y = (m.map.connect_pts_y2 - m.map.connect_pts_y1)+cur_y;
    [queued_sections addObject:m];
}

-(void)shift_queue_into_current { //move top map in queue to current
    if ([queued_sections count] == 0) {
        [self load_into_queue:[self get_random_map]];
    }
    MapSection *m = [queued_sections objectAtIndex:0];
    [queued_sections removeObjectAtIndex:0];
    
    [map_sections addObject:m];
    
    [tglayer.islands addObjectsFromArray:m.map.n_islands];
    [Island link_islands:tglayer.islands];
    for (Island* i in m.map.n_islands) {
        [tglayer addChild:i z:[i get_render_ord]];
    }
    
    [tglayer.game_objects addObjectsFromArray:m.map.game_objects];
    for (GameObject* o in m.map.game_objects) {
        [tglayer addChild:o z:[o get_render_ord]];
        if ([o class] == [DogBone class]) {
            [tglayer add_bone:(DogBone*)o autoassign:YES];
        }
    }
    
    
    
}

-(void)remove_map_section_from_current:(MapSection*)m {
    [tglayer.islands removeObjectsInArray:m.map.n_islands];
    
    for (Island* i in m.map.n_islands) {
        if (tglayer.player.current_island == i) tglayer.player.current_island = NULL;
        [tglayer removeChild:i cleanup:NO];
        if (i.prev != NULL) {
            i.prev.next = NULL;
            i.prev = NULL;
        }
        if (i.next != NULL) {
            i.next.prev = NULL;
            i.next = NULL;
        }
    }
    
    [tglayer.game_objects removeObjectsInArray:m.map.game_objects];
    
    for(GameObject* o in m.map.game_objects) {
        [tglayer removeChild:o cleanup:NO];
        if (tglayer.player.current_swingvine == o) tglayer.player.current_swingvine = NULL;
    }
    
    [map_sections removeObject:m];
}

-(void)cleanup_start:(CGPoint)player_startpt player:(CGPoint)cur {
    for(int j = map_sections.count-1; j >= 0; j--) {
        MapSection *i = [map_sections objectAtIndex:j];
        MapSection_Position ip = [i get_position_status:player_startpt];
        if (ip == MapSection_Position_PAST) {
            [self remove_map_section_from_current:i];
            [i release];
        }
    }
    
    for(MapSection *m in stored) {
        [m release];
    }
    [stored removeAllObjects];
}
-(void)update:(Player *)player g:(GameEngineLayer *)g {
    CGPoint pos = player.position;
    NSMutableArray *tostore = [[NSMutableArray alloc] init];
    MapSection *current;
    int ct_ahead = 0;
    
    for (MapSection *i in map_sections) { //get past ones
        CGRange range = [i get_range];
        MapSection_Position ip = [i get_position_status:pos];
        if (ip == MapSection_Position_PAST && range.max+REMOVEBUFFER < player.position.x) {
            [tostore addObject:i];
        } else if (ip == MapSection_Position_CURRENT) {
            current = i;
        } else if (ip == MapSection_Position_AHEAD) {
            ct_ahead++;
        }
    }
    
    if ([tostore count] > 0) { //move past ones to stored
        for (MapSection *i in tostore) {
            [stored addObject:i];
            [self remove_map_section_from_current:i];
        }
    }
    
    if ( ([map_sections count] == 0) || 
         (ct_ahead == 0 && [current get_range].max-ADDBUFFER < player.position.x) ) {
        [self shift_queue_into_current];
    }
    
    //NSLog(@"sto:%i cur:%i que:%i",[stored count],[map_sections count],[queued_sections count]);
    [tostore removeAllObjects];
    [tostore dealloc];
    return;
}

-(void)reset_map:(MapSection*)m {
    for (GameObject *o in m.map.game_objects) {
        [o reset];
    }
}

-(void)reset { //move all in stored to current (TODO: some in queue)
    for (int i = map_sections.count-1; i>=0; i--) {
        MapSection *t = [map_sections objectAtIndex:i];
        [self reset_map:t];
        [queued_sections insertObject:t atIndex:0];
        [self remove_map_section_from_current:t];
        
    }
    for (int i = stored.count-1; i>=0; i--) {
        MapSection *t = [stored objectAtIndex:i];
        [self reset_map:t];
        [queued_sections insertObject:t atIndex:0];
        [stored removeObjectAtIndex:i];
        
    }
    [self shift_queue_into_current];
    
    [super reset];
}

static NSString* lastlvlloaded;

-(NSString*)get_random_map {
    NSArray* tlvls;
    if (cur_mode == AutoLevelMode_Normal) {
        if (DEBUG_MODE == 1) {
            tlvls = [AutoLevel random_boss1test_levels];
        } else {
            tlvls = [AutoLevel random_set1];
        }
    } else {
        tlvls = [AutoLevel boss1_set];
    }
    NSString* ch = [tlvls objectAtIndex:arc4random_uniform([tlvls count])];
    lastlvlloaded = ch;
    NSLog(@"lvl:%@",ch);
    return ch;
}

-(void)dealloc {
    for (MapSection *m in map_sections) {
        [m release];
    }
    for (MapSection *m in stored) {
        [m release];
    }
    for (MapSection *m in queued_sections) {
        [m release];
    }
    [queued_sections removeAllObjects];
    [queued_sections release];
    [stored removeAllObjects];
    [stored release];
    [map_sections removeAllObjects];
    [map_sections release];
    [super dealloc];
}
-(NSString*)get_debug_msg {
    return lastlvlloaded;
    //return strf("STO:%i CUR:%i QUE:%i",[stored count],[map_sections count],[queued_sections count]);
}
@end


