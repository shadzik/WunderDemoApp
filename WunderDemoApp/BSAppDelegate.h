//
//  BSAppDelegate.h
//  WunderDemoApp
//
//  Created by Bartosz Świątek on 19.08.2013.
//  Copyright (c) 2013 Bartosz Świątek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
