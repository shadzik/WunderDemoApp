//
//  BSMasterViewController.h
//  WunderDemoApp
//
//  Created by Bartosz Świątek on 19.08.2013.
//  Copyright (c) 2013 Bartosz Świątek. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "BSTextField.h"

@interface BSMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate,UITextFieldDelegate>
{
    BSTextField *addField;
    UIView *headerView;
    NSMutableArray *fetchedObjects;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
