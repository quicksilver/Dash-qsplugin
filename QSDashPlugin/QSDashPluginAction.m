//
//  QSDashPluginAction.m
//  QSDashPlugin
//
//  Created by Rob McBroom on 2016/02/07.
//

#import "QSDashPluginAction.h"
#import "QSDashPlugin.h"

@implementation QSDashPluginActionProvider

- (QSObject *)searchDocSet:(QSObject *)dObject query:(QSObject *)iObject
{
	NSString *dashURLformat = @"dash-plugin://keys=%@&query=%@";
	NSArray *docsetObjects = [dObject splitObjects];
	NSString *query = [[iObject stringValue] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
	NSArray *keywords = [docsetObjects arrayByEnumeratingArrayUsingBlock:^id(QSObject *ds) {
		return [ds objectForType:QSDashDocsetType];
	}];
	NSString *joined = [keywords componentsJoinedByString:@","];
	NSString *dashURLstr = [NSString stringWithFormat:dashURLformat, joined, query];
	NSURL *dashURL = [NSURL URLWithString:dashURLstr];
	if (dashURL) {
		[[NSWorkspace sharedWorkspace] openURL:dashURL];
	} else {
		NSLog(@"error with location: %@", dashURLstr);
	}
	return nil;
}

- (QSObject *)searchDash:(QSObject *)dObject
{
	NSString *dashURLformat = @"dash://%@";
	NSString *query = [[dObject stringValue] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
	NSString *dashURLstr = [NSString stringWithFormat:dashURLformat, query];
	NSURL *dashURL = [NSURL URLWithString:dashURLstr];
	if (dashURL) {
		[[NSWorkspace sharedWorkspace] openURL:dashURL];
	} else {
		NSLog(@"error with location: %@", dashURLstr);
	}
	return nil;
}

- (QSObject *)viewDocset:(QSObject *)dObject
{
	NSString *dashURLformat = @"dash-plugin://keys=%@";
	NSArray *docsetObjects = [dObject splitObjects];
	NSArray *keywords = [docsetObjects arrayByEnumeratingArrayUsingBlock:^id(QSObject *ds) {
		return [ds objectForType:QSDashDocsetType];
	}];
	NSString *joined = [keywords componentsJoinedByString:@","];
	NSString *dashURLstr = [NSString stringWithFormat:dashURLformat, joined];
	NSURL *dashURL = [NSURL URLWithString:dashURLstr];
	if (dashURL) {
		[[NSWorkspace sharedWorkspace] openURL:dashURL];
	} else {
		NSLog(@"error with location: %@", dashURLstr);
	}
	return nil;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject
{
	// sort DocSets by use frequency in the third pane
	if ([action isEqualToString:@"QSDashSearchReversed"]) {
		return [QSLib scoredArrayForType:QSDashDocsetType];
	}
	// present a text-entry box
	else if ([action isEqualToString:@"QSDashSearch"]) {
		NSString *searchString = [[NSPasteboard pasteboardWithName:NSFindPboard] stringForType:NSStringPboardType];
		return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:(searchString?searchString:@"")]];
	}
	return nil;
}
@end
