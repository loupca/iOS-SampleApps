//
//  SpeechBubbleView.m
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

@import UIKit;

#import "SpeechBubbleView.h"

static UIFont* font = nil;
static UIImage* lefthandImage = nil;
static UIImage* righthandImage = nil;

const CGFloat VertPadding = 4;       // additional padding around the edges
const CGFloat HorzPadding = 4;

const CGFloat TextLeftMargin = 17;   // insets for the text
const CGFloat TextRightMargin = 15;
const CGFloat TextTopMargin = 10;
const CGFloat TextBottomMargin = 11;

const CGFloat MinBubbleWidth = 50;   // minimum width of the bubble
const CGFloat MinBubbleHeight = 40;  // minimum height of the bubble

const CGFloat WrapWidth = 200;       // maximum width of text in the bubble

@interface SpeechBubbleView() {
    NSString *_text;
	BubbleType _bubbleType;
}
@end

@implementation SpeechBubbleView

+ (void)initialize
{
	if (self == [SpeechBubbleView class])
	{
		font = [UIFont systemFontOfSize:[UIFont systemFontSize]];

		lefthandImage = [[UIImage imageNamed:@"BubbleLefthand"]
			stretchableImageWithLeftCapWidth:20 topCapHeight:19];

		righthandImage = [[UIImage imageNamed:@"BubbleRighthand"]
			stretchableImageWithLeftCapWidth:20 topCapHeight:19];
	}
}

+ (CGSize)sizeForText:(NSString*)text
{
	CGSize textSize = [text sizeWithFont:font
		constrainedToSize:CGSizeMake(WrapWidth, 9999)
		lineBreakMode:NSLineBreakByWordWrapping];

	CGSize bubbleSize;
	bubbleSize.width = textSize.width + TextLeftMargin + TextRightMargin;
	bubbleSize.height = textSize.height + TextTopMargin + TextBottomMargin;

	if (bubbleSize.width < MinBubbleWidth)
		bubbleSize.width = MinBubbleWidth;

	if (bubbleSize.height < MinBubbleHeight)
		bubbleSize.height = MinBubbleHeight;

	bubbleSize.width += HorzPadding*2;
	bubbleSize.height += VertPadding*3;

	return bubbleSize;
}

- (void)drawRect:(CGRect)rect
{
	[self.backgroundColor setFill];
	UIRectFill(rect);

	CGRect bubbleRect = CGRectInset(self.bounds, VertPadding, HorzPadding);

	CGRect textRect;
	textRect.origin.y = bubbleRect.origin.y + TextTopMargin;
	textRect.size.width = bubbleRect.size.width - TextLeftMargin - TextRightMargin;
	textRect.size.height = bubbleRect.size.height - TextTopMargin - TextBottomMargin;

	if (_bubbleType == BubbleTypeLefthand)
	{
		[lefthandImage drawInRect:bubbleRect];
		textRect.origin.x = bubbleRect.origin.x + TextLeftMargin;
	}
	else
	{
		[righthandImage drawInRect:bubbleRect];
		textRect.origin.x = bubbleRect.origin.x + TextRightMargin;
	}

	[[UIColor blackColor] set];
	[_text drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByWordWrapping];
}

- (void)setText:(NSString*)newText bubbleType:(BubbleType)newBubbleType
{
	_text = [newText copy];
	_bubbleType = newBubbleType;
	[self setNeedsDisplay];
}
@end
