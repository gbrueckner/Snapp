/* Copyright © 2012 Apple Inc. All Rights Reserved.
 *
 * This code was copied from Apple's Technical Q&A QA1487.
 */


@import Foundation;


@interface NSAttributedString (Hyperlink)

+ (instancetype)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;

@end
