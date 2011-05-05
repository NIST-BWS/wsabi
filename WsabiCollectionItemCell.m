//
//  WsabiCollectionItemCell.m
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


#import "WsabiCollectionItemCell.h"


@implementation WsabiCollectionItemCell
@synthesize placeholderImage, placeholderImageView, dataImage, imageView, isFilled;

- (id) initWithFrame: (CGRect) frame reuseIdentifier:(NSString *) reuseIdentifier
{
    self = [super initWithFrame: frame reuseIdentifier: reuseIdentifier];
    if ( self == nil )
        return ( nil );
    
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.contentView.opaque = NO;
    self.opaque = NO;
    
    self.placeholderImageView = [[[UIImageView alloc] initWithFrame:self.contentView.bounds] autorelease];
    self.placeholderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    float imageBorderWidth = 2.0;
    
    self.imageView = [[[UIImageView alloc] initWithFrame:CGRectInset(self.contentView.bounds, imageBorderWidth, imageBorderWidth)] autorelease];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.backgroundColor = [UIColor whiteColor];
    
    self.imageView.clipsToBounds = YES;

    self.imageView.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:0.8].CGColor;
    self.imageView.layer.borderWidth = imageBorderWidth;
    self.imageView.layer.cornerRadius = 12;
    self.imageView.layer.shouldRasterize = YES;
    
    self.imageView.hidden = YES; //start with the data image hidden; this is shown when the data image object is set.
    
    [self.contentView addSubview:self.placeholderImageView];
    [self.contentView addSubview:self.imageView];
    
    return ( self );
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

#pragma mark -
#pragma mark Property Accessors

-(void) setIsFilled:(BOOL)filled
{
	isFilled = filled;
	
//	if (isFilled) {
//		//use the data image to populate the image view.
//		self.imageView.image = self.dataImage;
//	}
//	else {
//		//use the placeholder image.
//		self.imageView.image = self.placeholderImage;
//	}
}

-(void) setPlaceholderImage:(UIImage *)newImage
{
   	//make sure the retain/release counts remain correct.
	if (newImage != placeholderImage)
    {
        [newImage retain];
        [placeholderImage release];
        placeholderImage = newImage;
    }
	
    //update the data image view.
	self.placeholderImageView.image = placeholderImage;
 
}

-(void) setDataImage:(UIImage *)newImage
{
	//make sure the retain/release counts remain correct.
	if (newImage != dataImage)
    {
        [newImage retain];
        [dataImage release];
        dataImage = newImage;
    }
	
    //update the data image view.
	self.imageView.image = dataImage;
	
    if (self.imageView.image) {
        self.imageView.hidden = NO;
        self.placeholderImageView.hidden = YES;
    }
    else {
        self.imageView.hidden = YES;
        self.placeholderImageView.hidden = NO;
    }
    
 }

- (void)dealloc {
	[placeholderImage release];
    [placeholderImageView release];
	[imageView release];
    [super dealloc];
}


@end
