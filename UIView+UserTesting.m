//
//  UserTesting.m
//  wsabi
//
//  Created by Matt Aronoff on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIView+UserTesting.h"

#define USER_TESTING_PREF @"user-testing-file"

@implementation UIView (UserTesting)

+(BOOL) startNewUserTestingFile
{    
    //This creates a new CSV-based, UTF-8
    
    //get a reference to the documents directory
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //store the new filename as a user preference, overwriting the existing entry if necessary
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"'UserTestLog_'yyyy-MM-dd_HH:mm:ss'.txt'"];
    NSDate *now = [NSDate date];
    
    NSString *filename = [documentsDir stringByAppendingPathComponent:[formatter stringFromDate:now]];

    //Create the file (inserting header information), then store its path in the user preferences.
    NSError *err = nil;
    if(![@"Timestamp,Class,xPosition,yPosition\n" writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:&err])
    {
        NSLog(@"Couldn't create a new user testing log at %@, error was: %@",filename, [err description]);
        return NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:filename forKey:USER_TESTING_PREF];
    return YES;
 }

+(void) appendUserTestingStringToCurrentLog:(NSString*)theString
{
    //Tag the string with the current time.
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss zzz,"];
    NSDate *now = [NSDate date];
    NSString *timedString = [[formatter stringFromDate:now] stringByAppendingString:theString];
    
    NSData *dataToWrite = [timedString dataUsingEncoding: NSUTF8StringEncoding];

    //Get the path of the current log file
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    NSString *logFilePath = [defaults objectForKey:USER_TESTING_PREF];
    
    //If there is no stored file, create one.
    if (!logFilePath) {
        BOOL createSuccess = [UIView startNewUserTestingFile];
        if (!createSuccess) {
            NSLog(@"UIView::appendUserTestingStringToCurrentLog: No file to append to, and starting a new file was unsuccessful.");
            return;
        }
    }
    
    //write to it.
    NSFileHandle* outputFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    [outputFile seekToEndOfFile];
    [outputFile writeData:dataToWrite];
}

//Implement a logging listener to every touch event passed through this window

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *aTouch = [touches anyObject];
    [super touchesBegan:touches withEvent:event];

    NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f\n", 
                           [self class], 
                           [aTouch locationInView:self.window].x, 
                           [aTouch locationInView:self.window].y];
    
    //NSLog(@"%@: Got a touch at x: %f and y:%f", [self class], [aTouch locationInView:self.window].x, [aTouch locationInView:self.window].y);
    [UIView appendUserTestingStringToCurrentLog:logString];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    [super touchesMoved:touches withEvent:event];
    
    NSString *logString = [NSString stringWithFormat:@"%@,%1.0f,%1.0f\n", 
                           [self class], 
                           [aTouch locationInView:self.window].x, 
                           [aTouch locationInView:self.window].y];
    
    //NSLog(@"%@: Got a drag at x: %f and y:%f", [self class], [aTouch locationInView:self.window].x, [aTouch locationInView:self.window].y);
    [UIView appendUserTestingStringToCurrentLog:logString];


}

@end
