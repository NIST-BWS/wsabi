//
//  AppDelegate_iPad.h
//  Wsabi
//
//  Created by Matt Aronoff on 8/25/10.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <UIKit/UIKit.h>
#import "AppDelegate_Shared.h"

#import "WsabiMasterViewController_iPad.h"
#import "WsabiDetailViewController_iPad.h"

@interface AppDelegate_iPad : AppDelegate_Shared {
	WsabiMasterViewController_iPad *mainController;
	WsabiDetailViewController_iPad *detailController;
	UISplitViewController *splitViewController;
}

@property (nonatomic, retain) WsabiMasterViewController_iPad *mainController;
@property (nonatomic, retain) WsabiDetailViewController_iPad *detailController;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;

@end

