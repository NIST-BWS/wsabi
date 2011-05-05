//
//  WsabiCollectionHeaderView.h
//  Wsabi
//
//  Created by Matt Aronoff on 2/3/11.
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

@interface WsabiCollectionHeaderView : UIView {

	UILabel *headerLabel;
	UIButton *addCollectionButton;
    UIButton *editCollectionsButton;

    BOOL selected;
    BOOL editing;
}

-(UIColor*)selectedColor;
-(UIColor*)normalColor;

@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL editing;

@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UIButton *addCollectionButton;
@property (nonatomic, retain) IBOutlet UIButton *editCollectionsButton;

@end
