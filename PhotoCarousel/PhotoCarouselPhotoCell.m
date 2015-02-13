
#import "PhotoCarouselPhotoCell.h"

@implementation PhotoCarouselPhotoCell

- (void)setSelected: (BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)drawRect: (CGRect)rect
{
    [super drawRect: rect];
    
    [self.image drawInRect: rect];
    
    [self drawSelectionBubbleInRect: rect];
}

- (void)drawSelectionBubbleInRect: (CGRect)rect
{
    NSString *icon = @"SelectionBubble";
    
    if (self.selected)
        icon = @"SelectionBubbleChecked";
    
    UIImage *checkedIcon = [UIImage imageNamed: icon];
    
    if (checkedIcon.size.width > self.selectionBubbleRect.size.width)
    {
        // checkedIcon cannot fit into selectionBubbleRect
        // left align
        [checkedIcon drawAtPoint: CGPointMake (CGRectGetMinX (rect) , CGRectGetMaxY (rect) - checkedIcon.size.height)];
    } else
    {
        // right align
        [checkedIcon drawAtPoint: CGPointMake (CGRectGetMaxX (self.selectionBubbleRect) - checkedIcon.size.width, CGRectGetMaxY (self.selectionBubbleRect) - checkedIcon.size.height)];
    }
}

@end
