//
//  ViewController.m
//  ImageReducer
//
//  Created by Jonas Gessner on 21.10.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import "ViewController.h"
#import "PNGDropView.h"

@interface ViewController()<NSTableViewDataSource, NSTableViewDelegate>
@property (strong, nonatomic) NSArray *imageAry;
@property (strong, nonatomic) NSArray *imageNameAry;
@property (strong, nonatomic) NSString *destPath;
@end

@implementation ViewController


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.imageAry.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *result = nil;
    NSImage *theImage = self.imageAry[row];

    if ([tableColumn.identifier isEqualToString:@"column_number_cell"])
    {
        result = [tableView makeViewWithIdentifier:@"column_number_cell" owner:self];
        result.textField.stringValue = [NSString stringWithFormat:@"%ld", (long)(row + 1)];
    }
    else if ([tableColumn.identifier isEqualToString:@"column_number_preview"])
    {
        result = [tableView makeViewWithIdentifier:@"column_number_preview" owner:self];
        result.imageView.image = theImage;
    }
    else if ([tableColumn.identifier isEqualToString:@"column_number_resolution"])
    {
        result = [tableView makeViewWithIdentifier:@"column_number_resolution" owner:self];
        
        NSString *fileName = [self.imageNameAry[row] stringByDeletingPathExtension];
        
        CGFloat scale = 3;
        NSArray *componentsOfname = [fileName componentsSeparatedByString:@"@"];
        if (componentsOfname.count > 1) {
            result.textField.stringValue = [NSString stringWithFormat:@"%.f * %.f", theImage.size.width, theImage.size.height];
        }
        else {
            result.textField.stringValue = [NSString stringWithFormat:@"%.f * %.f", theImage.size.width / scale, theImage.size.height / scale];
        }
    }
    else if ([tableColumn.identifier isEqualToString:@"column_number_image_name"])
    {
        result = [tableView makeViewWithIdentifier:@"column_number_image_name" owner:self];
        result.textField.stringValue = self.imageNameAry[row];
    }

    return result;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSArray *filePaths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    BOOL anyFileValid = NO;

    for (NSString *path in filePaths)
    {
        if ([[path.pathExtension lowercaseString] isEqualToString:@"png"] || [[path.pathExtension lowercaseString] isEqualToString:@"jpg"])
        {
            anyFileValid = YES;
            break;
        }
    }

    return (anyFileValid ? NSDragOperationCopy : NSDragOperationNone);
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSArray *filePaths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    NSMutableArray *images = [NSMutableArray array];
    NSMutableArray *imageNames = [NSMutableArray array];
    NSString *destPath = nil;

    for (NSString *path in filePaths)
    {
        if ([path.pathExtension caseInsensitiveCompare:@"png"] || [path.pathExtension caseInsensitiveCompare:@"jpg"])
        {
            NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];

            if (img)
            {
                [images addObject:img];
                [imageNames addObject:path.pathComponents.lastObject];
                
                if (destPath.length < 1) {
                    destPath =[path stringByDeletingLastPathComponent];
                }
            }
        }
    }
    
    self.imageAry = images;
    self.imageNameAry = imageNames;
    self.destPath = destPath;

    return images.count > 0;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
    self.destPathLabel.stringValue = self.destPath;
    [self.tableView reloadData];
}

- (IBAction)destBtnClicked:(NSButton *)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *theDoc = [[panel URLs] firstObject];
            self.destPath = theDoc.path;
            self.destPathLabel.stringValue = theDoc.path;
        }
    }];
}

- (IBAction)goBtnClicked:(NSButton *)sender
{
    for (NSUInteger idx = 0; idx < self.imageAry.count; idx++)
    {
        NSImage *img = self.imageAry[idx];
        NSString *naturalFilename = [self.imageNameAry[idx] stringByDeletingPathExtension];
        NSString *extension = [self.imageNameAry[idx] pathExtension];
        
        CGFloat scale = 3;
        CGSize naturalSize = CGSizeZero;
        NSArray *componentsOfname = [naturalFilename componentsSeparatedByString:@"@"];
        if (componentsOfname.count > 1) {
            scale = [[componentsOfname lastObject] integerValue];
            naturalSize = img.size;
            naturalFilename = [componentsOfname firstObject];
        }
        else {
            naturalSize = CGSizeMake(img.size.width / scale, img.size.height / scale);
        }
        
        for (NSUInteger i = 1; i <= scale; i++)
        {
            NSString *newFilename = (i > 1 ? [naturalFilename stringByAppendingFormat:@"@%lux.%@", (unsigned long)i, extension] : [naturalFilename stringByAppendingPathExtension:extension]);
            newFilename = [self.destPath stringByAppendingPathComponent:newFilename];
            
            if (i == scale)
            {
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                if ([fileMgr fileExistsAtPath:newFilename]) {
                    break;
                }
            }
            
            CGFloat screenScale = [[NSScreen mainScreen] backingScaleFactor];
            
            NSSize currentSize = (NSSize) {(naturalSize.width * (CGFloat)i) / screenScale, (naturalSize.height * (CGFloat)i) / screenScale };
            NSRect rect = (NSRect) {NSZeroPoint, currentSize };
            
            NSImage *newImage = [[NSImage alloc] initWithSize:currentSize];
            
            [newImage lockFocus];
            [img drawInRect:rect];
            [newImage unlockFocus];
            
            CGImageRef newImg = [newImage CGImageForProposedRect:&rect context:nil hints:nil];
            
            NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:newImg];
            
            NSData *data = [rep representationUsingType:([extension isEqualToString:@"png"] ? NSPNGFileType : NSJPEGFileType) properties:nil];
            
            if (![data writeToFile:newFilename atomically:YES]) {
                NSLog(@"Unable to save file: %@", newFilename);
            }
        }
    }
}


 - (BOOL)performDragOperaftion:(id <NSDraggingInfo>)sender
 {
     NSArray *filePaths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
     BOOL anyFileValid = NO;

     for (NSString *path in filePaths)
     {
         NSString *extension = [path.pathExtension lowercaseString];

         if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"])
         {
             CGFloat scale = (CGFloat)[[[[path.pathComponents.lastObject stringByDeletingPathExtension] componentsSeparatedByString:@"@"] lastObject] integerValue];

             if (scale > 1)
             {
                 NSString *scaleString = [NSString stringWithFormat:@"@%ix", (int)scale];
                 NSString *naturalFilename = [path stringByDeletingPathExtension];
                 naturalFilename = [naturalFilename substringToIndex:naturalFilename.length - scaleString.length];

                 NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
                 CGSize naturalSize = img.size;

                 for (NSUInteger i = 1; i < scale; i++)
                 {
                     CGFloat screenScale = [[NSScreen mainScreen] backingScaleFactor];

                     NSSize currentSize = (NSSize) {(naturalSize.width * (CGFloat)i) / screenScale, (naturalSize.height * (CGFloat)i) / screenScale };
                     NSRect rect = (NSRect) {NSZeroPoint, currentSize };

                     NSImage *newImage = [[NSImage alloc] initWithSize:currentSize];

                     [newImage lockFocus];
                     [img drawInRect:rect];
                     [newImage unlockFocus];

                     NSString *newFilename = (i > 1 ? [naturalFilename stringByAppendingFormat:@"@%lux.%@", (unsigned long)i, extension] : [naturalFilename stringByAppendingPathExtension:extension]);

                     CGImageRef newImg = [newImage CGImageForProposedRect:&rect context:nil hints:nil];

                     NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:newImg];

                     NSData *data = [rep representationUsingType:([extension isEqualToString:@"png"] ? NSPNGFileType : NSJPEGFileType) properties:nil];

                     BOOL ok = [data writeToFile:newFilename atomically:YES];

                     if (ok)
                     {
                         anyFileValid = YES;
                     }
                 }
             }
         }
     }

     return anyFileValid;
 }
 

@end
