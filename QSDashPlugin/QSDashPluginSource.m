//
//  QSDashPluginSource.m
//  QSDashPlugin
//
//  Created by Rob McBroom on 2016/02/07.
//

#import "QSDashPluginSource.h"
#import "QSDashPlugin.h"

static NSString *dashPrefPath = @"~/Library/Preferences/com.kapeli.dashdoc.plist";

@implementation QSDashPluginSource

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry
{
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *fullDashPrefPath = [dashPrefPath stringByStandardizingPath];
	if (![manager fileExistsAtPath:fullDashPrefPath isDirectory:NULL]) {
		return YES;
	}
	NSDate *modDate = [[manager attributesOfItemAtPath:fullDashPrefPath error:NULL] fileModificationDate];
	return ([modDate compare:indexDate] == NSOrderedAscending);
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry
{
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
	QSObject *newObject;

	NSString *fullDashPrefPath = [dashPrefPath stringByStandardizingPath];
	NSDictionary *dashPrefs = [NSDictionary dictionaryWithContentsOfFile:fullDashPrefPath];
	NSArray *docsets = [dashPrefs objectForKey:@"docsets"];
	for (NSDictionary *ds in docsets) {
		NSString *platform = [ds objectForKey:@"platform"];
		NSString *title = [ds objectForKey:@"docsetName"];
		NSString *path = [ds objectForKey:@"docsetPath"];
		NSString *ident = [NSString stringWithFormat:@"QSDashDocset:%@", platform];
		newObject = [QSObject makeObjectWithIdentifier:ident];
		[newObject setName:title];
		[newObject setObject:platform forType:QSDashDocsetType];
		[newObject setPrimaryType:QSDashDocsetType];
		[newObject setObject:path forMeta:@"docsetPath"];
		[objects addObject:newObject];
	}
	return objects;
}

// Object Handler Methods

/*
- (void)setQuickIconForObject:(QSObject *)object
{
	[object setIcon:nil]; // An icon that is either already in memory or easy to load
}

- (BOOL)loadIconForObject:(QSObject *)object
{
	return NO;
	id data = [object objectForType:QSQSDashPluginType];
	[object setIcon:nil];
	return YES;
}
*/
@end
