//
//  QSDashPluginSource.m
//  QSDashPlugin
//
//  Created by Rob McBroom on 2016/02/07.
//

#import "QSDashPluginSource.h"
#import "QSDashPlugin.h"

@implementation QSDashPluginSource

- (instancetype)init
{
	self = [super init];
	if (self) {
		NSFileManager *dfm = [NSFileManager defaultManager];
		NSString *pathFormat = @"~/Library/Preferences/%@.plist";
		self.dashBundleID = @"com.kapeli.dashdoc";
		self.dashPrefPath = [[NSString stringWithFormat:pathFormat, self.dashBundleID] stringByStandardizingPath];
		if (![dfm fileExistsAtPath:self.dashPrefPath isDirectory:nil]) {
			self.dashBundleID = @"com.kapeli.dash";
			self.dashPrefPath = [[NSString stringWithFormat:pathFormat, self.dashBundleID] stringByStandardizingPath];
		}
	}
	return self;
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry
{
	NSFileManager *manager = [NSFileManager defaultManager];
	if (![manager fileExistsAtPath:[self dashPrefPath] isDirectory:NULL]) {
		return YES;
	}
	NSDate *modDate = [[manager attributesOfItemAtPath:[self dashPrefPath] error:NULL] fileModificationDate];
	return ([modDate compare:indexDate] == NSOrderedAscending);
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry
{
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
	QSObject *newObject;

	NSDictionary *dashPrefs = [NSDictionary dictionaryWithContentsOfFile:[self dashPrefPath]];
	NSArray *docsets = [dashPrefs objectForKey:@"docsets"];
	for (NSDictionary *ds in docsets) {
		NSString *platform = [ds objectForKey:@"platform"];
		if (![[ds objectForKey:@"isEnabled"] boolValue]) {
			continue;
		}
		NSString *title = [ds objectForKey:@"docsetName"];
		// try user-defined keyword
		NSString *keyword = [[ds objectForKey:@"keyword"] stringByReplacingOccurrencesOfString:@":" withString:@""];
		if (![keyword length]) {
			// try internally hard-coded keywords
			keyword = [self keywordForDocset:title];
		}
		if (![keyword length]) {
			// try default keyword
			keyword = [ds objectForKey:@"suggestedKeyword"];
		}
		if (![keyword length]) {
			// use platform
			keyword = platform;
		}
		NSString *path = [ds objectForKey:@"docsetPath"];
		NSString *ident = [NSString stringWithFormat:@"QSDashDocset:%@", title];
		newObject = [QSObject makeObjectWithIdentifier:ident];
		[newObject setLabel:title];
		[newObject setName:[NSString stringWithFormat:@"%@ DocSet", title]];
		[newObject setObject:keyword forType:QSDashDocsetType];
		[newObject setPrimaryType:QSDashDocsetType];
		// metadata for icon loading
		[newObject setObject:path forMeta:@"docsetPath"];
		[newObject setObject:platform forMeta:@"platform"];
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
	NSString *platform = [object objectForMeta:@"platform"];
	NSBundle *dashBundle = [NSBundle bundleWithIdentifier:self.dashBundleID];
	NSImage *icon = [QSResourceManager imageNamed:platform inBundle:dashBundle];
	if (!icon) {
		NSString *docsetPath = [object objectForMeta:@"docsetPath"];
		NSArray *iconNames = @[@"icon@2x.png", @"icon.png", @"icon.tiff"];
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *iconPath;
		for (NSString *name in iconNames) {
			iconPath = [docsetPath stringByAppendingPathComponent:name];
			if ([fm fileExistsAtPath:iconPath]) {
				icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
				break;
			}
		}
	}
	if (!icon) {
		return NO;
	}
	[object setIcon:icon];
	return YES;
}

#pragma mark - Helpers

- (NSString *)keywordForDocset:(NSString *)docsetName
{
	// these are hard-coded inside Dash
	// list provided by Kapeli
	if([docsetName hasPrefix:@"Python 2"])
	{
		return @"python2";
	}
	else if([docsetName hasPrefix:@"Python 3"])
	{
		return @"python3";
	}
	else if([docsetName isEqualToString:@"Java SE7"])
	{
		return @"java7";
	}
	else if([docsetName isEqualToString:@"Java SE6"])
	{
		return @"java6";
	}
	else if([docsetName isEqualToString:@"Java SE8"])
	{
		return @"java8";
	}
	else if([docsetName hasPrefix:@"Qt 5"])
	{
		return @"qt5";
	}
	else if([docsetName hasPrefix:@"Qt 4"])
	{
		return @"qt4";
	}
	else if([docsetName hasPrefix:@"Cocos3D"])
	{
		return @"cocos3d";
	}
	return nil;
}
@end
