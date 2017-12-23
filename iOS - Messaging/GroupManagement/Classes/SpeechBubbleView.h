//
//  SpeechBubbleView.h
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

typedef enum
{
	BubbleTypeLefthand = 0,
	BubbleTypeRighthand,
}
BubbleType;

// A UIView that shows a speech bubble
@interface SpeechBubbleView : UIView 

// Calculates how big the speech bubble needs to be to fit the specified text
+ (CGSize)sizeForText:(NSString*)text;

// Configures the speech bubble
- (void)setText:(NSString*)text bubbleType:(BubbleType)bubbleType;

@end
