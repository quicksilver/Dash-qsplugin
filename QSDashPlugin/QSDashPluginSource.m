//
//  QSDashPluginSource.m
//  QSDashPlugin
//
//  Created by Rob McBroom on 2016/02/07.
//

#import "QSDashPluginSource.h"

@implementation QSQSDashPluginSource

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry
{
	return NO;
}

- (NSImage *)iconForEntry:(NSDictionary *)dict
{
	return nil;
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry
{
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
	QSObject *newObject;

	newObject = [QSObject objectWithName:@"TestObject"];
	[newObject setObject:@"" forType:QSQSDashPluginType];
	[newObject setPrimaryType:QSQSDashPluginType];
	[objects addObject:newObject];

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
