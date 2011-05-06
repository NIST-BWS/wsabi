//
//  NBCLSensorRawOutputController.h
//  Wsabi
//
//  Created by Matt Aronoff on 3/18/11.
//

/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <UIKit/UIKit.h>
#import "WSBDResult.h"

@protocol NBCLSensorRawOutputDelegate <NSObject>

-(void) clearWsbdResultCache;

@end

@interface NBCLSensorRawOutputController : UITableViewController {
    NSMutableArray *wsbdResults;
    NSMutableArray *wsbdOpNames;
    
    id<NBCLSensorRawOutputDelegate> delegate;
}

-(NSString*) getPrettyPrintedDetailStringForResult:(WSBDResult*)result;

-(IBAction) clearButtonPressed:(id)sender;

@property (nonatomic, retain) IBOutlet NSMutableArray *wsbdResults;
@property (nonatomic, retain) IBOutlet NSMutableArray *wsbdOpNames;

@property (nonatomic, assign) id<NBCLSensorRawOutputDelegate> delegate;
@end
