#import "FileCache.h"

#define PLIST @"plist"

@implementation FileCache

static NSMutableDictionary* files;

+(CGRect)get_cgrect_from_plist:(NSString*)file idname:(NSString*)idname {
    if (files == NULL) {
        files = [[NSMutableDictionary alloc] init];
    }
    if (![files objectForKey:file]) {
        [files setValue:[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:file ofType:PLIST]]
                 forKey:file];
        
        if ([files objectForKey:file] == NULL) {
            NSLog(@"FileCache::FILE NOT FOUND:%@",file);
        }
    }
    NSDictionary *tar = [files objectForKey:file];
    return [Common ssrect_from_dict:tar tar:idname];
}

@end
