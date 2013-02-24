#import "MapLoader.h"

@implementation GameMap
@synthesize assert_links;
@synthesize connect_pts_x1,connect_pts_x2,connect_pts_y1,connect_pts_y2;
@synthesize game_objects,n_islands;
@synthesize player_start_pt;
@end

@implementation MapLoader

#define DOTMAP @"map"

static NSMutableDictionary* cached_json;

+(void) precache_map:(NSString *)map_file_name {
    if (cached_json == NULL) {
        cached_json = [[NSMutableDictionary alloc] init];
    }
    if ([cached_json objectForKey:map_file_name]) {
        return;
    }
    
    NSString *islandFilePath = [[NSBundle mainBundle] pathForResource:map_file_name ofType:DOTMAP];
	NSString *islandInputStr = [[NSString alloc] initWithContentsOfFile : islandFilePath encoding:NSUTF8StringEncoding error:NULL];
	NSData *islandData  =  [islandInputStr dataUsingEncoding : NSUTF8StringEncoding];
    [islandInputStr dealloc];
    
    NSDictionary *j_map_data = [[CJSONDeserializer deserializer] deserializeAsDictionary:islandData error:NULL];
    [cached_json setValue:j_map_data forKey:map_file_name];
}

+(NSDictionary*)get_jsondict:(NSString *)map_file_name {
    if (![cached_json objectForKey:map_file_name]) {
        [MapLoader precache_map:map_file_name];
    }
    return [cached_json objectForKey:map_file_name];
}

+(GameMap*) load_map:(NSString *)map_file_name {
    NSDictionary *j_map_data = [MapLoader get_jsondict:map_file_name];
    
    NSArray *islandArray = [j_map_data objectForKey:(@"islands")];
	int islandsCount = [islandArray count];
	
    GameMap *map = [[GameMap alloc] init];
    map.n_islands = [[NSMutableArray alloc] init];
    map.game_objects = [[NSMutableArray alloc] init];
    
    float start_x = getflt(j_map_data, @"start_x");
	float start_y = getflt(j_map_data, @"start_y");
    map.player_start_pt = ccp(start_x,start_y);
    //NSLog(@"Player starting at (%f,%f)",start_x,start_y);
    
    int assert_links = ((NSString*)[j_map_data objectForKey:(@"assert_links")]).intValue;
    map.assert_links = assert_links;
    
    NSDictionary* connect_pts = [j_map_data objectForKey:(@"connect_pts")];
    if(connect_pts != NULL) {
        map.connect_pts_x1 = getflt(connect_pts, @"x1");
        map.connect_pts_x2 = getflt(connect_pts, @"x2");
        map.connect_pts_y1 = getflt(connect_pts, @"y1");
        map.connect_pts_y2 = getflt(connect_pts, @"y2");
    }
    
	for(int i = 0; i < islandsCount; i++){
		NSDictionary *currentIslandDict = (NSDictionary *)[islandArray objectAtIndex:i];
        CGPoint start = ccp(getflt(currentIslandDict,@"x1"),getflt(currentIslandDict,@"y1"));
        CGPoint end = ccp(getflt(currentIslandDict,@"x2"),getflt(currentIslandDict,@"y2"));
        
        Island *currentIsland;
        
        float height = getflt(currentIslandDict, @"hei");
        NSString *ndir_str = [currentIslandDict objectForKey:@"ndir"];
        
        float ndir = 0;
        if ([ndir_str isEqualToString:@"left"]) {
            ndir = 1;
        } else if ([ndir_str isEqualToString:@"right"]) {
            ndir = -1;
        }
        BOOL can_land = ((NSString *)[currentIslandDict objectForKey:@"can_fall"]).boolValue;
        
        NSString *ground_type = (NSString *)[currentIslandDict objectForKey:@"ground"];
        
        if (ground_type == NULL || [ground_type isEqualToString:@"open"]) {
            currentIsland = [LineIsland init_pt1:start pt2:end height:height ndir:ndir can_land:can_land];
        } else if ([ground_type isEqualToString:@"cave"]) {
            currentIsland = [CaveLineIsland init_pt1:start pt2:end height:height ndir:ndir can_land:can_land];
        } else if ([ground_type isEqualToString:@"bridge"]) {
            currentIsland = [BridgeIsland init_pt1:start pt2:end height:height ndir:ndir can_land:can_land];
        } else if ([ground_type isEqualToString:@"lab"]) {
            currentIsland = [LabLineIsland init_pt1:start pt2:end height:height ndir:ndir can_land:can_land];
        } else {
            NSLog(@"unrecognized ground type!!");
            continue;
        }
		[map.n_islands addObject:currentIsland];
	}
    
    
    NSArray *coins_array = [j_map_data objectForKey:@"objects"];
    
    for(int i = 0; i < [coins_array count]; i++){
        NSDictionary *j_object = (NSDictionary *)[coins_array objectAtIndex:i];
        NSString *type = (NSString *)[j_object objectForKey:@"type"];
        
        if([type isEqualToString:@"dogbone"]){
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            int bid = ((NSString*)[j_object  objectForKey:@"bid"]).intValue;
            [map.game_objects addObject:[DogBone init_x:x y:y bid:bid]];
            
            
        } else if ([type isEqualToString:@"dogcape"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[DogCape init_x:x y:y]];
            
        } else if ([type isEqualToString:@"dogrocket"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[DogRocket init_x:x y:y]];
            
        } else if ([type isEqualToString:@"ground_detail"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            int type = ((NSString*)[j_object  objectForKey:@"img"]).intValue;
            [map.game_objects addObject:[GroundDetail init_x:x y:y type:type islands:map.n_islands]];
            
        } else if ([type isEqualToString:@"checkpoint"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[CheckPoint init_x:x y:y]];
            
        } else if ([type isEqualToString:@"game_end"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[GameEndArea init_x:x y:y]];
            
        } else if ([type isEqualToString:@"spike"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[Spike init_x:x y:y islands:map.n_islands]];
            
        } else if ([type isEqualToString:@"water"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");;
            float hei = getflt(j_object, @"height");;
            [map.game_objects addObject:[Water init_x:x y:y width:width height:hei]];
            
        } else if ([type isEqualToString:@"jumppad"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            
            NSDictionary* dir_obj = [j_object objectForKey:@"dir"];
            float dir_x = getflt(dir_obj, @"x");;
            float dir_y = getflt(dir_obj, @"y");;
            Vec3D* dir_vec = [Vec3D init_x:dir_x y:dir_y z:0];
            [map.game_objects addObject:[JumpPad init_x:x y:y dirvec:dir_vec]];
            
            [dir_vec dealloc];
            
        } else if ([type isEqualToString:@"birdflock"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[BirdFlock init_x:x y:y]];
            
        } else if([type isEqualToString:@"blocker"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");;
            float height = getflt(j_object, @"height");;
            
            [map.game_objects addObject:[Blocker init_x:x y:y width:width height:height]];
            
        } else if([type isEqualToString:@"speedup"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            
            NSDictionary* dir_obj = [j_object objectForKey:@"dir"];
            float dir_x = getflt(dir_obj, @"x");;
            float dir_y = getflt(dir_obj, @"y");;
            Vec3D* dir_vec = [Vec3D init_x:dir_x y:dir_y z:0];
            [map.game_objects addObject:[SpeedUp init_x:x y:y dirvec:dir_vec]];
            
            [dir_vec dealloc];
            
        } else if ([type isEqualToString:@"cavewall"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");;
            float hei = getflt(j_object, @"height");;
            [map.game_objects addObject:[CaveWall init_x:x y:y width:width height:hei]];
            
        } else if ([type isEqualToString:@"island_fill"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");;
            float hei = getflt(j_object, @"height");;
            [map.game_objects addObject:[IslandFill init_x:x y:y width:width height:hei]];
            
        } else if ([type isEqualToString:@"breakable_wall"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");;
            float y2 = getflt(j_object, @"y2");;
            [map.game_objects addObject:[BreakableWall init_x:x y:y x2:x2 y2:y2]];
            
        } else if ([type isEqualToString:@"spikevine"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");;
            float y2 = getflt(j_object, @"y2");;
            [map.game_objects addObject:[SpikeVine init_x:x y:y x2:x2 y2:y2]];
            
        } else if ([type isEqualToString:@"camera_area"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");;
            float hei = getflt(j_object, @"height");;
            
            NSDictionary* dir_obj = [j_object objectForKey:@"camera"];
            float cx = getflt(dir_obj, @"x");
            float cy = getflt(dir_obj, @"y");
            float cz = getflt(dir_obj, @"z");
            struct CameraZoom n = [Common cons_normalcoord_camera_zoom_x:cx y:cy z:cz];
            [map.game_objects addObject:[CameraArea init_x:x y:y wid:width hei:hei zoom:n]];
            
        } else if ([type isEqualToString:@"swingvine"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");;
            float y2 = getflt(j_object, @"y2");;
            float len = sqrtf(powf(x2-x, 2)+powf(y2-y, 2));
            [map.game_objects addObject:[SwingVine init_x:x y:y len:len]];
            
        } else if ([type isEqualToString:@"robotminion"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[MinionRobot cons_x:x y:y]];
            
        } else if ([type isEqualToString:@"launcherrobot"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            NSDictionary* dir_obj = [j_object objectForKey:@"dir"];
            float dir_x = getflt(dir_obj, @"x");;
            float dir_y = getflt(dir_obj, @"y");;
            Vec3D* dir_vec = [Vec3D init_x:dir_x y:dir_y z:0];
            
            [map.game_objects addObject:[LauncherRobot cons_x:x y:y dir:dir_vec]];
            [dir_vec dealloc];
            
        } else if ([type isEqualToString:@"labwall"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");;
            float hei = getflt(j_object, @"height");;
            [map.game_objects addObject:[FadeOutLabWall init_x:x y:y width:width height:hei]];
            
        } else if ([type isEqualToString:@"copter"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[CopterRobotLoader cons_x:x y:y]];
            
        } else if ([type isEqualToString:@"electricwall"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");;
            float y2 = getflt(j_object, @"y2");;
            [map.game_objects addObject:[ElectricWall init_x:x y:y x2:x2 y2:y2]];
            
        } else if ([type isEqualToString:@"labentrance"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[LabEntrance cons_pt:ccp(x,y)]];
            
        } else if ([type isEqualToString:@"labexit"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[LabExit cons_pt:ccp(x,y)]];
        
        } else if ([type isEqualToString:@"enemyalert"]) {
            [map.game_objects addObject:[EnemyAlert cons_p1:ccp(getflt(j_object, @"x"),getflt(j_object, @"y"))
                                                       size:ccp(getflt(j_object, @"width"),getflt(j_object, @"height"))]];
        
        } else {
            NSLog(@"item read error");
            continue;
        }
    }

    //NSLog(@"finish parse");
    return map;
}

float getflt(NSDictionary* j_object,NSString* key) {
    return ((NSString*)[j_object objectForKey:key]).floatValue;
}

@end
