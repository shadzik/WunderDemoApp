//
//  BSDetailViewController.h
//  WunderDemoApp
//
//  Created by Bartosz Świątek on 19.08.2013.
//  Copyright (c) 2013 Bartosz Świątek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *sortDescriptionLabel;
@end
