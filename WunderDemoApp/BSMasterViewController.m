//
//  BSMasterViewController.m
//  WunderDemoApp
//
//  Created by Bartosz Świątek on 19.08.2013.
//  Copyright (c) 2013 Bartosz Świątek. All rights reserved.
//

#import "BSMasterViewController.h"
#import "BSDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BSMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation BSMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (UIView *)createHeaderView:(BOOL)withAnimation
{
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    addField = [[BSTextField alloc] initWithFrame:CGRectMake(10,10, headerView.frame.size.width-20, 40)];
    addField.delegate = self;
    addField.placeholder = @"Add an item...";
    addField.backgroundColor = [UIColor whiteColor];
    addField.textColor = [UIColor blackColor];
    addField.alpha = 0.8;
    addField.keyboardType = UIKeyboardTypeAlphabet;
    addField.returnKeyType = UIReturnKeyNext;
    [headerView addSubview:addField];
    if (withAnimation) {
        addField.alpha = 0.0;
        //addField.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        //addField.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
        addField.alpha = 0.8;
        [UIView commitAnimations];
    }
    
    return headerView;
}

- (void)destroyHeaderView:(BOOL)withAnimation
{
    if (withAnimation) {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            addField.alpha = 0.0;
            //self.tableView.tableHeaderView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        } completion:^(BOOL finished){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.15];
            [UIView setAnimationDelegate:self];
            self.tableView.tableHeaderView = nil;
            [UIView commitAnimations];
        }];
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)saveContext
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([addField.text length] > 0) {
        [self insertNewObject:nil withTitle:addField.text];
        addField.text = nil;
        // save new order here too but only if text field wasn't empty
        fetchedObjects = [[self.fetchedResultsController fetchedObjects] mutableCopy];
        int i = 0;
        for (NSManagedObject *row in fetchedObjects) {
            BOOL isComplete = [[row valueForKey:@"finished"] boolValue];
            if (!isComplete) {
                [row setValue:[NSNumber numberWithInt:i++] forKey:@"sortOrder"];
            }
        }
        // Save the context.
        [self saveContext];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditing)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
    [self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
    [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self.navigationItem setLeftBarButtonItem:self.editButtonItem animated:YES];
    self.navigationItem.rightBarButtonItem = nil;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    addField.text = nil;
}

- (void)cancelEditing
{
    [addField resignFirstResponder];
}

- (void)doneEditing
{
    if ([addField.text length] > 0) {
        [self insertNewObject:nil withTitle:addField.text];
    }
    [addField resignFirstResponder];
    // save new order here too
    fetchedObjects = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    int i = 0;
    for (NSManagedObject *row in fetchedObjects) {
        BOOL isComplete = [[row valueForKey:@"finished"] boolValue];
        if (!isComplete) {
            [row setValue:[NSNumber numberWithInt:i++] forKey:@"sortOrder"];
        }
    }
    // Save the context.
    [self saveContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.tableHeaderView = [self createHeaderView:NO];
    self.tableView.allowsSelectionDuringEditing = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    fetchedObjects = [[self.fetchedResultsController fetchedObjects] mutableCopy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender withTitle:(NSString *)title
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    //[newManagedObject setValue:[NSDate date] forKey:@"sortOrder"];
    [newManagedObject setValue:title forKey:@"title"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table View

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing)
    {
        [self destroyHeaderView:YES];
        for (int i = 200; i < [fetchedObjects count] + 200; i++) {
            ((UIImageView *)[self.view viewWithTag:i]).userInteractionEnabled = NO;
            ((UIImageView *)[self.view viewWithTag:i]).alpha = 0.4;
        }
    } else {
        self.tableView.tableHeaderView = [self createHeaderView:YES];
        for (int i = 200; i < [fetchedObjects count] + 200; i++) {
            ((UIImageView *)[self.view viewWithTag:i]).userInteractionEnabled = YES;
            ((UIImageView *)[self.view viewWithTag:i]).alpha = 1.0;
        }
        // save new order
        int i = 0;
        for (NSManagedObject *row in fetchedObjects) {
            BOOL isComplete = [[row valueForKey:@"finished"] boolValue];
            if (!isComplete) {
                [row setValue:[NSNumber numberWithInt:i++] forKey:@"sortOrder"];
            }
        }
        
        [self saveContext];
        
//        if (![self.fetchedResultsController performFetch:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"Sections: %d", [[self.fetchedResultsController sections] count]);
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    //[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.alpha = 1.0;
    
    [self configureCell:cell atIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [fetchedObjects removeObjectAtIndex:indexPath.row];
        //NSLog(@"Index Path: %d", indexPath.row);
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should be re-orderable.
    NSManagedObject *row = [fetchedObjects objectAtIndex:indexPath.row];
    BOOL isComplete = [[row valueForKey:@"finished"] boolValue];
    if (isComplete) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (fetchedObjects == nil) {
        return;
    }
    
    id movingRow = [fetchedObjects objectAtIndex:sourceIndexPath.row];
    [fetchedObjects removeObjectAtIndex:sourceIndexPath.row];
    [fetchedObjects insertObject:movingRow atIndex:destinationIndexPath.row];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"title"] description];
    BOOL isComplete = [[object valueForKey:@"finished"] boolValue];
    UIImage *checkbox = [[UIImage alloc] init];
    if (isComplete) {
        checkbox = [UIImage imageNamed:@"checked.png"];
        cell.textLabel.enabled = NO;
        //cell.backgroundColor = [UIColor colorWithRed:144.0/255.0 green:238.0/255.0 blue:144.0/255.0 alpha:1.0];
        cell.alpha = 0.8;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary* attributes = @{
                                     NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                      };
        
        NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:cell.textLabel.text attributes:attributes];
        cell.textLabel.attributedText = attrText;
    } else {
        checkbox = [UIImage imageNamed:@"unchecked.png"];
        cell.textLabel.enabled = YES;
        //cell.backgroundColor = [UIColor whiteColor];
        cell.alpha = 1.0;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.imageView.image = checkbox;
    cell.imageView.tag = indexPath.row + 200;
    cell.accessoryType = UITableViewCellAccessoryNone;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemFinished:)];
    cell.imageView.userInteractionEnabled = YES;
    [cell.imageView addGestureRecognizer:tap];
}

- (void) itemFinished:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint tapLocation = [tapRecognizer locationInView:self.tableView];
    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    fetchedObjects = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    NSManagedObject *object = [fetchedObjects objectAtIndex:tappedIndexPath.row];
    BOOL isComplete = [[object valueForKey:@"finished"] boolValue];
    NSInteger sortPosition = [[object valueForKey:@"sortOrder"] integerValue];
    
    if (isComplete) {
        if (sortPosition >= 100)
            sortPosition = sortPosition - 100;
        [object setValue:[NSNumber numberWithBool:NO] forKey:@"finished"];
    } else {
        if (sortPosition < 100)
            sortPosition = sortPosition + 100;
        [object setValue:[NSNumber numberWithBool:YES] forKey:@"finished"];
    }
    [object setValue:[NSNumber numberWithInteger:sortPosition] forKey:@"sortOrder"];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedIndexPath] withRowAnimation: UITableViewRowAnimationFade];
    // Save the context.
    [self saveContext];
}

@end
