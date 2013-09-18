//
//  BSDetailViewController.m
//  WunderDemoApp
//
//  Created by Bartosz Świątek on 19.08.2013.
//  Copyright (c) 2013 Bartosz Świątek. All rights reserved.
//

#import "BSDetailViewController.h"

@interface BSDetailViewController ()
- (void)configureView;
@end

@implementation BSDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.title = [[self.detailItem valueForKey:@"title"] description];
        self.detailDescriptionLabel.text = [NSString stringWithFormat:@"%@", [[self.detailItem valueForKey:@"timeStamp"] description]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
