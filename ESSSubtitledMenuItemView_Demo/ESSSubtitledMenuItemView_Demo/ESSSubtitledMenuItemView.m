//
//  ESSSubtitledMenuItemView.m
//
//  Created by Matthias Gansrigler on 23.11.2020.
//  Copyright © 2020-2021 Eternal Storms Software. All rights reserved.
//

#import "ESSSubtitledMenuItemView.h"

@interface ESSBaseCustomMenuItemView ()

@end

@implementation ESSBaseCustomMenuItemView

- (instancetype)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:NSMakeRect(0, 0, 1, 1)])
	{
		self.material = NSVisualEffectMaterialMenu;
		return self;
	}
	
	return nil;
}

- (BOOL)isEmphasized
{
	return YES;
}

- (NSVisualEffectState)state
{
	return NSVisualEffectStateActive;
}

- (NSVisualEffectBlendingMode)blendingMode
{
	return NSVisualEffectBlendingModeBehindWindow;
}

- (BOOL)allowsVibrancy
{
	return NO;
}

- (void)viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	
	while (self.trackingAreas.count != 0)
		[self removeTrackingArea:self.trackingAreas[0]];
	
	if (self.window == nil)
		return;
	
	NSTrackingArea *ta = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingActiveAlways|NSTrackingMouseEnteredAndExited|NSTrackingInVisibleRect|NSTrackingEnabledDuringMouseDrag owner:self userInfo:nil];
	[self addTrackingArea:ta];
}

- (void)mouseEntered:(NSEvent *)event
{
	if (@available(macOS 11.0, *))
	{
		self.maskImage = [NSImage imageWithSize:self.bounds.size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
			[[NSColor clearColor] set];
			[NSBezierPath fillRect:dstRect];
			
			[[NSColor blackColor] set];
			NSBezierPath *bp = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(5, 0, dstRect.size.width-10, dstRect.size.height) xRadius:4 yRadius:4];
			[bp fill];
			
			return YES;
		}];
	}
	
	self.material = NSVisualEffectMaterialSelection;
}

- (void)mouseExited:(NSEvent *)event
{
	self.material = NSVisualEffectMaterialMenu;
}

- (void)mouseDown:(NSEvent *)event
{
}

- (void)mouseUp:(NSEvent *)event
{
	if (self.material != NSVisualEffectMaterialSelection)
		return;
	
	self.material = NSVisualEffectMaterialMenu;
	[self setNeedsDisplay:YES];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.06 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		self.material = NSVisualEffectMaterialSelection;
		[self setNeedsDisplay:YES];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self.enclosingMenuItem.menu cancelTracking];
			
			if (self.enclosingMenuItem.target != nil && self.enclosingMenuItem.action != nil)
			{
				NSMethodSignature *sig = [self.enclosingMenuItem.target methodSignatureForSelector:self.enclosingMenuItem.action];
				NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
				inv.target = self.enclosingMenuItem.target;
				inv.selector = self.enclosingMenuItem.action;
				id obj = self.enclosingMenuItem;
				
				if (sig.numberOfArguments >= 3)
					[inv setArgument:&obj atIndex:2];
				
				[inv invokeWithTarget:inv.target];
			}
		});
	});
}

@end







@interface ESSSubtitledMenuItemView ()

@property (strong) NSString *title;
@property (strong) NSString *subtitle;

@property (strong) NSTextField *titleField;
@property (strong) NSTextField *subtitleField;

@end

@implementation ESSSubtitledMenuItemView

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(NSImage *)image
{
	NSAssert(title.length != 0, @"Title may not be nil - otherwise, use an ordinary NSMenuItem without .view instead");
	NSAssert(subtitle.length != 0, @"Subtitle may not be nil - otherwise, use an ordinary NSMenuItem without .view instead");
	
	if (self = [super initWithFrame:NSMakeRect(0, 0, 1, 1)])
	{
		self.title = title;
		self.subtitle = subtitle;
		[self setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
		[self setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
		[self setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
		[self setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
		
		NSImage *img = image.copy;
		
		NSImageView *iv = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
		iv.image = img;
		iv.imageScaling = NSImageScaleProportionallyUpOrDown;
		
		self.titleField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
		[self.titleField setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
		[self.titleField setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
		self.titleField.stringValue = title;
		self.titleField.font = [NSFont menuFontOfSize:12.0];
		self.titleField.textColor = [NSColor labelColor];
		
		self.subtitleField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
		[self.subtitleField setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
		[self.subtitleField setContentHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
		self.subtitleField.stringValue = subtitle;
		self.subtitleField.font = [NSFont menuFontOfSize:10];
		self.subtitleField.textColor = [NSColor secondaryLabelColor];
		
		self.titleField.bordered = self.subtitleField.bordered = NO;
		self.titleField.drawsBackground = self.subtitleField.drawsBackground = NO;
		self.titleField.editable = self.subtitleField.editable = self.titleField.selectable = self.subtitleField.selectable = NO;
		
		self.translatesAutoresizingMaskIntoConstraints = iv.translatesAutoresizingMaskIntoConstraints = self.titleField.translatesAutoresizingMaskIntoConstraints = self.subtitleField.translatesAutoresizingMaskIntoConstraints = NO;
		
		[self addSubview:iv];
		[self addSubview:self.titleField];
		[self addSubview:self.subtitleField];
		
		static CGFloat superviewLeadingTrailingDistance = 14.0;
		static CGFloat imageWidthAndHeight = 28.0;
		
		[NSLayoutConstraint activateConstraints:@[[iv.heightAnchor constraintEqualToConstant:imageWidthAndHeight],
												  [iv.widthAnchor constraintEqualToConstant:(img != nil ? imageWidthAndHeight:0)],
												  [iv.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:superviewLeadingTrailingDistance],
												  [iv.topAnchor constraintEqualToAnchor:self.topAnchor constant:4],
												  [iv.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-4],
												  
												  [self.titleField.leadingAnchor constraintEqualToAnchor:iv.trailingAnchor constant:(img != nil ? 4:0)],
												  [self.titleField.topAnchor constraintEqualToAnchor:iv.topAnchor],
												  [self.titleField.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-superviewLeadingTrailingDistance],
												  
												  [self.subtitleField.leadingAnchor constraintEqualToAnchor:self.titleField.leadingAnchor],
												  [self.subtitleField.bottomAnchor constraintEqualToAnchor:iv.bottomAnchor],
												  [self.subtitleField.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-superviewLeadingTrailingDistance],
												  
		]];
		[self setFrameSize:[self fittingSize]];
		
		return self;
	}
	
	return nil;
}

- (void)mouseEntered:(NSEvent *)event
{
	[super mouseEntered:event];
	
	self.titleField.textColor = self.subtitleField.textColor = [NSColor selectedMenuItemTextColor];
}

- (void)mouseExited:(NSEvent *)event
{
	[super mouseExited:event];
	
	self.titleField.textColor = [NSColor labelColor];
	self.subtitleField.textColor = [NSColor secondaryLabelColor];
}

@end
