    //
//  WsabiDetailViewController_iPad.m
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


#import "WsabiDetailViewController_iPad.h"
#import "WsabiMasterViewController_iPad.h"

#define CAPTURER_SCROLL_INSETS UIEdgeInsetsMake(0, 176, 0, 176)

#define CAPTURER_WIDTH 366 //obviously, we don't want to hard code this.
#define CAPTURER_WIDTH_OFFSET 50 //obviously, we don't want to hard code this.

#define CAPTURER_TAG_OFFSET 1000 //the starting view tag number for capturers.


@interface WsabiDetailViewController_iPad ()
- (void)configureView;
@end

@implementation WsabiDetailViewController_iPad
@synthesize toolbar, titleToolbarItem, popoverController, bugPopoverController, rootViewController, rootMenuToolbarItem; 
@synthesize newLogFileToolbarItem, bugToolbarItem;
@synthesize capturerScroll, capturerPageControl;//, capturerPagingOverlay;
@synthesize collectionsTable, collectionsDropShadowTop, collectionsDropShadowBottom, sortedCollections;
@synthesize workflowLoadedOverlay;
@synthesize sensorLinks;
@synthesize captureVideoPreviewLayer = _captureVideoPreviewLayer;
@synthesize captureManager = _captureManager;

@synthesize wsbdResultCache, wsbdOpNameCache;

@synthesize workflow, activeCollection;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)configureView {
    // Update the user interface for the detail item.
   // detailDescriptionLabel.text = [[detailItem valueForKey:@"timeStamp"] description];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.navigationController setNavigationBarHidden:NO];

    //add shadows to the toolbar.
    self.toolbar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.toolbar.layer.shadowOpacity = 0.5;
    self.toolbar.layer.shadowOffset = CGSizeMake(1,2);
    self.toolbar.layer.shadowRadius = 8;
    self.toolbar.layer.shouldRasterize = YES;

    self.capturerPageControl.dotColorOtherPage = [UIColor grayColor];
    self.capturerPageControl.dotColorCurrentPage = [UIColor darkGrayColor];
    self.capturerPageControl.delegate = self;
        
    //configure the scroll view's response area.
    self.capturerScroll.responseInsets = CAPTURER_SCROLL_INSETS;
    
    //put some interior shadows "inside" the collections table.
    self.collectionsDropShadowTop.image = [[UIImage imageNamed:@"DropShadow_Linear"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    self.collectionsDropShadowBottom.image = [[UIImage imageNamed:@"DropShadow_Linear"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    self.collectionsDropShadowBottom.transform = CGAffineTransformMakeRotation(M_PI);
    
    //round the corners of the workflow loaded overlay.
    self.workflowLoadedOverlay.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.workflowLoadedOverlay.layer.shadowOpacity = 0.5;
    self.workflowLoadedOverlay.layer.shadowOffset = CGSizeMake(2,3);
    self.workflowLoadedOverlay.layer.shadowRadius = 10;
    self.workflowLoadedOverlay.layer.cornerRadius = 12;
    self.workflowLoadedOverlay.layer.shouldRasterize = YES;

    
    //TESTING ONLY: Set up the WSBD result cache
    self.wsbdResultCache = [[[NSMutableArray alloc] init] autorelease];
    self.wsbdOpNameCache = [[[NSMutableArray alloc] init] autorelease];

    //if this VC gets dumped because of a memory warning,
    //the master VC button is never recreated, even though the view controller itself is.
    //Attempt to add the button manually with a reference we got when the view was actually
    //first created.
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && self.rootMenuToolbarItem) {
        //NSLog(@"rootMenuToolbarItem is %@",self.rootMenuToolbarItem);
        [self splitViewController:self.splitViewController willHideViewController:self.rootViewController withBarButtonItem:self.rootMenuToolbarItem forPopoverController:self.popoverController];
    }
        
    //Register to receive notifications when we are backgrounded or restored from the background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
    //if we're supposed to autoload a workflow, do it.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"do_not_autoload_preference"]) {
        //Based heavily on http://stackoverflow.com/questions/516443/nsmanagedobjectid-into-nsdata/516735#516735
        
        NSManagedObjectContext *context = [(AppDelegate_Shared*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSPersistentStoreCoordinator *store = [(AppDelegate_Shared*)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];

        NSURL *uri = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentWorkflowObjectID"]];
        NSManagedObjectID *objID = [store managedObjectIDForURIRepresentation:uri];
        if (objID) {
            [self setWorkflow:(Workflow*)[context objectWithID:objID]];
        }
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    //if necessary, add or remove the newLog and bug buttons.
    NSMutableArray *tempItems = [self.toolbar.items mutableCopy];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bug_button_visible_preference"]) {
        if (![tempItems containsObject:self.newLogFileToolbarItem]) {
            [tempItems addObject:self.newLogFileToolbarItem];
        }
        if (![tempItems containsObject:self.bugToolbarItem]) {
            [tempItems addObject:self.bugToolbarItem];
        }
        [self.toolbar setItems:tempItems animated:NO];

    }
    else {
        [tempItems removeObject:self.newLogFileToolbarItem];
        [tempItems removeObject:self.bugToolbarItem];
        [self.toolbar setItems:tempItems animated:NO];
    }
    [tempItems release];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //recompute the bounds of the scroll view.
}

#pragma mark -
#pragma mark Property accessors
- (void) setWorkflow:(Workflow *)newWorkflow
{
	workflow = newWorkflow;

    //save the context here, before we start messing with things.
    [(AppDelegate_Shared*)[[UIApplication sharedApplication] delegate] saveContext];

    //store the new workflow's object ID (converted to an archivable object) in the preferences in case we want to reload it later.
    if (workflow) {
        NSURL *uri = [[workflow objectID] URIRepresentation];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:uri] forKey:@"currentWorkflowObjectID"];
    }
    else {
        //if we've set the workflow to nil, clear any stored workflow ID.
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentWorkflowObjectID"];
    }
    
	//clear the existing workflow scroll.
	for (UIView *v in self.capturerScroll.subviews) {
		if ([v isKindOfClass:[WsabiDeviceView_iPad class]]) {
			[v removeFromSuperview];
		}
	}
    
    //clear the existing active collection pointer.
    self.activeCollection = nil;
	
    if (workflow) {
        
        //set up the page control
        self.capturerPageControl.numberOfPages = [workflow.capturers count];
        
        self.titleToolbarItem.title = [NSString stringWithFormat:@"%@ (Step 1 of %d)", workflow.name, [workflow.capturers count]];
        
        //create (or empty out) the dictionary of sensor links to talk to the sensors associated with this workflow's capturers.
        if (!self.sensorLinks) {
            self.sensorLinks = [[[NSMutableArray alloc] init] autorelease];
        }
        else {
            //disconnect all links and remove the objects
            for (NBCLSensorLink *s in self.sensorLinks) {
                //retain this link long enough for the disconnect sequence to complete.
                //We'll release it at that point.
                [s retain];
                [s beginDisconnectSequence:s.currentSessionId shouldReleaseIfSuccessful:YES withSenderTag:-1];
            }
            [self.sensorLinks removeAllObjects];
        }

        //Sort the existing capturers for this workflow by their stated order.
        NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"positionInWorkflow" ascending:YES selector:@selector(compare:)] autorelease];
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
		
        NSArray *tempCapturers = [workflow.capturers sortedArrayUsingDescriptors:sortDescriptors];
        for (Capturer *c in tempCapturers) {
            //Check to see if we've already created a link to this capturer's sensor.
            //If not, do it.
            BOOL existingLink = NO;
            for (NBCLSensorLink *s in self.sensorLinks) {
                if (s.uri == c.sensor.uri) {
                    existingLink = YES;
                }
            }
            if (!existingLink) {

                //If this is one of our special local URIs, create a local sensor link.
                //If this is a sensor at a normal URI, create a normal sensor link.
                NBCLSensorLink *newLink = nil;
                
                if ([c.sensor.uri hasPrefix:kLocalCameraURLPrefix]) {
                    newLink = [[[NBCLInternalCameraSensorLink alloc] init] autorelease];
                }
                else {
                    newLink = [[[NBCLSensorLink alloc] init] autorelease];
                }
                    
                newLink.uri = c.sensor.uri;
                
                //set the link delegate so we get messages when stuff happens.
                newLink.delegate = self;
                
                //add the link to the array.
                [self.sensorLinks addObject:newLink];
                
                //attempt to connect this sensor, stealing the lock if necessary.
                BOOL sequenceStarted = [newLink beginConnectSequence:YES withSenderTag:-1];
                if (!sequenceStarted) {
                    NSLog(@"Couldn't start sensor connect sequence for sensor at %@",c.sensor.uri);
                }
            }
            
            WsabiDeviceView_iPad *dView = [self createDeviceViewForCapturer:c];
            
            //unless this is the active card, disable the capture button.
            dView.captureButton.enabled = ([tempCapturers indexOfObject:c] == [self.activeCollection.currentPosition intValue]);
            
            [self.capturerScroll addSubview:dView];
            
            //start with the reconnect options enabled.
            dView.reconnectOptionsEnabled = YES;
        }
        self.capturerScroll.contentSize = CGSizeMake([tempCapturers count] * (CAPTURER_WIDTH_OFFSET + CAPTURER_WIDTH), self.capturerScroll.bounds.size.height);
        self.capturerScroll.contentOffset = CGPointMake(0, 0);
        
        //if either 1) there aren't any collections, or 2) there aren't any active collections, add a new active collection.
        if (!workflow.collections || 
            [workflow.collections count] == 0 ||
            [[workflow.collections filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"isActive == YES"]] count] == 0
            ) {
            
            [self addNewCollection:nil];
        }
        else {
            //update the sorted list of collections for the table view.
            [self updateCollections];
            
        }
        
        //show the workflow loaded overlay to alert the user.
        [self showWorkflowLoadedOverlay:1.5];
        
        //update the active collection indicators (this reloads the data table as well).
        //Pass -1 as the position parameter so that we maintain the existing collection position.
        //FIXME: This is hugely inefficient, as we're setting and reading the activeCollection stuff about
        //17 times during this process.
        [self makeCollectionActiveAtIndex:[self.sortedCollections indexOfObject:self.activeCollection] withActivePosition:-1 animated:NO];

    }
    else
    {
        //we're using nil in place of a workflow.
        self.titleToolbarItem.title = @"No Workflow Loaded";
        [self updateCollections];
        [self.collectionsTable reloadData];
    }
    
}

#pragma mark - Multitasking methods
-(void) handleEnterBackground:(NSNotification*)notification
{
    //disconnect all links
    for (NBCLSensorLink *s in self.sensorLinks) {
        [s beginDisconnectSequence:s.currentSessionId shouldReleaseIfSuccessful:NO withSenderTag:-1];
    }

}

-(void) handleEnterForeground:(NSNotification*)notification
{
    //attempt to reconnect all links, stealing locks if necessary.
    for (NBCLSensorLink *s in self.sensorLinks) {
        [s beginConnectSequence:YES withSenderTag:-1];
    }
    

    //Fire viewWillAppear manually to make sure our toolbar buttons are as expected.
    [self viewWillAppear:YES];
}

#pragma mark - Toolbar action methods
-(IBAction) startNewUserTestingLog:(id)sender
{
    NSLog(@"Starting a new user testing log");
    
    if (![UIView startNewUserTestingFile]) {
        NSLog(@"Couldn't open a new user testing file.");
    }
}

-(IBAction) bugButtonPressed:(id)sender
{
    //if we're already showing this controller, just hide it and return.
    if (self.bugPopoverController && self.bugPopoverController.popoverVisible) {
        [self.bugPopoverController dismissPopoverAnimated:YES];
        return;
    }
    
    //make sure the main popover isn't visible.
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    NBCLSensorRawOutputController *bugController = [[[NBCLSensorRawOutputController alloc] initWithNibName:@"NBCLSensorRawOutputController" bundle:nil] autorelease];
    
    bugController.wsbdResults = self.wsbdResultCache;
    bugController.wsbdOpNames = self.wsbdOpNameCache;

    UINavigationController *tempNav = [[[UINavigationController alloc] initWithRootViewController:bugController] autorelease];
    
    if (!self.bugPopoverController) {
        self.bugPopoverController = [[[UIPopoverController alloc] initWithContentViewController:tempNav] autorelease];
    }
    else {
        self.bugPopoverController.contentViewController = tempNav;
    }
    
    self.bugPopoverController.popoverContentSize = CGSizeMake(320, 600);
    
    [self.bugPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(NBCLPhotoBrowserController*) presentFullscreenPhotoBrowser:(NSArray*)sortedPhotoPaths withItemAtIndex:(int)index
{
    //Loop through each photo ref and create a matching TTPhoto subclass,
    //then add that object to an array.
    NSMutableArray *photos = [[[NSMutableArray alloc] initWithCapacity:[sortedPhotoPaths count]] autorelease];
    
    for (int i = 0; i < [sortedPhotoPaths count]; i++) {
        NSString *photoPath = [sortedPhotoPaths objectAtIndex:i];
        
        //generate the URL format that Three20 likes.
        // NSString *ttpath = [[NSURL fileURLWithPath:ref.path] absoluteString];
        NSString *ttpath = [@"documents://" stringByAppendingString:[photoPath lastPathComponent]];
        NSLog(@"Trying to load photo at %@",ttpath);
        
        //Get the image's native size
        NSURL *imageFileURL = [NSURL fileURLWithPath:photoPath];
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageFileURL, NULL);
        if (imageSource == NULL) {
            // Error loading image
            NSLog(@"Tried to get image dimensions, but couldn't load image. Trouble ahead.");
        }
        
        CGFloat width = 0.0f, height = 0.0f;
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        if (imageProperties != NULL) {
            CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
            if (widthNum != NULL) {
                CFNumberGetValue(widthNum, kCFNumberFloatType, &width);
            }
            
            CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNum != NULL) {
                CFNumberGetValue(heightNum, kCFNumberFloatType, &height);
            }
            
            CFRelease(imageProperties);
        }

        
        //fit the image to the screen
//        if (width/height > height/width) {
//            //fit the width
//        }
        CGSize targetSize = CGSizeMake(width, height);
        
        NBCLPhoto *photo = [[[NBCLPhoto alloc] initWithCaption:[photoPath lastPathComponent]
                                                  urlLarge:ttpath
                                                  urlSmall:ttpath 
                                                  urlThumb:ttpath 
                                                      size:targetSize] autorelease];
        [photos addObject:photo];
    }
    
    //create the photo source for our TTPhotoViewController
    NBCLPhotoSource *source = [[[NBCLPhotoSource alloc] initWithTitle:@"Biometric Data" photos:photos] autorelease];
    
    NBCLPhotoBrowserController *photoController = [[[NBCLPhotoBrowserController alloc] initWithNibName:@"NBCLPhotoBrowserController" bundle:nil] autorelease];
    photoController.photoSource = source;
    photoController.centerPhoto = [source.photos objectAtIndex:index];
    [photoController updateView];
    
    UINavigationController *tempNav = [[[UINavigationController alloc] initWithRootViewController:photoController] autorelease];
    tempNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    //launch this as a modal view controller.
    [self presentModalViewController:tempNav animated:YES];
    
    return photoController;
    
}


#pragma mark - Sensor Link Delegate methods
-(void) sensorOperationDidFail:(int)opType fromLink:(id)link withError:(NSError*)error
{
    //update the device views based on the current link readiness.
    for (UIView *v in self.capturerScroll.subviews) {
        if ([v isKindOfClass:[WsabiDeviceView_iPad class]]) {
            WsabiDeviceView_iPad *currentDevice = (WsabiDeviceView_iPad*) v;
            NBCLSensorLink *currentLink = link;
            //If the URI matches, this is a matching capturer.
            if ([currentDevice.capturer.sensor.uri localizedCaseInsensitiveCompare:currentLink.uri] == NSOrderedSame) {
                if (opType == kOpTypeRegister) {
                    //Mark this as an unsuccessful reconnect attempt.
                    [currentDevice reconnectCompleted:NO];
                    
                }
                if (opType == kOpTypeConfigure || opType == kOpTypeCapture || opType == kOpTypeDownload) {
                    //reset the UI to "not capturing."
                    [currentDevice captureCompleted];
                }
                //in either case, re-enable the reconnect options.
                currentDevice.reconnectOptionsEnabled = YES;
            }
        }
    }

    
    //add this result to the WS-BD Result cache (at the top)
    [self.wsbdOpNameCache insertObject:[NBCLSensorLink stringForOpType:opType] atIndex:0];
    [self.wsbdResultCache insertObject:error atIndex:0];

}

-(void) sensorOperationWasCancelledByService:(int)opType fromLink:(id)link withResult:(WSBDResult*)result
{
    
}

-(void) sensorOperationWasCancelledByClient:(int)opType fromLink:(id)link
{
    
}

-(void) sensorOperationCompleted:(int)opType fromLink:(id)link withResult:(WSBDResult*)result
{
    if (result.status != StatusSuccess) {
        //make sure we reset any UI state so we can try again.
        if (opType == kOpTypeRegister || opType == kOpTypeLock || opType == kOpTypeInitialize) {
            //we need to reconnect to this sensor.
            for (UIView *v in self.capturerScroll.subviews) {
                if ([v isKindOfClass:[WsabiDeviceView_iPad class]]) {
                    WsabiDeviceView_iPad *currentDevice = (WsabiDeviceView_iPad*) v;
                    NBCLSensorLink *currentLink = link;
                    //If the URI matches, this is a matching capturer.
                    if ([currentDevice.capturer.sensor.uri localizedCaseInsensitiveCompare:currentLink.uri] == NSOrderedSame) {
                        currentDevice.sensorAvailable = NO;
                        //make sure we're not in "reconnect" mode anymore if we shouldn't be.
                        [currentDevice reconnectCompleted:NO];
                    }
                }
            }
        }

    }   
    
    //add this result to the WS-BD Result cache (at the top)
    [self.wsbdOpNameCache insertObject:[NBCLSensorLink stringForOpType:opType] atIndex:0];
    [self.wsbdResultCache insertObject:result atIndex:0];
    
}

-(void) sensorConnectionStatusChanged:(BOOL)connectedAndReady fromLink:(id)link
{
    //update the device views based on the current link readiness.
    for (UIView *v in self.capturerScroll.subviews) {
        if ([v isKindOfClass:[WsabiDeviceView_iPad class]]) {
            WsabiDeviceView_iPad *currentDevice = (WsabiDeviceView_iPad*) v;
            NBCLSensorLink *currentLink = link;
            //If the URI matches, this is a matching capturer.
            if ([currentDevice.capturer.sensor.uri localizedCaseInsensitiveCompare:currentLink.uri] == NSOrderedSame) {
                currentDevice.sensorAvailable = connectedAndReady;
                //make sure we're not in "reconnect" mode anymore if we shouldn't be.
                [currentDevice reconnectCompleted:connectedAndReady];
            }
        }
    }
}


//NOTE: The result object will be the result from the last performed step;
//so if the sequence succeeds, it'll be the last step in the sequence; otherwise
//it'll be the step that failed, so that the status will indicate what the problem was.
-(void) sensorConnectSequenceCompletedFromLink:(id)link withResult:(WSBDResult*)result
{
    NBCLSensorLink *sensorLink = link;
    if (result.status == StatusSuccess) {
        NSLog(@"Successfully connected to sensor at URI %@",sensorLink.uri);
    }
}

-(void) sensorCaptureSequenceCompletedFromLink:(id)link withResults:(NSMutableArray*)results withSenderTag:(int)tag
{
    //Get the data objects for the current collection so we can modify them as necessary.
    NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"positionInCollection" ascending:YES selector:@selector(compare:)] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
    NSArray *sortedDataObjects = [self.activeCollection.items sortedArrayUsingDescriptors:sortDescriptors];

    BiometricData *theData = [sortedDataObjects objectAtIndex:(tag - CAPTURER_TAG_OFFSET)];
    WsabiDeviceView_iPad *theCapturer = (WsabiDeviceView_iPad*)[self.capturerScroll viewWithTag:tag];

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd HH_mm_ss"];
    
    
    //TODO: This needs to handle multiple capture results more capably (which is to say, at all).
    for (int i = 0; i < [results count]; i++) {
        WSBDResult *dl = [results objectAtIndex:i];
        if (dl.status == StatusSuccess) {
            //use this result, then break.

            NSDate *now = [NSDate date];
            theData.timestampCaptured = now;
            theData.timestampModified = now;
            
            //if the data is one of UIImage's supported image types, use it in the matching device view.
            if ([dl.contentType isEqualToString:@"image/png"] ||
                [dl.contentType isEqualToString:@"image/jpeg"] ||
                [dl.contentType isEqualToString:@"image/bmp"] ||
                [dl.contentType isEqualToString:@"image/x-windows-bmp"] ||
                [dl.contentType isEqualToString:@"image/x-tiff"] ||
                [dl.contentType isEqualToString:@"image/tiff"]
                ) {
                UIImage *tempImage = [UIImage imageWithData:dl.downloadData];
                
                //if we're replacing an existing image, try to remove the old file from the filesystem
                //before storing the new one.
                if (theData.filePath) {
                    [[NSFileManager defaultManager] removeItemAtPath:theData.filePath error:nil];
                }
                
                //theCapturer.resultImageView.image = tempImage;

                theData.contentType = dl.contentType; //store the content type of the resulting data.

                //save the data to the Documents directory, and store the path in the Core data object.
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                                
                NSString *tempImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"CollectionResult_%@.png",[formatter stringFromDate:[NSDate date]]]];
                
                [UIImagePNGRepresentation(tempImage) writeToFile:tempImagePath atomically:YES];
                theData.filePath = tempImagePath; //store the path to this image in Core Data
                theData.thumbnail = UIImagePNGRepresentation([UIImage scaleImage:tempImage toSize:CGSizeMake(kThumbnailImageMaxSize, kThumbnailImageMaxSize)]);
                
                [self updateData:theData forDeviceView:theCapturer withFlash:YES]; //force a data reload.

                [self.collectionsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:[self.sortedCollections indexOfObject:self.activeCollection]]] 
                                             withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
    
    [theCapturer captureCompleted]; //return the capturer to its normal (waiting) state.
}

-(void) sensorDisconnectSequenceCompletedFromLink:(id)link withResult:(WSBDResult*)result shouldReleaseIfSuccessful:(BOOL)shouldRelease;
{
    NBCLSensorLink *sensorLink = link;
    if (result.status == StatusSuccess) {
        NSLog(@"Successfully disconnected from sensor at URI %@",sensorLink.uri);
        
        if (shouldRelease) {
            [link release]; //release the link object
        }
    }

}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Workflows";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
	self.rootViewController.popoverController = pc;
    
    //store a reference to this button.
    //NOTE: This is a terrible hack to work around a bug in the way UISplitViewController handles memory warnings.
    //When the warning is received, it dumps both view controllers, instantiating them again as necessary.
    //HOWEVER, when the master VC is recreated, it never fires the associated willHide/willShow delegate methods,
    //so the menu button in the detail view is never recreated, even though the VC to fill it has been.
    //Therefore, we're keeping a reference to the button the first time we get it,
    //and then using that reference in viewDidLoad to recreate the button manually, if it's required.
    self.rootMenuToolbarItem = barButtonItem;
 }


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Convenience methods for creating device views
-(WsabiDeviceView_iPad*) createDeviceViewForCapturer:(Capturer*)cap;
{
	WsabiDeviceView_iPad *dView = [[[NSBundle mainBundle] loadNibNamed:@"WsabiDeviceView_iPad" owner:self options:nil] objectAtIndex:0];
	
    NSLog(@"Created device view %@",dView);
    
	//configure the device view.
	dView.center = CGPointMake(self.capturerScroll.bounds.size.width/2.0 + (CAPTURER_WIDTH_OFFSET + CAPTURER_WIDTH) * [cap.positionInWorkflow intValue], 
							   self.capturerScroll.bounds.size.height/2.0);
	
	dView.delegate = self;
	
	//connect the capture device to Core Data
	dView.capturer = cap;
    
    //Figure out whether the sensor is available -- if this is a local sensor,
    //it's possible that it will have fired the connection status change method
    //before we've gotten to this point in the UI creation, so the sensor might
    //already be available.
    BOOL alreadyActive = NO;
    for (NBCLSensorLink *currentLink in self.sensorLinks) {
        //If the URI matches, this is a matching capturer.
        if ([dView.capturer.sensor.uri localizedCaseInsensitiveCompare:currentLink.uri] == NSOrderedSame && currentLink.initialized) {
            
            dView.sensorAvailable = YES;
            //make sure we're not in "reconnect" mode anymore if we shouldn't be.
            [dView reconnectCompleted:YES];
            alreadyActive = YES;
            break; //no need to keep looking.
        }
    }    
    if (!alreadyActive) {
        //start with the connection spinner active.
        [dView.reconnectActivity setHidden:NO];
        [dView.reconnectActivity startAnimating];
    }
    
	//set the view tag so we can retrieve this view later when needed.
	dView.tag = CAPTURER_TAG_OFFSET + [cap.positionInWorkflow intValue];
    
    NSLog(@"Creating a capturer device view with tag %d",dView.tag);
	
	return dView;
}

-(void) enableLivePreviewForDeviceAtIndex:(NSNumber*)index
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //first, hide the preview for all views in the capture scroll view.
    for (WsabiDeviceView_iPad *v in self.capturerScroll.subviews) {
          v.livePreviewView.hidden = YES;
    }
    
    //figure out which device we're working on, and which sensor link it's connected to.
    WsabiDeviceView_iPad *dView = (WsabiDeviceView_iPad *)[self.capturerScroll viewWithTag:CAPTURER_TAG_OFFSET + [index intValue]];
    NBCLSensorLink *dViewSensorLink = nil;
    for (NBCLSensorLink *link in self.sensorLinks) {
        //If the URI matches, this is a matching link.
        if ([dView.capturer.sensor.uri localizedCaseInsensitiveCompare:link.uri] == NSOrderedSame) {
            dViewSensorLink = link;
            break; //no need to keep looking.
        }
    }
    
    if (!dView || ![dViewSensorLink isKindOfClass:[NBCLInternalCameraSensorLink class]]) {
        //either we don't have a device view to work on
        //or the sensor doesn't support live preview, so just return.
        [pool drain];
        return;
    }
    
    //FIXME: TESTING ONLY.
    //Set up the live camera preview. This isn't something we'll want to do automatically in the long term,
    //but would conceivably go here anyway.
    NBCLInternalCameraSensorLink *pLink = (NBCLInternalCameraSensorLink*) dViewSensorLink;
    
    AVCaptureVideoPreviewLayer *previewLayer = pLink.previewLayer;
    //configure the preview layer and its target parent layer.
    [previewLayer setFrame:dView.livePreviewView.bounds];
    [dView.livePreviewView.layer setMasksToBounds:YES];
    
    
    if ([[pLink.captureManager session] isRunning]) {
        [pLink.captureManager setDelegate:self];
        
        //           NSUInteger cameraCount = [captureManager cameraCount];
        //            if (cameraCount < 1) {
        //                [[self hudButton] setEnabled:NO];
        //                [[self cameraToggleButton] setEnabled:NO];
        //                [[self stillImageButton] setEnabled:NO];
        //                [[self gravityButton] setEnabled:NO];
        //            } else if (cameraCount < 2) {
        //                [[self cameraToggleButton] setEnabled:NO];
        //            }
        //            
        //            if (cameraCount < 1 && [captureManager micCount] < 1) {
        //                [[self recordButton] setEnabled:NO];
        //            }
        
        //Add the actual preview layer to the specified object's livePreviewView.
        //NOTE: This should remove the layer from any other hierarchies in which it's present.
        [dView.livePreviewView.layer insertSublayer:previewLayer below:[[dView.livePreviewView.layer sublayers] objectAtIndex:0]];
        dView.livePreviewView.hidden = NO;
    } 
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                            message:@"Failed to start session."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    } 
    
        

    [pool drain];
}

-(void) disableLivePreviewForDeviceAtIndex:(NSNumber*)index
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //TESTING ONLY: Turn off the camera preview for this device.
    WsabiDeviceView_iPad *dView = (WsabiDeviceView_iPad *)[self.capturerScroll viewWithTag:CAPTURER_TAG_OFFSET+[index intValue]];
    if (dView) {
        //Remove all sublayers of the preview view, which will have the
        //effect of turning off the preview.
        dView.livePreviewView.layer.sublayers = nil;
    }
    [pool drain];
}

//If -1 is passed in as the new active position, the active collection's existing position is used.
-(void) makeCollectionActiveAtIndex:(int)index withActivePosition:(int)pos animated:(BOOL)isAnimated
{
    for (int i = 0; i < [self.sortedCollections count]; i++) {
        BiometricCollection *coll = (BiometricCollection*)[self.sortedCollections objectAtIndex:i];
        if (i == index) {
            coll.isActive = [NSNumber numberWithBool:YES];
            self.activeCollection = coll;
        }
        else
        {
            coll.isActive = [NSNumber numberWithBool:NO];
        }
        
    }

    //sort the collection items in the current collection so we can attach them to the capture devices
    NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"positionInCollection" ascending:YES selector:@selector(compare:)] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
    NSArray *sortedItems = [self.activeCollection.items sortedArrayUsingDescriptors:sortDescriptors];
    
    for (UIView *v in self.capturerScroll.subviews) {
        if ([v isKindOfClass:[WsabiDeviceView_iPad class]]) {
            WsabiDeviceView_iPad *tempView = (WsabiDeviceView_iPad*)v;
            //set this device's BiometricData object
            [tempView setData:[sortedItems objectAtIndex:(tempView.tag - CAPTURER_TAG_OFFSET)]];
            //flip this card to the front
            [tempView flipToFront];

        }
    }
    
    //update the current position to match what was requested.
    if (pos >= 0) {
        self.activeCollection.currentPosition = [NSNumber numberWithInt:pos];
    }

    //reset the scroll offset and current page indicators as necessary.
    //scroll the scroll view to show the requested device.
    //NOTE: This should return step 0 when there's no current position set.
    NSLog(@"makeCollectionActiveAtIndex: setting scroll offset to %1.0f",(CAPTURER_WIDTH_OFFSET + CAPTURER_WIDTH) * (float)[self.activeCollection.currentPosition intValue]);

    [self.capturerScroll setContentOffset:CGPointMake((CAPTURER_WIDTH_OFFSET + CAPTURER_WIDTH) * [self.activeCollection.currentPosition intValue], 0) animated:isAnimated];
    
    [self performSelectorOnMainThread:@selector(enableLivePreviewForDeviceAtIndex:) withObject:self.activeCollection.currentPosition waitUntilDone:NO];
    
    [self.collectionsTable reloadData];
        
    //Make sure the newly created collection is visible.
    [self.collectionsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


//Rebuild the sorted array of collections from the current workflow.
-(void) updateCollections
{
    //if there's no workflow, just clear everything and return.
    if (!self.workflow) {
        self.sortedCollections = nil;
        self.activeCollection = nil;
        return;
    }
    
	NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestampStarted" ascending:NO selector:@selector(compare:)] autorelease];
	
	NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
	
	self.sortedCollections = [self.workflow.collections sortedArrayUsingDescriptors:sortDescriptors];
    
    //update the active collection pointer.
    for (BiometricCollection *coll in self.sortedCollections) {
        if ([coll.isActive boolValue]) {
            self.activeCollection = coll;
            break; //no need to keep looking.
        }
    }
}

#pragma mark -
#pragma mark Table View Data Source and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.workflow) {
		return MAX([self.sortedCollections count], 1); //always provide at least the header to add a new collection.
	}
    else return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1; //each cell is going to be its own collection container.
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	WsabiCollectionHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"WsabiCollectionHeaderView" owner:self options:nil] objectAtIndex:0];
    
    
    //connect the "add new" button to the proper handler
    [headerView.addCollectionButton addTarget:self action:@selector(addNewCollection:) forControlEvents:UIControlEventTouchUpInside];
    
    //connect the "edit" button to the proper handler
    [headerView.editCollectionsButton addTarget:self action:@selector(editCollectionTable:) forControlEvents:UIControlEventTouchUpInside];
    
    //determine whether or not this collection is selected.
    BiometricCollection *c = [self.sortedCollections objectAtIndex:section];
    //If it's selected, or if it's the only collection, highlight the header.
    headerView.selected = ((c == self.activeCollection) || ([self.sortedCollections count] == 1));

    //use the collection data to set the header label
    if (c) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease ];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        
        headerView.headerLabel.text = [NSString stringWithFormat:@"Collection (started %@)",[formatter stringFromDate:c.timestampStarted]];
    }
    else {
        headerView.headerLabel.text = @"";
    }
    
    //put a shadow behind the header.
    headerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    headerView.layer.shadowOpacity = 0.5;
    headerView.layer.shadowOffset = CGSizeMake(1, 2);
    headerView.layer.shadowRadius = 5;
    headerView.layer.shouldRasterize = YES;
    
    //tag this view's label with the section index so we can use it to activate this collection later.
    headerView.headerLabel.tag = section;
    
    //if this table is in editing mode, adjust the header.
    headerView.editing = tableView.editing;

    //add a touch listener to the header's text label to change the active collection.
    UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionHeaderTapped:)];
    [headerView.headerLabel addGestureRecognizer:headerTap];
    [headerTap release];
    
    
	return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //figure out how many rows this cell should occupy based on how many items are in the collection.
    BiometricCollection *c = [self.sortedCollections objectAtIndex:indexPath.section];
    int count = [c.items count];
    int numRows = 1 + floor(((kCollectionCellSize.width + kCollectionCellOffset.width) * count) / self.collectionsTable.bounds.size.width);
    
    
    return numRows * (kCollectionCellSize.height + (2 * kCollectionCellOffset.height));
}

- (void)configureCell:(WsabiCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.collection = [self.sortedCollections objectAtIndex:indexPath.section];
    //tag the cell with the current index of this collection.
    cell.tag = indexPath.section;
    cell.delegate = self;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    WsabiCollectionCell *cell = (WsabiCollectionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (WsabiCollectionCell*)[[[NSBundle mainBundle] loadNibNamed:@"WsabiCollectionCell" owner:self options:nil] objectAtIndex:0];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object.
        BiometricCollection *objectToDelete = [self.sortedCollections objectAtIndex:indexPath.section];
        //if this is active, set the next workflow as active if possible.
        if (objectToDelete.isActive && [self.sortedCollections count] > (indexPath.section + 1)) {
            [(BiometricCollection*)[self.sortedCollections objectAtIndex:indexPath.section + 1] setIsActive:[NSNumber numberWithBool:YES]];
        }
        
        //If there are any results in this collection, delete them from the file system
        //before removing the database object.
        for (BiometricData *theData in [objectToDelete.items allObjects]) {
            if (theData.filePath) {
                [[NSFileManager defaultManager] removeItemAtPath:theData.filePath error:nil];
            }
        }
        
        [self.workflow removeCollectionsObject:objectToDelete];
        
        NSManagedObjectContext *context = [self.workflow managedObjectContext];
        
        //If there aren't any more collections, add a new one.
        if ([self.workflow.collections count] <= 0) {
            [self addNewCollection:nil];
        }
        
        NSError *error;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        //update the list of collections
        [self updateCollections];
        
        //delete the visual row.
        [UIView animateWithDuration:kFadeAnimationDuration 
                         animations:^{
                             self.collectionsTable.alpha = 0.0;
                         }
                         completion:^(BOOL completed) {
                             [self.collectionsTable reloadData];
                             [UIView animateWithDuration:kFadeAnimationDuration 
                                              animations:^{
                                                  self.collectionsTable.alpha = 1.0;
                                              }];
                         }
         ];

        //[tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];
        
    }   
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark -
#pragma mark Table view delegate

//- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    for (int i = 0; i < [self.sortedCollections count]; i++) {
//        //set this collection as active, and set the others as inactive
//        [(BiometricCollection*)[self.sortedCollections objectAtIndex:i] setIsActive:[NSNumber numberWithBool:(i == indexPath.section)]];
//    }
//    [self.collectionsTable reloadData];
//}

#pragma mark -
#pragma mark Button Action methods
-(IBAction) addNewCollection:(id)sender
{
    if (!self.workflow) {
        return; //nothing to add a collection to.
    }
    
    BiometricCollection *coll = [NSEntityDescription insertNewObjectForEntityForName:@"BiometricCollection" inManagedObjectContext:self.workflow.managedObjectContext];

    coll.timestampStarted = [NSDate date];

    //sort the capturers by their position in the workflow, then create a placeholder cell for each one.
    NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"positionInWorkflow" ascending:YES selector:@selector(compare:)] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
    NSArray *sortedCapturers = [workflow.capturers sortedArrayUsingDescriptors:sortDescriptors];

    //set this collection to have the same number of items as the workflow has capturers.
    coll.totalLength = [NSNumber numberWithInt:[sortedCapturers count]];

    for (int i = 0; i < [sortedCapturers count]; i++) {
        Capturer *cap = (Capturer*)[sortedCapturers objectAtIndex:i];
        BiometricData *newData = [NSEntityDescription insertNewObjectForEntityForName:@"BiometricData" inManagedObjectContext:self.workflow.managedObjectContext];
        newData.captureType = cap.captureType;
        newData.originalCaptureType = cap.captureType; //this allows us to track how this data was captured even if we change the type later.
        newData.positionInCollection = [NSNumber numberWithInt:i];
        
        //add this item to the collection
        [coll addItemsObject:newData];
    }

    //set this collection as active. NOTE: This is taken 
    //coll.isActive = [NSNumber numberWithBool:YES];

    //set all the other collections (if any) as inactive, then add this collection to the list.
    for (BiometricCollection *otherColl in [self.workflow.collections allObjects]) {
        otherColl.isActive = [NSNumber numberWithBool:NO];
    }

    [self.workflow addCollectionsObject:coll];

    //update the sorted list of collections for the table view.
    [self updateCollections];

    //update the visual object
    //NOTE: We have to do a manual fade here for now, because insert/reloadSections doesn't refresh the custom header views.

    [UIView animateWithDuration:kFadeAnimationDuration 
                 animations:^{
                     self.collectionsTable.alpha = 0.0;
                 }
                 completion:^(BOOL completed) {
                    [self.collectionsTable reloadData];
                    [UIView animateWithDuration:kFadeAnimationDuration 
                                    animations:^{
                                          self.collectionsTable.alpha = 1.0;
                                      }];
                 }
    ];

    [self makeCollectionActiveAtIndex:0 withActivePosition:0 animated:YES];
    
    

}

-(IBAction) editCollectionTable:(id)sender
{
    [self.collectionsTable setEditing:!self.collectionsTable.editing animated:YES];
    
    //change the edit button's selected state.
    ((UIButton*)sender).selected = !((UIButton*)sender).selected;
}

-(IBAction) collectionHeaderTapped:(UITapGestureRecognizer*)recog
{
    //Pass -1 as the new position, as we don't want to change the active position of the new collection.
    [self makeCollectionActiveAtIndex:recog.view.tag withActivePosition:-1 animated:YES];
}

#pragma mark - Miscellaneous animation methods, etc.
-(void) updateData:(BiometricData*)newData forDeviceView:(WsabiDeviceView_iPad*)device withFlash:(BOOL)flash
{
    if (!device) {
        return; //nothing to update.
    }
    
    if (!flash) {
        //just set the data on the specified device and return.
        device.data = newData;
        return;
    }
    
    UIView *flashView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease]; //don't round the corners; the excess white should work as a glow effect.
    flashView.backgroundColor = [UIColor whiteColor];
    flashView.alpha = 0.0;
    [self.view addSubview:flashView];
    
    [UIView animateWithDuration:kFlashInAnimationDuration 
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         flashView.alpha = kFlashOpacity;
                     }
                     completion:^(BOOL completed) {
                         //put the new data in place behind the flash view.
                         device.data = newData;
                         //Perform the second half of the animation, in which the new image is set and faded back in.
                         [UIView animateWithDuration:kFlashOutAnimationDuration 
                                               delay:0 
                                             options:UIViewAnimationOptionBeginFromCurrentState
                                          animations: ^{
                                              flashView.alpha = 0.0;
                                          }
                                          completion:^(BOOL completed) {
                                              //remove the flash view from the view hierarchy.
                                              [flashView removeFromSuperview];
                                          }
                          
                          ];
                         
                     }
     
     ];

}

-(void) showWorkflowLoadedOverlay:(NSTimeInterval)visibleTime
{
    [UIView animateWithDuration:0.5
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         self.workflowLoadedOverlay.alpha = 1.0;
                     }
                     completion:^(BOOL completed) {
   
                         //wait the specified amount of time, then hide the overlay.
                         [UIView animateWithDuration:0.5 
                                               delay:visibleTime 
                                             options:UIViewAnimationOptionBeginFromCurrentState
                                          animations: ^{
                                              self.workflowLoadedOverlay.alpha = 0.0;
                                          }
                                          completion:nil                          
                          ];
                         
                     }
     
     ];

}

#pragma mark - Device View (front and back) delegates
-(void) didBeginAnnotating:(id)sender
{	

}

-(void) didEndAnnotating:(id)sender
{	
    //update the current collection to make sure we get updated badges.
    int sectionIndex = [self.sortedCollections indexOfObject:self.activeCollection];
    
    //NOTE: We have to reload the entire table here, or the UITableView won't show a valid
    //section header until the user moves the table. Not sure why reloading the section
    //doesn't trigger a section header reload, but it doesn't.
    [self.collectionsTable reloadData];
    
    //If we're adjusting an annotation on a collection that's no longer visible, show it, so the user knows
    //we're changing something.
    [self.collectionsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void) didRequestConnection:(id)sender atNewUri:(NSString*)newUri
{
    WsabiDeviceView_iPad *currentDevice = sender;
    for (NBCLSensorLink *link in self.sensorLinks) {
        //If the URI matches, this is a matching link.
        if ([currentDevice.capturer.sensor.uri localizedCaseInsensitiveCompare:link.uri] == NSOrderedSame) {
            
            //update the URI
            link.uri = newUri;
            currentDevice.capturer.sensor.uri = newUri;
            
            //disable the reconnect options until this call resolves one way or another.
            currentDevice.reconnectOptionsEnabled = NO;
            
            //attempt to connect this sensor, stealing the lock if necessary.
            BOOL sequenceStarted = [link beginConnectSequence:YES withSenderTag:-1];
            if (!sequenceStarted) {
                NSLog(@"Couldn't start sensor connect sequence for sensor at %@",currentDevice.capturer.sensor.uri);
            }

        }
    }
    
    //enable the capture button behind the reconnect view.
    currentDevice.captureButton.enabled = YES;
}

-(void) didConnectToSensor:(id)sender
{
    //Connection was successful. If this is the active sensor, enable the capture button.
    
    //Find the current capturer.
    WsabiDeviceView_iPad *currentDevice = (WsabiDeviceView_iPad*) [self.capturerScroll viewWithTag:
                                                                   ([self.activeCollection.currentPosition intValue] + CAPTURER_TAG_OFFSET)];
    
    if (currentDevice == sender) {
        //this is the active capture card; enable the capture button.
        currentDevice.captureButton.enabled = YES;
    }
}

-(void) didRequestCapture:(id)sender
{
    //capture, then download.
    WsabiDeviceView_iPad *currentDevice = sender;
    for (NBCLSensorLink *link in self.sensorLinks) {
        //If the URI matches, this is a matching link.
        if ([currentDevice.capturer.sensor.uri localizedCaseInsensitiveCompare:link.uri] == NSOrderedSame) {
            [link beginCaptureSequence:link.currentSessionId captureType:[currentDevice.capturer.captureType intValue] withMaxSize:640 withSenderTag:currentDevice.tag];
        }

    }

}

-(void) didRequestCancelCapture:(id)sender
{
    //capture, then download.
    WsabiDeviceView_iPad *currentDevice = sender;
    for (NBCLSensorLink *link in self.sensorLinks) {
        //If the URI matches, this is a matching link.
        if ([currentDevice.capturer.sensor.uri localizedCaseInsensitiveCompare:link.uri] == NSOrderedSame) {
            [link beginCancel:link.currentSessionId withSenderTag:currentDevice.tag];
        }
        
    }

}

-(void) didRequestClearData:(id)sender
{
    //Clear the data from this collection item.
    WsabiDeviceView_iPad *currentDevice = sender;
    int tag = currentDevice.tag;

    //Remove the matching result from the active collection.
    //Get the data objects for the current collection so we can modify them as necessary.
    NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"positionInCollection" ascending:YES selector:@selector(compare:)] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
    NSArray *sortedDataObjects = [self.activeCollection.items sortedArrayUsingDescriptors:sortDescriptors];
    
    BiometricData *theData = [sortedDataObjects objectAtIndex:(tag - CAPTURER_TAG_OFFSET)];

    //remove the file at theData's file path, then remove the path and thumbnail.
    if (theData.filePath) {
        @try {
            [[NSFileManager defaultManager] removeItemAtPath:theData.filePath error:nil];
        }
        @catch (NSException *exception) {
            NSLog(@"DetailView::didRequestClearData couldn't delete the requested file (%@)", theData.filePath);
        }
        theData.filePath = nil;
    }
    theData.thumbnail = nil;
    
    //Reload the collection to display the changes
    [self.collectionsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:[self.sortedCollections indexOfObject:self.activeCollection]]] 
                                 withRowAnimation:UITableViewRowAnimationFade];

    [self updateData:theData forDeviceView:currentDevice withFlash:NO];
    
    //enable the capture button on this device.
    currentDevice.captureButton.enabled = YES;
}

-(void) didRequestCurrentItemFullScreen
{
    int index = [self.activeCollection.currentPosition intValue];
    
    //build an array of image paths, then open a full-screen image view for them.
    //Sort the existing capturers for this workflow by their stated order.
    NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"positionInCollection" ascending:YES selector:@selector(compare:)] autorelease];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
    
    NSArray *tempItems = [self.activeCollection.items sortedArrayUsingDescriptors:sortDescriptors];
    
    //If there's nothing in this cell, just return.
    if (![(BiometricData*)[tempItems objectAtIndex:index] filePath]) {
        return;
    }
    
    //We need to convert the index to a matching number that doesn't include any missing cells prior
    //to this result (that is, if the first real result is at index 3, so index 3 gets passed in here,
    //the photo browser still only thinks there's one result, so we need to ask for the photo at index
    //0).
    
    int convertedIndex = index;
    
    NSMutableArray *paths = [[[NSMutableArray alloc] init] autorelease];
    for (int i = 0; i < [tempItems count]; i++) {
        if ([(BiometricData*)[tempItems objectAtIndex:i] filePath]) {
            [paths addObject:[(BiometricData*)[tempItems objectAtIndex:i] filePath]];
        }
        else if (i < index) {
            //if there's no result and we're before the requested index, decrement the converted
            //index counter.
            convertedIndex--;
        }
    }
    
    [self presentFullscreenPhotoBrowser:paths withItemAtIndex:convertedIndex];

}


#pragma mark -
#pragma mark Collection delegate methods
-(void) didSelectItemAtIndex:(int)index fromCollectionCell:(id)sender
{
    //make sure this collection is active.
    [self makeCollectionActiveAtIndex:((WsabiCollectionCell*)sender).tag withActivePosition:index animated:YES];
        
    //reset the scroll offset and current page indicators as necessary.
    //scroll the scroll view to show this device.
    //NOTE: This should return step 0 when there's no current position set.
    //[self.capturerScroll scrollRectToVisible:[self.capturerScroll viewWithTag:CAPTURER_TAG_OFFSET+index].frame animated:YES];

}


-(void) didRequestLargeViewOfItemAtIndex:(int)index fromCollectionCell:(id)sender
{
    if (!sender) {
        //nothing to show, just return.
        NSLog(@"Requested a large view from a nonexistent collection. Ignoring.");
        return;
    }
    
    //build an array of image paths, then open a full-screen image view for them.
    //Sort the existing capturers for this workflow by their stated order.
    NSSortDescriptor *orderSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"positionInCollection" ascending:YES selector:@selector(compare:)] autorelease];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:orderSortDescriptor];
    
    NSArray *tempItems = [((WsabiCollectionCell*)sender).collection.items sortedArrayUsingDescriptors:sortDescriptors];
    
    //If there's nothing in this cell, just return.
    if (![(BiometricData*)[tempItems objectAtIndex:index] filePath]) {
        return;
    }
    
    //We need to convert the index to a matching number that doesn't include any missing cells prior
    //to this result (that is, if the first real result is at index 3, so index 3 gets passed in here,
    //the photo browser still only thinks there's one result, so we need to ask for the photo at index
    //0).
    
    int convertedIndex = index;
    
    NSMutableArray *paths = [[[NSMutableArray alloc] init] autorelease];
    for (int i = 0; i < [tempItems count]; i++) {
        if ([(BiometricData*)[tempItems objectAtIndex:i] filePath]) {
            [paths addObject:[(BiometricData*)[tempItems objectAtIndex:i] filePath]];
        }
        else if (i < index) {
            //if there's no result and we're before the requested index, decrement the converted
            //index counter.
            convertedIndex--;
        }
    }
    
//    if ([paths count] > 0) {
//        PhotoViewController *photoViewer = [[[PhotoViewController alloc] init] autorelease];
//        photoViewer.photoPaths = paths;
//        
//        UINavigationController *tempNav = [[[UINavigationController alloc] initWithRootViewController:photoViewer] autorelease];
//        [self presentModalViewController:tempNav animated:YES];
//  
//    }
    
    [self presentFullscreenPhotoBrowser:paths withItemAtIndex:convertedIndex];

}

#pragma mark AVCamDemoCaptureManager delegate
- (void) captureStillImageFailedWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Still Image Capture Failure"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void) acquiringDeviceLockFailedWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device Configuration Lock Failure"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];    
}

- (void) cannotWriteToAssetLibrary
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incompatible with Asset Library"
                                                        message:@"The captured file cannot be written to the asset library. It is likely an audio-only file."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];        
}

- (void) assetLibraryError:(NSError *)error forURL:(NSURL *)assetURL
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Asset Library Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];    
}

- (void) someOtherError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];    
}

- (void) recordingBegan
{
    //    [[self recordButton] setTitle:@"Stop"];
    //    [[self recordButton] setEnabled:YES];
}

- (void) recordingFinished
{
    //    [[self recordButton] setTitle:@"Record"];
    //    [[self recordButton] setEnabled:YES];
}

- (void) deviceCountChanged
{
    //    AVCamDemoCaptureManager *captureManager = [self captureManager];
    //    if ([captureManager cameraCount] >= 1 || [captureManager micCount] >= 1) {
    //        [[self recordButton] setEnabled:YES];
    //    } else {
    //        [[self recordButton] setEnabled:NO];
    //    }
    
}




#pragma mark -
#pragma mark UIScrollView delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//update the current page indicator.
    //NSLog(@"Scrollview offset is %1.0f",scrollView.contentOffset.x);
	self.capturerPageControl.currentPage = round(scrollView.contentOffset.x / (CAPTURER_WIDTH_OFFSET + CAPTURER_WIDTH));
	
	if (workflow && workflow.name) {
		self.titleToolbarItem.title = [NSString stringWithFormat:@"%@ (Step %d of %d)", workflow.name, self.capturerPageControl.currentPage + 1, [workflow.capturers count]];
	}
	
    
}

//NOTE: This will be called when the user scrolls, OR when the system calls scrollRectToVisible with animations enabled.
-(void) updateScrollPositionData:(UIScrollView*)scrollView setActiveCell:(BOOL)shouldSet
{
    //Perform some more computationally expensive operations here, rather than any time the scroll amount changes.
    
    int itemNumber = round(scrollView.contentOffset.x / (CAPTURER_WIDTH_OFFSET + CAPTURER_WIDTH));
    
    //if necessary, manually set the active cell.
    if (shouldSet) {
        for (int i = 0; i < [self.sortedCollections count]; i++) {
          BiometricCollection *c = [self.sortedCollections objectAtIndex:i];
           if ([c.isActive boolValue]) {
             //this is the one we want. Select the matching cell in the collections table.
               [(WsabiCollectionCell*)[self.collectionsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]] selectItemAtIndex:itemNumber];
            }
        }

    }
    
    //update the current workflow position.
    if (self.activeCollection) {
        NSLog(@"After animation, setting new active collection position to %d",itemNumber);
        self.activeCollection.currentPosition = [NSNumber numberWithInt:itemNumber];
    }
        
    NSLog(@"After setting active collection, scrollView offset is (%1.0f,%1.0f)",self.capturerScroll.contentOffset.x, self.capturerScroll.contentOffset.y);

    //disable capture buttons on all but this capture card.
    for (int j = 0; j < [self.workflow.capturers count]; j++) {
        WsabiDeviceView_iPad *captureCard = (WsabiDeviceView_iPad*) [self.capturerScroll viewWithTag:(j + CAPTURER_TAG_OFFSET)];
        BOOL shouldEnable = (j == itemNumber);
        captureCard.captureButton.enabled = shouldEnable;
    }
    
}

//NOTE: This is only called when scrolling manually.
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.capturerScroll) {

        [self updateScrollPositionData:scrollView setActiveCell:YES];
        //enable live preview for this workflow position (if applicable)
        [self performSelectorOnMainThread:@selector(enableLivePreviewForDeviceAtIndex:) withObject:self.activeCollection.currentPosition waitUntilDone:NO];
    }
}

//NOTE: This is only called when scrolling programmatically.
-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.capturerScroll) {
        [self updateScrollPositionData:scrollView setActiveCell:NO];
        self.capturerPageControl.currentPage = round(scrollView.contentOffset.x / (CAPTURER_WIDTH_OFFSET + CAPTURER_WIDTH));
        
        if (workflow && workflow.name) {
            self.titleToolbarItem.title = [NSString stringWithFormat:@"%@ (Step %d of %d)", workflow.name, self.capturerPageControl.currentPage + 1, [workflow.capturers count]];
        }

    }

}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    //dump the WSBD result cache
    NSLog(@"Received memory warning, clearing WS-BD Result and OpName caches");
    [self.wsbdResultCache removeAllObjects];
    [self.wsbdOpNameCache removeAllObjects];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[toolbar release];
	[titleToolbarItem release];
    [rootMenuToolbarItem release];
    [bugToolbarItem release];
    [wsbdResultCache release];
    [wsbdOpNameCache release];
    [capturerScroll release];
	[capturerPageControl release];
	[collectionsTable release];
    [collectionsDropShadowTop release];
	[collectionsDropShadowBottom release];
    [workflowLoadedOverlay release];
    
    [sortedCollections release];
    [sensorLinks release];
    [_captureVideoPreviewLayer release];
    [_captureManager release];
    
    [popoverController release];
    [bugPopoverController release];
    [super dealloc];
}


@end
    