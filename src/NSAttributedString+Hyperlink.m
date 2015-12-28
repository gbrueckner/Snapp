/* Copyright © 2012 Apple Inc. All Rights Reserved.
 *
 * This code was copied from Apple's Technical Q&A QA1487.
 */


#import "NSAttributedString+Hyperlink.h"
@import AppKit;


@implementation NSAttributedString (Hyperlink)


+ (instancetype)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL {

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:inString];
    NSRange range = NSMakeRange(0, [attrString length]);

    [attrString beginEditing];

    [attrString addAttribute:NSLinkAttributeName
                       value:[aURL absoluteString]
                       range:range];

    // make the text appear in blue
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[NSColor blueColor]
                       range:range];

    // next make the text appear with an underline
    [attrString addAttribute:NSUnderlineStyleAttributeName
                       value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                       range:range];

    [attrString endEditing];

    return [attrString autorelease];
}


@end
