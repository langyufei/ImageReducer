//
//  PNGDropView.m
//  ImageReducer
//
//  Created by Jonas Gessner on 21.10.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import "PNGDropView.h"

@implementation PNGDropView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];

    if (self)
    {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }

    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return [self.draggingDelegate draggingEntered:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    return [self.draggingDelegate performDragOperation:sender];
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
    [self.draggingDelegate draggingEnded:sender];
}

@end
