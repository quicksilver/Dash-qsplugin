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
		if (![[ds objectForKey:@"isEnabled"] boolValue]) {
			continue;
		}
		NSString *platform = [ds objectForKey:@"platform"];
		NSString *title = [ds objectForKey:@"docsetName"];
		NSString *path = [ds objectForKey:@"docsetPath"];
		NSString *ident = [NSString stringWithFormat:@"QSDashDocset:%@", platform];
		newObject = [QSObject makeObjectWithIdentifier:ident];
		[newObject setLabel:title];
		[newObject setName:[NSString stringWithFormat:@"%@ DocSet", title]];
		[newObject setObject:platform forType:QSDashDocsetType];
		[newObject setPrimaryType:QSDashDocsetType];
		[newObject setObject:path forMeta:@"docsetPath"];
		[objects addObject:newObject];
	}
	return objects;
}

// Object Handler Methods

- (BOOL)loadChildrenForObject:(QSObject *)object
{
	NSMutableArray *children = [[QSLib scoredArrayForType:QSDashDocsetType] mutableCopy];
	[object setChildren:children];
	return YES;
}

- (void)setQuickIconForObject:(QSObject *)object
{
	NSImage *docsetIcon = [[NSWorkspace sharedWorkspace] iconForFileType:@"com.apple.xcode.docset"];
	[object setIcon:docsetIcon];
}

- (BOOL)loadIconForObject:(QSObject *)object
{
	NSString *platform = [object objectForType:QSDashDocsetType];
	NSBundle *dashBundle = [NSBundle bundleWithIdentifier:@"com.kapeli.dashdoc"];
	NSImage *icon = [QSResourceManager imageNamed:platform inBundle:dashBundle];
	if (!icon) {
		// TODO: check inside the DocSet
	}
	[object setIcon:icon];
	return YES;
}
@end
