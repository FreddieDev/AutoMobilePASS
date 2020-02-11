#include "AutoMobilePASSListController.h"

@implementation AutoMobilePASSListController
	-(NSArray *)specifiers {
		if (!_specifiers) {
			_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
		}

		return _specifiers;
	}
	
	// Opens my Twitter page
	- (void)twitterlinkcardboard {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/face_cardboard"] options:@{} completionHandler:nil];
	}
@end