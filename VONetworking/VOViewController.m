//
//  VOViewController.m
//  VONetworking
//
//  Created by heguangzhong2009@gmail.com on 05/02/2018.
//  Copyright (c) 2018 heguangzhong2009@gmail.com. All rights reserved.
//

#import "VOViewController.h"
#import "VONetworking.h"
@interface VOViewController ()

@end

@implementation VOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [VONetworking baseUrl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
