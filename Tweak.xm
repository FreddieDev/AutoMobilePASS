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





// Redefine UITableView to expose _gestureRecognizers
@interface PrivUITableView : UITableView
	-(NSMutableArray *) _gestureRecognizers;
@end



@interface TokenListViewController : UIViewController
	-(UILabel *) mTLvcUiAppTitle; // Main menu title
	-(PrivUITableView *) mTableView; // Main menu's list of tokens

	-(void)tapSel:(UITapGestureRecognizer*)sender; // Taps a token in the main menu tokens list view
@end


%hook TokenListViewController
	-(void)viewDidAppear:(bool)animated {
		%orig;

		// Change title to show tweak is working
		[[self mTLvcUiAppTitle] setText:@"MobilePass [AUTOMATED]"];

		[NSTimer scheduledTimerWithTimeInterval:0.9
				target:self
				selector:@selector(autoClickFirstEntry:)
				userInfo:nil
				repeats:NO];
	}

	%new
	-(void)autoClickFirstEntry:(NSTimer *)timer {
		// tapSel takes a gesture recognizer (which sits on UITableView)
		// It's likely it calculates the cell that was tapped by the location of the touch
		// Passing nil probably makes it use (0, 0) which automatically selects the top entry
		[self tapSel:nil];
	}
%end


// Auto-fill passcode
// Works by overriding setText which is used to clear the passcode text field
@interface PinTextField : UITextField
@end
%hook PinTextField
	-(void)setText:(NSString*)arg1 {
		%orig([NSString stringWithFormat:@"%i", myPin]);
	}
%end

// Skip passcode page
@interface PinPolicyPortalUrlViewController : UIViewController
	-(void)onClickContinue:(id)arg1;
@end
%hook PinPolicyPortalUrlViewController
	-(void)viewDidAppear:(bool)animated {
		%orig; // Run original handler

		[NSTimer scheduledTimerWithTimeInterval:0.05
				target:self
				selector:@selector(autoContinue:)
				userInfo:nil
				repeats:NO];
	}

	%new
	-(void)autoContinue:(NSTimer *)timer {
		[self onClickContinue:nil]; // Fire continue button handler
	}
%end




// Constructor
%ctor {

	// Load preferences
	refreshPrefs();

	// Stop loading if tweak is disabled
	if (!tweakEnabled) return;

	// Initializes ungrouped hooks
	%init;
}