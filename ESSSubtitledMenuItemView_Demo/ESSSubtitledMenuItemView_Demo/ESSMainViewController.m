//
//  ViewController.m
//  ESSSubtitledMenuItemView_Demo
//
//  Created by Matthias Gansrigler on 13.03.2021.
//

#import "ESSMainViewController.h"
#import "ESSSubtitledMenuItemView.h"
#import <QuartzCore/QuartzCore.h>

@interface ESSMainViewController ()

@property (strong) IBOutlet NSButton *button;

- (IBAction)showMenuWithSubtitledItems:(NSButton *)sender;

@end

@implementation ESSMainViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)showMenuWithSubtitledItems:(NSButton *)sender
{
	NSMenu *men = [[NSMenu alloc] initWithTitle:@""];
	
	NSUInteger amount = 10;
	NSUInteger count = 0;
	for (count = 0; count < amount; count++)
	{
		NSUInteger runningCount = count+1;
		
		/*
		 This is where it all happens!
		 */
		NSMenuItem *item = [[NSMenuItem alloc] init];
		item.target = self;
		item.action = @selector(showAlert:);
		ESSSubtitledMenuItemView *view = [[ESSSubtitledMenuItemView alloc] initWithTitle:[NSString stringWithFormat:@"Shake %ld time(s)",runningCount] subtitle:[NSString stringWithFormat:@"This will shake the button %ld time(s)",runningCount] image:nil];
		item.view = view;
		
		[men addItem:item];
	}
	
	[men popUpMenuPositioningItem:nil
					   atLocation:NSMakePoint(sender.bounds.size.width,
											  sender.flipped ? sender.frame.size.height:0)
						   inView:sender];
}

- (void)showAlert:(NSMenuItem *)sender
{
	NSString *previousTitle = self.button.title;
	self.button.title = @"Wheeeeeeeeeeee, look at me go!";
	
	dispatch_async(dispatch_get_main_queue(), ^{
		CGFloat degreesInRadians = ((120) / (180.0 * M_PI));
		if (self.button.layer.anchorPoint.x < 0.499999 || self.button.layer.anchorPoint.x > 0.50000000001)
		{
			self.button.layer.anchorPoint = NSMakePoint(0.5, 0.5);
			self.button.layer.position = CGPointMake(self.button.layer.position.x+(self.button.frame.size.width/2.0),
												 self.button.layer.position.y+(self.button.frame.size.height/2.0));
		}
		CATransform3D zRotation = self.button.layer.transform;
		zRotation = CATransform3DRotate(CATransform3DIdentity, degreesInRadians, 0, 0, 1.0);
		CATransform3D zRotationMinus = self.button.layer.transform;
		zRotationMinus = CATransform3DRotate(CATransform3DIdentity, -degreesInRadians, 0, 0, 1.0);
		CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
		anim.fromValue = [NSValue valueWithCATransform3D:zRotationMinus];
		anim.toValue = [NSValue valueWithCATransform3D:zRotation];
		anim.duration = 0.07;
		NSString *title = ((ESSSubtitledMenuItemView *)sender.view).title;
		NSString *numberComponent = [title componentsSeparatedByString:@" "][1]; //don't do this with localized strings. Or, just don't do this ;)
		NSUInteger number = numberComponent.integerValue;
		anim.repeatCount = number;
		anim.removedOnCompletion = YES;
		anim.autoreverses = YES;
		
		[self.button.layer addAnimation:anim forKey:@"shake"];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(anim.duration*anim.repeatCount*2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			self.button.title = previousTitle;
		});
	});
}

@end
