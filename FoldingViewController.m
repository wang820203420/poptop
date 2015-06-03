//
//  FoldingViewController.m
//  poptop
//
//  Created by zhisu on 15/6/2.
//  Copyright (c) 2015年 zhisu. All rights reserved.
//

#import "FoldingViewController.h"
#import "FoldingView.h"



@interface FoldingViewController ()

@property(nonatomic) FoldingView *foldView;
@end

@implementation FoldingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor orangeColor];
    

    [self addFoldView];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self.foldView poke];
    
}

#pragma mark - Private instance methods

- (void)addFoldView
{
    CGFloat padding = 30.f;
    CGFloat width = CGRectGetWidth(self.view.bounds) - padding * 2;
    CGRect frame = CGRectMake(0, 0, width, width);
    
    self.foldView = [[FoldingView alloc] initWithFrame:frame
                                                 image:[UIImage imageNamed:@"1.jpg"]];
    self.foldView.center = self.view.center;
    [self.view addSubview:self.foldView];
}

@end
