//
//  STypingAnimation.m
//  STypedAnimationExample
//
//  Created by Dani Arnaout on 7/24/16.
//  Copyright © 2016 Saily. All rights reserved.
//

#import "STypingAnimation.h"

@interface STypingAnimation()
@property (strong, nonatomic) UILabel *cursorLabel;

@property (strong, nonatomic) NSMutableString *currentString;
@property (strong, nonatomic) NSArray *textArray;
@property (assign, nonatomic) NSInteger currentCharacterPosition;
@property (assign, nonatomic) NSInteger currentArrayPosition;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic, getter=isDeleting) BOOL deleting;
@property (assign, nonatomic, getter=isAnimatingCursor) BOOL animatingCursor;

@end

@implementation STypingAnimation

//-----------------------------------
// Designated Initializer
//-----------------------------------
#pragma mark - Designated Initializer

- (instancetype)initWithTextArray:(NSArray *)array {
  self = [super initWithFrame:CGRectMake(0, 0, 300, 100)];
  if (self) {
    [self setTextArray:array];
    [self awakeFromNib];
  }
  return self;
}

//-----------------------------------
// UIView Lifecycle
//-----------------------------------
#pragma mark - UIView Lifecycle

- (void)awakeFromNib {
  [super awakeFromNib];
  
  [self setDefaultValues];
  
  if (!self.animatingCursor) {
    [self addSubview:self.cursorLabel];
    [self blinkForever:self.cursorLabel];
    self.animatingCursor = YES;
  }
  
  [self performSelector:@selector(startLabelAnimation) withObject:nil afterDelay:self.startTypingDelay];
}

//------------------------------
// Lazy Initializers
//------------------------------
#pragma mark - Lazy Initializers

- (NSMutableString *)currentString {
  if (!_currentString) {
    _currentString = [NSMutableString stringWithCapacity:50];
  }
  return _currentString;
}

- (UILabel *)cursorLabel {
  if (!_cursorLabel) {
    _cursorLabel = [[UILabel alloc] init];
    _cursorLabel.text = @"|";
    _cursorLabel.font = self.font;
    _cursorLabel.textColor = self.textColor;
    [_cursorLabel sizeToFit];
    [self updateCursorPosition];
  }
  return _cursorLabel;
}

//---------------------------
// Public Methods
//---------------------------
#pragma mark - Public Methods

- (void)setTextArray:(NSArray *)array {
  if (!array.count) {
    NSLog(@"Error creating STypingAnimation view. Array should contain at least one string");
    return;
  }
  
  for (id string in array) {
    if (![string isKindOfClass:[NSString class]]) {
      NSLog(@"Error creating STypingAnimation view. Array elements must be of type NSString");
      return;
    }
  }
  
  _textArray = array;
  [self resetTypingAnimation];
}

//----------------------------
// Private Methods
//----------------------------
#pragma mark - Private Methods

- (void)setDefaultValues {
  if (self.typingSpeed <= 0) {
    self.typingSpeed = 0.5;
  }
  
  if (self.cursorBlinkSpeed <= 0) {
    self.cursorBlinkSpeed = 1;
  }
  
  if (self.startTypingDelay <= 0) {
    self.startTypingDelay = 0.5;
  }
  
  if (self.delayToStartDeleting <= 0) {
    self.delayToStartDeleting = 1;
  }
  
  if (self.deletingSpeed <= 0) {
    self.deletingSpeed = 0.1;
  }
}

- (void)resetTypingAnimation {
  self.text = @"";
  self.currentArrayPosition = 0;
  self.currentCharacterPosition = 0;
  self.currentString = [NSMutableString stringWithCapacity:50];
}

//----------------------------
// Label Methods
//----------------------------

- (CGRect)getBoundingRectForLabel {
  CGSize constrain = CGSizeMake(self.bounds.size.width, FLT_MAX);
  CGRect rect = [self.text boundingRectWithSize:constrain  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
  return rect;
}

- (NSString *)updateCurrentString {
  
  NSString *string = self.textArray[self.currentArrayPosition];
  
  if (!self.isDeleting) {
    if (self.textArray.count > self.currentArrayPosition) {
      NSRange range = NSMakeRange(self.currentCharacterPosition, 1);
      if (range.location != NSNotFound && range.location + range.length <= string.length) {
        NSString *nextCharacter = [string substringWithRange:range];
        [self.currentString appendString:nextCharacter];
        self.currentCharacterPosition++;
      } else {
        // End of range, it's time to delete
        self.deleting = YES;
        [self stopLabelAnimation];
        [self performSelector:@selector(startLabelAnimation) withObject:nil afterDelay:self.delayToStartDeleting];
      }
    }
  } else {
    // Deleting
    if (self.currentCharacterPosition > 0) {
      self.currentCharacterPosition--;
    }
    
    if ([self.currentString length] > 0) {
      self.currentString = [[string substringToIndex:self.currentCharacterPosition] mutableCopy];
    } else {
      // Done with the word, it's time for the next word
      self.deleting = NO;
      [self stopLabelAnimation];
      [self performSelector:@selector(startLabelAnimation) withObject:nil afterDelay:self.delayToStartDeleting];
      
      self.currentArrayPosition++;
      if (self.textArray.count <= self.currentArrayPosition) {
        // Repeat if all words has been used
        self.currentArrayPosition = 0;
        if (!self.loop) {
          [self.timer invalidate];
          [self.cursorLabel.layer removeAllAnimations];
        }
      }
    }
  }
  
  return self.currentString;
}

- (void)updateLabel {
  self.text = [self updateCurrentString];
  [self updateCursorPosition];
  [self handleCursorAlpha];
}

- (void)startLabelAnimation {
  self.timer = [NSTimer scheduledTimerWithTimeInterval:self.isDeleting?self.deletingSpeed:self.typingSpeed target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
}

- (void)stopLabelAnimation {
  [self.timer invalidate];
}

//----------------------------
// Cursor Methods
//----------------------------

- (void)handleCursorAlpha {
  if (self.deleting && [self.currentString isEqualToString:self.textArray[self.currentArrayPosition]]) {
    return;
  }
  
  [self.cursorLabel.layer removeAllAnimations];
  self.cursorLabel.alpha = 1;
  [self blinkForever:self.cursorLabel];
}

- (void)updateCursorPosition {
  CGRect rect = [self getBoundingRectForLabel];
  CGFloat originX = [self.currentString isEqualToString:@""]?0:rect.size.width;
  self.cursorLabel.frame = CGRectMake(originX, self.frame.size.height/2 - rect.size.height/2 - rect.size.height/10, 50, rect.size.height);
}

- (void)blinkForever:(UIView *)view {
  if ([view isKindOfClass:[UIView class]]) {
    [UIView animateWithDuration:self.cursorBlinkSpeed delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction animations:^{
      view.alpha = 0.0;
    } completion:NULL];
  }
}

@end
