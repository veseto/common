//
//  CEAppDelegate.h
//  CommonExpensesApp
//
//  Created by veseto on 16.02.13.
//  Copyright (c) 2013 г. Vesela Popova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
#import "CEUser.h"
#import "CircleDefinition.h"

@interface CEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain, nonatomic) UINavigationController *navigationController;
@property (retain, nonatomic) MFSideMenu *sideMenu;

@property CEUser *currentUser;
@property CircleDefinition *currentCircle;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
