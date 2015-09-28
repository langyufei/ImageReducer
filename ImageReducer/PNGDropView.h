//
//  PNGDropView.h
//  ImageReducer
//
//  Created by Jonas Gessner on 21.10.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PNGDropViewDraggingDelegate;

@interface PNGDropView : NSView

@property (weak, nonatomic) IBOutlet id<PNGDropViewDraggingDelegate> draggingDelegate;

@end


@protocol PNGDropViewDraggingDelegate <NSObject>

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
- (void)draggingEnded:(id <NSDraggingInfo>)sender;

@end