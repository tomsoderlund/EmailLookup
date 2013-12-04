//
//  AppDelegate.m
//  EmailLookup
//
//  Created by Tom Söderlund on 2012-08-08.
//  Copyright (c) 2012 Tom Söderlund. All rights reserved.
//

#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>

@implementation AppDelegate

@synthesize nameField;
@synthesize outputField;
@synthesize lookupButton;
@synthesize searchModeRadioGroup;
@synthesize outputFormatRadioGroup;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (NSString*)formatOutputString:(NSString*)resultString withAddress:(ABPerson*)address inFormat:(long)formatMode {
    
    NSString *newLine;
    
    // 2) Output
    switch ([[outputFormatRadioGroup selectedCell] tag]) {
        case kOutputFormatEmail: {
            NSString *firstName = [address valueForProperty:kABFirstNameProperty];
            NSString *lastName = [address valueForProperty:kABLastNameProperty];
            ABMultiValue *emailMultiValue = [address valueForProperty:kABEmailProperty];
            NSString *email = [emailMultiValue valueAtIndex:0];
            
            if (email)
                newLine = [NSString stringWithFormat:@"%@ %@ <%@>", firstName, lastName, email];
            else
                newLine = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            break;
        }
            
        case kOutputFormatFull: {
            ABMultiValue *emailMultiValue = [address valueForProperty:kABEmailProperty];
            NSString *email = [emailMultiValue valueAtIndex:0];
            ABMultiValue *phoneMultiValue = [address valueForProperty:kABPhoneProperty];
            NSString *phone = [phoneMultiValue valueAtIndex:0];
            ABMultiValue *urlMultiValue = [address valueForProperty:kABURLsProperty];
            NSString *url = [urlMultiValue valueAtIndex:0];
            ABMultiValue *addressMultiValue = [address valueForProperty:kABAddressProperty];
            NSDictionary *cityAddressDictionary = [addressMultiValue valueAtIndex:0];
            NSString *city = [cityAddressDictionary objectForKey:@"City"];
            NSString *country = [cityAddressDictionary objectForKey:@"Country"];
            //NSString *cityAddress = [NSString stringWithFormat:@"%@, %@", [cityAddressDictionary objectForKey:@"City"], [cityAddressDictionary objectForKey:@"Country"]];
            //NSDate *lastModiDate = (NSDate*) ABRecordCopyValue(address, kABPersonModificationDateProperty);
            NSDate *lastModiDate = (NSDate*) [address valueForProperty:kABModificationDateProperty];
            
            newLine = [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@;%@;%@;%@;%@",
                       [address valueForProperty:kABOrganizationProperty],
                       [address valueForProperty:kABFirstNameProperty],
                       [address valueForProperty:kABLastNameProperty],
                       [address valueForProperty:kABJobTitleProperty],
                       email,
                       phone,
                       url,
                       city,
                       country,
                       lastModiDate
                       ];
            newLine = [newLine stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            newLine = [newLine stringByReplacingOccurrencesOfString:@";, " withString:@";"];
            
            //NSLog(@"Found: %@", newLine);
            break;
        }
    }
    
    return newLine;
}

- (IBAction)lookupContacts:(id)sender {
    ABAddressBook *AB = [ABAddressBook sharedAddressBook];
    NSString *resultString = @"";
    NSArray *nameArray;
    
    [lookupButton setEnabled:NO];
    
    // 1) Search
    switch ([[searchModeRadioGroup selectedCell] tag]) {
        case kSearchModePerson: {
            // Split people
            nameArray = [nameField.stringValue componentsSeparatedByString:@"\n"];
            for (NSString *fullName in nameArray) {
                // Split names
                NSMutableArray *personNameArray = (NSMutableArray*)[fullName componentsSeparatedByString: @" "];
                NSString *firstName = [personNameArray objectAtIndex:0];
                NSString *lastName;
                if (personNameArray.count > 1) {
                    // Last name too
                    [personNameArray removeObjectAtIndex:0];
                    lastName = [personNameArray componentsJoinedByString: @" "];
                }
                else {
                    lastName = @"";
                }
                //NSLog(@"Names: '%@', '%@'", firstName, lastName);
                
                // Search Address Book
                ABSearchElement *searchFirstName = [ABPerson searchElementForProperty:kABFirstNameProperty label:nil key:nil value:firstName comparison:kABEqualCaseInsensitive];
                ABSearchElement *searchLastName = [ABPerson searchElementForProperty:kABLastNameProperty label:nil key:nil value:lastName comparison:kABEqualCaseInsensitive];
                ABSearchElement *searchFullName = [ABSearchElement searchElementForConjunction:kABSearchAnd children:[NSArray arrayWithObjects:searchFirstName, searchLastName, nil]];
                NSArray *addressesFound = [AB recordsMatchingSearchElement:searchFullName];
                
                //NSLog(@"Found: %ld", addressesFound.count);
                /*
                 for (ABPerson *address in addressesFound) {
                 NSLog(@"  Names: '%@', '%@'", [address valueForProperty:kABFirstNameProperty], [address valueForProperty:kABLastNameProperty]);
                 }
                 */
                if (addressesFound.count > 0) {
                    ABPerson *address = [addressesFound objectAtIndex:0];
                    resultString = [NSString stringWithFormat:@"%@%@\n", resultString, [self formatOutputString:resultString withAddress:address inFormat:[[outputFormatRadioGroup selectedCell] tag]]];
                }
                
            }
            break;
        }
        case kSearchModeCompany: {
            // Split people
            nameArray = [nameField.stringValue componentsSeparatedByString:@"\n"];
            for (NSString *fullName in nameArray) {
                // Search Address Book
                NSLog(@"searchCompany: '%@'", fullName);
                ABSearchElement *searchCompany = [ABPerson searchElementForProperty:kABOrganizationProperty label:nil key:nil value:fullName comparison:kABContainsSubStringCaseInsensitive]; // comparison:kABEqualCaseInsensitive
                NSArray *addressesFound = [AB recordsMatchingSearchElement:searchCompany];
                
                NSLog(@"Found: %ld", addressesFound.count);
                for (ABPerson *address in addressesFound) {
                    resultString = [NSString stringWithFormat:@"%@%@\n", resultString, [self formatOutputString:resultString withAddress:address inFormat:[[outputFormatRadioGroup selectedCell] tag]]];
                }
            }
            break;
        }
        case kSearchModeAll: {
            // Search Address Book
            ABSearchElement *searchAll = [ABPerson searchElementForProperty:kABFirstNameProperty label:nil key:nil value:@"01234" comparison:kABNotEqual];
            NSArray *addressesFound = [AB recordsMatchingSearchElement:searchAll];
            
            NSLog(@"Found: %ld", addressesFound.count);
            for (ABPerson *address in addressesFound) {
                resultString = [NSString stringWithFormat:@"%@%@\n", resultString, [self formatOutputString:resultString withAddress:address inFormat:[[outputFormatRadioGroup selectedCell] tag]]];
            }
            break;
        }

    }
    
    // 2) Output
    switch ([[outputFormatRadioGroup selectedCell] tag]) {
        case kOutputFormatEmail:
            break;
        case kOutputFormatFull:
            break;
    }
    
    // Set text field
    [outputField setStringValue:resultString];
    
    [lookupButton setEnabled:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

@end