//
//  MessageTableViewCell.m
//  GroupManagement
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MessageTableViewCell.h"
#import "SpeechBubbleView.h"

static UIColor* color = nil;

@interface MessageTableViewCell() {
    SpeechBubbleView *_bubbleView;
	UILabel *_label;
}
@end

@implementation MessageTableViewCell

+ (void)initialize
{
	if (self == [MessageTableViewCell class])
	{
		color = [UIColor colorWithRed:219/255.0 green:226/255.0 blue:237/255.0 alpha:1.0];
	}
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		// Create the speech bubble view
		_bubbleView = [[SpeechBubbleView alloc] initWithFrame:CGRectZero];
		_bubbleView.backgroundColor = color;
		_bubbleView.opaque = YES;
		_bubbleView.clearsContextBeforeDrawing = NO;
		_bubbleView.contentMode = UIViewContentModeRedraw;
		_bubbleView.autoresizingMask = 0;
		[self.contentView addSubview:_bubbleView];

		// Create the label
		_label = [[UILabel alloc] initWithFrame:CGRectZero];
		_label.backgroundColor = color;
		_label.opaque = YES;
		_label.clearsContextBeforeDrawing = NO;
		_label.contentMode = UIViewContentModeRedraw;
		_label.autoresizingMask = 0;
		_label.font = [UIFont systemFontOfSize:13];
		_label.textColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1.0];
		[self.contentView addSubview:_label];
	}
	return self;
}

- (void)layoutSubviews
{
	// This is a little trick to set the background color of a table view cell.
	[super layoutSubviews];
	self.backgroundColor = color;
}

- (void)setMessage:(MASMessage *)message
{
	CGPoint point = CGPointZero;

	// We display messages that are sent by the user on the right-hand side of
	// the screen. Incoming messages are displayed on the left-hand side.
	NSString* senderName;
	BubbleType bubbleType;
    self.bubbleSize = [SpeechBubbleView sizeForText:message.payloadTypeAsString];
    
    
    // Format the message date
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDoesRelativeDateFormatting:YES];
    NSString* dateString;

	if (!message.senderDisplayName)
	{
		bubbleType = BubbleTypeRighthand;
		senderName = NSLocalizedString(@"You", nil);
		point.x = self.bounds.size.width - self.bubbleSize.width;
		_label.textAlignment = NSTextAlignmentLeft;
        dateString = [formatter stringFromDate:[NSDate date]];
	}
	else
	{
		bubbleType = BubbleTypeLefthand;
        senderName = message.senderDisplayName; //message.senderName;
		_label.textAlignment = NSTextAlignmentRight;
        dateString = [formatter stringFromDate:message.sentTime];
	}

	// Resize the bubble view and tell it to display the message text
	CGRect rect;
	rect.origin = point;
    rect.size = self.bubbleSize;
	_bubbleView.frame = rect;
	[_bubbleView setText:message.payloadTypeAsString bubbleType:bubbleType];


	// Set the sender's name and date on the label
	_label.text = [NSString stringWithFormat:@"%@ @ %@", senderName, dateString];
	[_label sizeToFit];
	_label.frame = CGRectMake(8, self.bubbleSize.height, self.contentView.bounds.size.width - 16, 16);
}

@end
