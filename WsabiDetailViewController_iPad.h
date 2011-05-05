//
//  WsabiDetailViewController_iPad.h
//  Wsabi
//
//  Created by Matt Aronoff on 10/20/10.
//
/*
 This software was developed at the National Institute of Standards and Technology by employees of the Federal Government
 in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not 
 subject to copyright protection and is in the public domain. Wsabi is an experimental system. NIST assumes no responsibility 
 whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or 
 any other characteristic. We would appreciate acknowledgement if the software is used.
 */


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>

#import "UIImage+NBCLExtras.h"
#import "ColorablePageControl.h"

#import "NBCLSensorLink.h"
#import "NBCLInternalCameraSensorLink.h"

#import "WSBDResult.h"

#import "WsabiDeviceView_iPad.h"
#import "WsabiCollectionHeaderView.h"
#import "WsabiCollectionCell.h"

#import "constants.h"
#import "PagingInsetScrollView.h"

#import "Workflow.h"
#import "Workflow+DeepCopying.h"
#import "Capturer.h"
#import "Sensor.h"

#import "BiometricCollection.h"
#import "BiometricData.h"

#import "NBCLSensorRawOutputController.h"

#import "NBCLPhotoBrowserController.h"
#import "NBCLPhoto.h"
#import "NBCLPhotoSource.h"

@class WsabiMasterViewController_iPad;

@interface WsabiDetailViewController_iPad : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, 
																UIScrollViewDelegate, WsabiCollectionDelegate,
                                                                WsabiDeviceViewDelegate, NBCLSensorLinkDelegate,
															UITableViewDataSource, UITableViewDelegate, ColorablePageControlDelegate,
                                                             AVCamDemoCaptureManagerDelegate> 
{

	UIPopoverController *popoverController;
    UIPopoverController *bugPopoverController;
    UIToolbar *toolbar;
	UIBarButtonItem *titleToolbarItem;
    UIBarButtonItem *rootMenuToolbarItem;
    UIBarButtonItem *bugToolbarItem;
    
	WsabiMasterViewController_iPad *rootViewController;

	
	PagingInsetScrollView *capturerScroll;
	ColorablePageControl *capturerPageControl;
	//ScrollViewOverlay *capturerPagingOverlay;
	
	UITableView *collectionsTable;
    UIImageView *collectionsDropShadowTop;
    UIImageView *collectionsDropShadowBottom;
    
	//Core data...data.
	Workflow *workflow;
    BiometricCollection *activeCollection;
    
	NSArray *sortedCollections;
    
    //An array of live connections to sensors.
    NSMutableArray *sensorLinks;
    
    //Direct camera preview stuff.
    AVCamDemoCaptureManager *_captureManager;
    AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;

    //TESTING ONLY: An array of our received WSBD Results, which may be emptied if we get a memory warning.
    NSMutableArray *wsbdResultCache;
    NSMutableArray *wsbdOpNameCache;
}

-(WsabiDeviceView_iPad*) createDeviceViewForCapturer:(Capturer*)cap;

//If -1 is passed in as the new active position, the active collection's existing position is used.
-(void) makeCollectionActiveAtIndex:(int)index withActivePosition:(int)pos animated:(BOOL)isAnimated;

//TESTING ONLY: backgroundable methods for enabling/disabling camera preview.
-(void) enableLivePreviewForDeviceAtIndex:(NSNumber*)index;
-(void) disableLivePreviewForDeviceAtIndex:(NSNumber*)index;

-(void) updateCollections;

-(IBAction) addNewCollection:(id)sender;
-(IBAction) editCollectionTable:(id)sender;
-(IBAction) collectionHeaderTapped:(UITapGestureRecognizer*)recog;

- (void)configureCell:(WsabiCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (NBCLPhotoBrowserController*) presentFullscreenPhotoBrowser:(NSArray*)sortedPhotoPaths withItemAtIndex:(int)index;


//Multitasking methods
-(void) handleEnterBackground:(NSNotification*)notification;
-(void) handleEnterForeground:(NSNotification*)notification;

//toolbar action methods
-(IBAction) bugButtonPressed:(id)sender;

@property (nonatomic, retain) IBOutlet UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UIPopoverController *bugPopoverController;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, assign) IBOutlet WsabiMasterViewController_iPad *rootViewController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *titleToolbarItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *rootMenuToolbarItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *bugToolbarItem;

@property (nonatomic, retain) IBOutlet PagingInsetScrollView *capturerScroll;
@property (nonatomic, retain) IBOutlet ColorablePageControl *capturerPageControl;

@property (nonatomic, retain) IBOutlet UITableView *collectionsTable;
@property (nonatomic, retain) IBOutlet UIImageView *collectionsDropShadowTop;
@property (nonatomic, retain) IBOutlet UIImageView *collectionsDropShadowBottom;

//Core data...data.
@property (nonatomic, assign) Workflow *workflow;
@property (nonatomic, assign) BiometricCollection *activeCollection;
@property (nonatomic, retain) NSArray *sortedCollections;

//Connection stuff
@property (nonatomic, retain) NSMutableArray *sensorLinks;

//Direct camera preview stuff
@property (nonatomic,retain) AVCamDemoCaptureManager *captureManager;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

//Testing only
@property (nonatomic, retain) NSMutableArray *wsbdResultCache;
@property (nonatomic, retain) NSMutableArray *wsbdOpNameCache;

@end
