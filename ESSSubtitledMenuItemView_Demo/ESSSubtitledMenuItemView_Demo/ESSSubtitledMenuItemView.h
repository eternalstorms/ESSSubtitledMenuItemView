//
//  ESSSubtitledMenuItemView.h
//
//  Created by Matthias Gansrigler on 23.11.2020.
//  Copyright © 2020-2021 Eternal Storms Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @abstract		The base class for NSMenuItem.view views. Only provides hover effects, and the execution of the menu item's action on its target. Must be subclassed to be actually useful, as this does not contain any view setup.
 */
API_AVAILABLE(macos(10.11))
@interface ESSBaseCustomMenuItemView : NSVisualEffectView

@end




/*!
 @abstract		Provides an NSMenuItem.view with an icon, title and subtitle.
 */
API_AVAILABLE(macos(10.11))
@interface ESSSubtitledMenuItemView : ESSBaseCustomMenuItemView

@property (readonly) NSString *title;
@property (readonly) NSString *subtitle;

/*!
 @abstract		Instantiates a view to use with an @c NSMenuItem object's -view property, showing an icon, title and subtitle.
 @param 		title The title of the menu item. May not be nil. (Otherwise you could just use NSMenuItem itself, without the view)
 @param			subtitle The subtitle of the menu item. May not be nil. (Otherwise you could just use NSMenuItem itself, without the view)
 @param			image The image of the menu item. May be nil.
 */
- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(NSImage *)image;

@end
