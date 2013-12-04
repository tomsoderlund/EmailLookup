//
//  AppDelegate.h
//  EmailLookup
//
//  Created by Tom Söderlund on 2012-08-08.
//  Copyright (c) 2012 Tom Söderlund. All rights reserved.
//

#define  kSearchModePerson      0
#define  kSearchModeCompany     1
#define  kSearchModeAll         2
#define  kOutputFormatEmail     0
#define  kOutputFormatFull      1

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *nameField;
@property (weak) IBOutlet NSTextField *outputField;
//@property (weak) IBOutlet NSTextField *labelField;
@property (weak) IBOutlet NSButton *lookupButton;
@property (weak) IBOutlet NSMatrix *searchModeRadioGroup;
@property (weak) IBOutlet NSMatrix *outputFormatRadioGroup;

- (IBAction)lookupContacts:(id)sender;

@end
