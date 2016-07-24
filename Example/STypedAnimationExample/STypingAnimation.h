//
//  STypingAnimation.h
//  STypedAnimationExample
//
//  Created by Dani Arnaout on 7/24/16.
//  Copyright © 2016 Saily. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STypingAnimation : UILabel

@property (assign, nonatomic) CGFloat typingSpeed;
@property (assign, nonatomic) CGFloat cursorBlinkSpeed;
@property (assign, nonatomic) CGFloat startTypingDelay;
@property (assign, nonatomic) CGFloat delayToStartDeleting;
@property (assign, nonatomic) CGFloat deletingSpeed;
@property (assign, nonatomic) CGFloat loop;

// Designated Initializer
- (instancetype)initWithTextArray:(NSArray *)array;

// Public methods
- (void)setTextArray:(NSArray *)array;

@end
