
#import "CPTheme.h"
#import "CPExceptions.h"
#import "CPDarkGradientTheme.h"
#import "CPPlainBlackTheme.h"
#import "CPPlainWhiteTheme.h"
#import "CPStocksTheme.h"

// theme names
NSString * const kCPDarkGradientTheme = @"Dark Gradients";
NSString * const kCPPlainWhiteTheme = @"Plain White";
NSString * const kCPPlainBlackTheme = @"Plain Black";
NSString * const kCPStocksTheme = @"Stocks";

@implementation CPTheme

+(CPTheme *)themeNamed:(NSString *)themeName
{
	static NSMutableDictionary *themes = nil;
	if ( themes == nil ) themes = [[NSMutableDictionary alloc] init];
	
	CPTheme *theme = [themes objectForKey:themeName];
	if ( theme ) return theme;
	
	static NSArray *themeClasses = nil;
	if ( themeClasses == nil ) {
		themeClasses = [[NSArray alloc] initWithObjects:[CPDarkGradientTheme class], [CPPlainBlackTheme class], [CPPlainWhiteTheme class],  [CPStocksTheme class], nil];
	}
	
	for ( Class themeClass in themeClasses ) {
		if ( [themeName isEqualToString:[themeClass name]] ) {
			theme = [[themeClass alloc] init];
			break;
		}
	}
	
	return [theme autorelease];
}

+(NSString *)name 
{
	return NSStringFromClass(self);
}

-(id)newGraph
{
	return nil;
}

@end
