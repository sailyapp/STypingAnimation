//
//  ViewController.m
//  STypedAnimationExample
//
//  Created by Dani Arnaout on 7/24/16.
//  Copyright © 2016 Saily. All rights reserved.
//

#import "ViewController.h"
#import "STypingAnimation.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet STypingAnimation *typingView;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.typingView setTextArray:@[@"Hello World!",@"It's working!"]];
  
  // (Optional) Properties to modify
  self.typingView.typingSpeed = 0.5;
  self.typingView.cursorBlinkSpeed = 1;
  self.typingView.startTypingDelay = 1;
  self.typingView.delayToStartDeleting = 1;
  self.typingView.deletingSpeed = 0.1;
  self.typingView.loop = YES;
}

@end
