#import "MapLoader.h"

@implementation MapLoader

+(GameMap) load_map:(NSString *)map_file_name oftype:(NSString *) map_file_type{
    
    NSString *islandFilePath = [[NSBundle mainBundle] pathForResource:map_file_name ofType:map_file_type];
	NSString *islandInputStr = [[NSString alloc] initWithContentsOfFile : islandFilePath encoding:NSUTF8StringEncoding error:NULL];
	NSData *islandData  =  [islandInputStr dataUsingEncoding : NSUTF8StringEncoding];
    [islandInputStr dealloc];
    
    NSDictionary *j_map_data = [[CJSONDeserializer deserializer] deserializeAsDictionary:islandData error:NULL];
    
    NSArray *islandArray = [j_map_data objectForKey:(@"islands")];
	int islandsCount = [islandArray count];
	
    struct GameMap map;
    map.n_islands = [[NSMutableArray alloc] init];
    map.game_objects = [[NSMutableArray alloc] init];
    
    float start_x = ((NSString*)[j_map_data objectForKey:(@"start_x")]).floatValue;
	float start_y = ((NSString*)[j_map_data objectForKey:(@"start_y")]).floatValue;
    map.player_start_pt = ccp(start_x,start_y);
    NSLog(@"Player starting at (%f,%f)",start_x,start_y);
    
    int assert_links = ((NSString*)[j_map_data objectForKey:(@"assert_links")]).intValue;
    map.assert_links = assert_links;
    
	for(int i = 0; i < islandsCount; i++){
		NSDictionary *currentIslandDict = (NSDictionary *)[islandArray objectAtIndex:i];
		CGPoint start = ccp( ((NSString *)[currentIslandDict objectForKey:@"x1"]).floatValue
							,((NSString *)[currentIslandDict objectForKey:@"y1"]).floatValue );
		CGPoint end = ccp( ((NSString *)[currentIslandDict objectForKey:@"x2"]).floatValue
						  ,((NSString *)[currentIslandDict objectForKey:@"y2"]).floatValue );
		
        
        NSString *type = (NSString*)[currentIslandDict objectForKey:@"type"];
        
        Island *currentIsland;
        
		if ([type isEqualToString:@"line"]) {
            float height = ((NSString *)[currentIslandDict objectForKey:@"hei"]).floatValue;
            NSString *ndir_str = [currentIslandDict objectForKey:@"ndir"];
            float ndir = 0;
            if ([ndir_str isEqualToString:@"left"]) {
                ndir = 1;
            } else if ([ndir_str isEqualToString:@"right"]) {
                ndir = -1;
            }
            BOOL can_land = ((NSString *)[currentIslandDict objectForKey:@"can_fall"]).boolValue;
            currentIsland = [LineIsland init_pt1:start pt2:end height:height ndir:ndir can_land:can_land];
            
		} else {
            NSLog(@"line read error");
            continue;
        }
		[map.n_islands addObject:currentIsland];
	}
    
    
    NSArray *coins_array = [j_map_data objectForKey:@"objects"];
    
    for(int i = 0; i < [coins_array count]; i++){
        NSDictionary *j_object = (NSDictionary *)[coins_array objectAtIndex:i];
        NSString *type = (NSString *)[j_object objectForKey:@"type"];
        
        if([type isEqualToString:@"dogbone"]){
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            int bid = ((NSString*)[j_object  objectForKey:@"bid"]).intValue;
            [map.game_objects addObject:[DogBone init_x:x y:y bid:bid]];
            
            
        } else if ([type isEqualToString:@"dogcape"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            [map.game_objects addObject:[DogCape init_x:x y:y]];
            
        } else if ([type isEqualToString:@"dogrocket"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            [map.game_objects addObject:[DogRocket init_x:x y:y]];
            
        } else if ([type isEqualToString:@"ground_detail"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            int type = ((NSString*)[j_object  objectForKey:@"img"]).intValue;
            [map.game_objects addObject:[GroundDetail init_x:x y:y type:type]];
            
        } else if ([type isEqualToString:@"checkpoint"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            [map.game_objects addObject:[CheckPoint init_x:x y:y]];
            
        } else if ([type isEqualToString:@"game_end"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            [map.game_objects addObject:[GameEndArea init_x:x y:y]];
            
        } else if ([type isEqualToString:@"spike"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            [map.game_objects addObject:[Spike init_x:x y:y islands:map.n_islands]];
            
        } else if ([type isEqualToString:@"water"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            float width = ((NSString*)[j_object  objectForKey:@"width"]).floatValue;
            float hei = ((NSString*)[j_object  objectForKey:@"height"]).floatValue;
            [map.game_objects addObject:[Water init_x:x y:y width:width height:hei]];
            
        } else if ([type isEqualToString:@"jumppad"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            [map.game_objects addObject:[JumpPad init_x:x y:y islands:map.n_islands]];
            
        } else if ([type isEqualToString:@"birdflock"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            [map.game_objects addObject:[BirdFlock init_x:x y:y]];
            
        } else if([type isEqualToString:@"blocker"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            float width = ((NSString*)[j_object  objectForKey:@"width"]).floatValue;
            float height = ((NSString*)[j_object  objectForKey:@"height"]).floatValue;
            
            [map.game_objects addObject:[Blocker init_x:x y:y width:width height:height]];
            
        } else if([type isEqualToString:@"speedup"]) {
            float x = ((NSString*)[j_object  objectForKey:@"x"]).floatValue;
            float y = ((NSString*)[j_object  objectForKey:@"y"]).floatValue;
            
            [map.game_objects addObject:[SpeedUp init_x:x y:y islands:map.n_islands]];
            
        } else {
            NSLog(@"item read error");
            continue;
        }
    }

    NSLog(@"finish parse");
    return map;
}

@end
