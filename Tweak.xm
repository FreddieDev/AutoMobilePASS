// Useful clang commands to ignore unused code, in case for testing I want to disable entire blocks
#pragma clang diagnostic ignored "-Wunused-const-variable"
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wunused-function"

#define kPreferencePath @"/var/mobile/Library/Preferences/com.cardboardface.automobilepass.prefs.plist" // Path for tweak preferences file


// Preferences
static NSMutableDictionary *settings;
static BOOL tweakEnabled;
static int myPin;

// Load preference updates into variables
static void refreshPrefs() {

	// Ensure preferences file has been created (if not load, load default preferences from ImLyingDownDamnitPrefs)
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.cardboardface.automobilepass.prefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("com.cardboardface.automobilepass.prefs"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		settings = nil;
	}
	if (!settings) {
		settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPreferencePath];
	}
	

	// Load settings into vars (loading a default value if no setting is set)
	tweakEnabled = [([settings objectForKey:@"Enabled"] ?: @(YES)) boolValue];
	myPin = [([settings objectForKey:@"MyPin"] ?: 0) intValue];
}
static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	refreshPrefs();
}



@interface PinTextField : UITextField
@end
%hook PinTextField
	-(void)setText:(NSString*)arg1 {
		%orig([NSString stringWithFormat:@"%i", myPin]);
	}
%end


// Constructor
%ctor {

	// Add observer to call PreferencesChangedCallback() when the preferences are updated
	CFNotificationCenterAddObserver(
			CFNotificationCenterGetDarwinNotifyCenter(),
			NULL,
			(CFNotificationCallback) PreferencesChangedCallback,
			CFSTR("com.cardboardface.automobilepass.prefs.prefschanged"),
			NULL,
			CFNotificationSuspensionBehaviorCoalesce);

	refreshPrefs(); // Load preferences

	%init; // Initializes ungrouped hooks
}