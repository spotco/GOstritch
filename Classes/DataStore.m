#import "DataStore.h"

@implementation DataStore

static NSUserDefaults* store;

+(void)init {
    store = [NSUserDefaults standardUserDefaults];
}

+(void)reset_all {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

+(BOOL)isset_key:(NSString*)key {
    return [store objectForKey:key] != NULL;
}

+(void)reset_key:(NSString*)key {
    [store setObject:nil forKey:key];
}

+(void)set_key:(NSString*)key int_value:(int)val {
    [store setInteger:val forKey:key];
    [store synchronize];
}

+(int)get_int_for_key:(NSString*)key {
    return [store integerForKey:key];
}

+(void)set_key:(NSString*)key flt_value:(float)val {
    [store setFloat:val forKey:key];
    [store synchronize];
}

+(float)get_flt_for_key:(NSString*)key {
    return [store floatForKey:key];
}

+(void)set_key:(NSString*)key str_value:(NSString*)val {
    [store setObject:val forKey:key];
    [store synchronize];
}

+(NSString*)get_str_for_key:(NSString*)key {
    return [store stringForKey:key];
}


@end
