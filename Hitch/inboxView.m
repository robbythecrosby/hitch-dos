//
//  inboxView.m
//  Hitch
//
//  Created by Robert Crosby on 8/9/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "inboxView.h"

@interface inboxView ()

@end

@implementation inboxView

- (void)viewDidLoad {
    scroll.contentSize = CGSizeMake([References screenWidth], scroll.frame.size.height);
    scroll.frame = CGRectMake(0, menuBar.frame.origin.y+menuBar.frame.size.height, [References screenWidth], [References screenHeight]-menuBar.frame.size.height);
    [References createLine:self.view xPos:0 yPos:menuBar.frame.origin.y+menuBar.frame.size.height inFront:TRUE];
    [References cardshadow:driveShadow];
    [References cornerRadius:driveCard radius:8.0f];
    [References cardshadow:driveRequestsShadow];
    [References cornerRadius:driveRequestsCard radius:8.0f];
    [References cornerRadius:noDriveLabel radius:8.0f];
    [References cardshadow:ridesShadow];
    [References cornerRadius:ridesCard radius:8.0f];
    [super viewDidLoad];
    
    [self getMyDrive];
    [self getMyRides];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    openDriveButton.hidden = YES;
    drivePriceShadow.hidden = YES;
    drivePrice.hidden = YES;
    driveRequestsTable.hidden = YES;
    noRequestsLabel.hidden = NO;
    noDriveLabel.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getMyRides {
    myRideRecords = [[NSMutableArray alloc] init];
    myRides = [[NSMutableArray alloc] init];
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"email = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]];
    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"People" predicate:predicate];
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    if (results.count > 0) {
                    CKRecord *record = results[0];
                    NSMutableArray *ridesToGet = [record valueForKey:@"myRides"];
                    if (ridesToGet.count > 0) {
                        CKContainer *defaultContainer = [CKContainer defaultContainer];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rideID IN %@)", ridesToGet];
                        CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
                        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Rides" predicate:predicate];
                        [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
                            if (!error) {
                                if (results.count > 0) {
                                    [myRides removeAllObjects];
                                    [myRideRecords removeAllObjects];
                                    for (int a = 0; a < results.count; a++) {
                                        CKRecord *record = results[a];
                                        NSDate *date = [record valueForKey:@"date"];
                                        NSDate *time = [record valueForKey:@"time"];
                                        NSString *name = [record valueForKey:@"name"];
                                        NSString *plainStart = [record valueForKey:@"plainStart"];
                                        NSString *plainEnd = [record valueForKey:@"plainEnd"];
                                        NSLog(@"%@",plainEnd);
                                        NSNumber *seats = [record valueForKey:@"seats"];
                                        NSNumber *price = [record valueForKey:@"price"];
                                        NSString *rideID = [record valueForKey:@"rideID"];
                                        NSMutableArray *messages = [record valueForKey:@"messages"];
                                        NSMutableArray *riders = [record valueForKey:@"riders"];
                                        NSMutableArray *requests = [record valueForKey:@"requests"];
                                        NSMutableArray *payments = [record valueForKey:@"payments"];
                                        CLLocation *start = [record valueForKey:@"start"];
                                        CLLocation *end = [record valueForKey:@"end"];
                                        rideObject *ride = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd andPhone:[record valueForKey:@"email"] andRequests:requests andPayments:payments andID:rideID];
                                        [myRideRecords addObject:results[a]];
                                        [myRides addObject:ride];
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^(void){
                                        noRidesLabel.hidden = YES;
                                        rideTable.hidden = NO;
                                        [rideTable reloadData];
                                    });
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^(void){
                                    noRidesLabel.hidden = NO;
                                    rideTable.hidden = YES;
                                    });
                                }
                            } else {
                                NSLog(@"%@",error.localizedDescription);
                            }
                        }];
                    } else {
                        noRidesLabel.hidden = NO;
                        rideTable.hidden = YES;
                    }
                }
                });
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
//    myRideRecords = [[NSMutableArray alloc] init];
//    myRides = [[NSMutableArray alloc] init];
//    NSString *string = [NSString stringWithFormat:@"riders IN '%@' || requests IN '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
//    CKContainer *defaultContainer = [CKContainer defaultContainer];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
//    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
//    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Rides" predicate:predicate];
//    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
//        if (!error) {
//            if (results.count > 0) {
//                [myRides removeAllObjects];
//                [myRideRecords removeAllObjects];
//                for (int a = 0; a < results.count; a++) {
//                    CKRecord *record = results[a];
//                    NSDate *date = [record valueForKey:@"date"];
//                    NSDate *time = [record valueForKey:@"time"];
//                    NSString *name = [record valueForKey:@"name"];
//                    NSString *plainStart = [record valueForKey:@"plainStart"];
//                    NSString *plainEnd = [record valueForKey:@"plainEnd"];
//                    NSNumber *seats = [record valueForKey:@"seats"];
//                    NSNumber *price = [record valueForKey:@"price"];
//                    NSMutableArray *messages = [record valueForKey:@"messages"];
//                    NSMutableArray *riders = [record valueForKey:@"riders"];
//                    NSMutableArray *requests = [record valueForKey:@"requests"];
//                    CLLocation *start = [record valueForKey:@"start"];
//                    CLLocation *end = [record valueForKey:@"end"];
//                    rideObject *ride = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd andPhone:[record valueForKey:@"email"] andRequests:requests];
//                    [myRideRecords addObject:results[a]];
//                    [myRides addObject:ride];
//                }
//                dispatch_async(dispatch_get_main_queue(), ^(void){
//                    noRidesLabel.hidden = YES;
//                    rideTable.hidden = NO;
//                    [rideTable reloadData];
//                });
//            } else {
//                dispatch_async(dispatch_get_main_queue(), ^(void){
//                    noRidesLabel.hidden = NO;
//                    rideTable.hidden = YES;
//                });
//            }
//        } else {
//            NSLog(@"%@",error.localizedDescription);
//        }
//    }];
}

-(void)getMyDrive {
    NSString *string = [NSString stringWithFormat:@"email = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Rides" predicate:predicate];
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            if (results.count > 0) {
                
                CKRecord *record = results[0];
                myDriveRecord = record;
                NSDate *date = [record valueForKey:@"date"];
                NSDate *time = [record valueForKey:@"time"];
                NSString *name = [record valueForKey:@"name"];
                NSString *plainStart = [record valueForKey:@"plainStart"];
                NSString *plainEnd = [record valueForKey:@"plainEnd"];
                NSNumber *seats = [record valueForKey:@"seats"];
                NSNumber *price = [record valueForKey:@"price"];
                NSMutableArray *messages = [record valueForKey:@"messages"];
                NSMutableArray *riders = [record valueForKey:@"riders"];
                NSMutableArray *requests = [record valueForKey:@"requests"];
                NSMutableArray *payments = [record valueForKey:@"payments"];
                CLLocation *start = [record valueForKey:@"start"];
                CLLocation *end = [record valueForKey:@"end"];
                NSString *rideID = [record valueForKey:@"rideID"];
                myDrive = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd andPhone:[record valueForKey:@"email"] andRequests:requests andPayments:payments andID:rideID];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    noDriveLabel.hidden = YES;
                    driveFrom.text = myDrive.plainStart;
                    driveTo.text = myDrive.plainEnd;
                    driveSeats.text = [NSString stringWithFormat:@"%i",myDrive.seats.intValue];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
                    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
                    [timeFormatter setDateFormat:@"h a"];
                    driveDate.text = [NSString stringWithFormat:@"%@ around %@",[dateFormatter stringFromDate:myDrive.date],[timeFormatter stringFromDate:myDrive.date]];
                    [References cornerRadius:drivePrice radius:8.0f];
                    [References cardshadow:drivePriceShadow];
                    drivePriceShadow.hidden = NO;
                    openDriveButton.hidden = NO;
                    drivePrice.hidden = NO;
                    if (myDrive.price.intValue > 0) {
                        drivePrice.text = [NSString stringWithFormat:@"$%i",myDrive.price.intValue];
                    } else {
                        drivePrice.text = @"Free";
                    }
                    [showRequests setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
                    [showRiders setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                    [driveRequestsTable reloadData];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    openDriveButton.hidden = YES;
                    drivePriceShadow.hidden = YES;
                    drivePrice.hidden = YES;
                    driveRequestsTable.hidden = YES;
                    noRequestsLabel.hidden = NO;
                    noDriveLabel.hidden = NO;
                });
            }
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        if (!myDrive) {
            return 0;
        }else {
            if (showRequests.titleLabel.textColor == [UIColor darkTextColor]) {
                if (myDrive.requests.count == 0) {
                    driveRequestsTable.hidden = YES;
                    noRequestsLabel.hidden = NO;
                    noRequestsLabel.text = @"No Requests";
                } else {
                    driveRequestsTable.hidden = NO;
                    noRequestsLabel.hidden = YES;
                }
                return myDrive.requests.count;
            } else {
                if (myDrive.riders.count == 0) {
                    driveRequestsTable.hidden = YES;
                    noRequestsLabel.hidden = NO;
                    noRequestsLabel.text = @"No Riders";
                } else {
                    driveRequestsTable.hidden = NO;
                    noRequestsLabel.hidden = YES;
                }
                return myDrive.riders.count;
            }
        }
    } else {
        if (myRides.count == 0) {
            rideTable.hidden = YES;
            noRidesLabel.hidden = NO;
        } else {
            rideTable.hidden = NO;
            noRidesLabel.hidden = YES;
        }
        return myRides.count;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
    return 57;
    } else {
        return 130;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1) {
        static NSString *simpleTableIdentifier = @"driveRequestsCell";
        
        driveRequestsCell *cell = (driveRequestsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"driveRequestsCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if (showRequests.titleLabel.textColor == [UIColor darkTextColor]) {
            [cell.confirm addTarget:self action:@selector(confirmDriveRequest:) forControlEvents:UIControlEventTouchUpInside];
            cell.confirm.tag = indexPath.row;
            cell.cancel.tag = indexPath.row;
            [References cornerRadius:cell.picutre radius:cell.picutre.frame.size.width/2];
            [cell setBackgroundColor:[UIColor clearColor]];
            cell.name.text = myDrive.requests[indexPath.row];
            [References tintUIButton:cell.confirm color:[References colorFromHexString:@"#057AFF"]];
            [References tintUIButton:cell.cancel color:[References colorFromHexString:@"#057AFF"]];
            [cell.cancel addTarget:self action:@selector(cancelDriveRequest:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [References cornerRadius:cell.picutre radius:cell.picutre.frame.size.width/2];
            [cell setBackgroundColor:[UIColor clearColor]];
            cell.name.text = myDrive.riders[indexPath.row];
            [cell.confirm setBackgroundImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
            [References tintUIButton:cell.confirm color:[[self view] tintColor]];
            cell.tag = indexPath.row;
            [cell.confirm addTarget:self action:@selector(callPerson:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        return cell;
    } else {
        static NSString *simpleTableIdentifier = @"feedCell";
        
        feedCell *cell = (feedCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"feedCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }

        rideObject *ride = myRides[indexPath.row];
        NSArray *startArray = [ride.plainStart componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSInteger startCount = [startArray count];
        if (startCount == 1) {
            cell.from.text = [NSString stringWithFormat:@"%@",[ride.plainStart substringWithRange:NSMakeRange(0, 3)]];
        } else if (startCount == 2) {
            cell.from.text = [NSString stringWithFormat:@"%c%c",[startArray[0] characterAtIndex:0],[startArray[1] characterAtIndex:0]];
        } else if (startCount == 3) {
            cell.from.text = [NSString stringWithFormat:@"%c%c%c",[startArray[0] characterAtIndex:0],[startArray[1] characterAtIndex:0],[startArray[2] characterAtIndex:0]];
        }
        NSArray *endArray = [ride.plainEnd componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSInteger endCount = [endArray count];
        if (endCount == 1) {
            cell.to.text = [NSString stringWithFormat:@"%@",[ride.plainEnd substringWithRange:NSMakeRange(0, 3)]];
        } else if (endCount == 2) {
            cell.to.text = [NSString stringWithFormat:@"%c%c",[endArray[0] characterAtIndex:0],[endArray[1] characterAtIndex:0]];
        } else if (endCount == 3) {
            cell.to.text = [NSString stringWithFormat:@"%c%c%c",[endArray[0] characterAtIndex:0],[endArray[1] characterAtIndex:0],[endArray[2] characterAtIndex:0]];
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM"];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"d"];
        cell.month.text = [dateFormatter stringFromDate:ride.date];
        cell.date.text = [timeFormatter stringFromDate:ride.date];
        [References cornerRadius:cell.whiteBack radius:9.0];
        [References cornerRadius:cell.redBack radius:9.0];
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 2) {
        selectionFeedback = [[UISelectionFeedbackGenerator alloc] init];
        [selectionFeedback prepare];
        [selectionFeedback selectionChanged];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            rideView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rideView"];
            viewController.ride = myRides[indexPath.row];
            viewController.rideRecord = myRideRecords[indexPath.row];
            [self presentViewController:viewController animated:YES completion:nil];
        });
    }
}

-(void)confirmDriveRequest:(UIButton*)sender {
    NSString *person = myDrive.requests[sender.tag];
    NSMutableArray *newRequests = [[NSMutableArray alloc] initWithArray:myDrive.requests];
    [newRequests removeObjectAtIndex:sender.tag];
    NSMutableArray *newPayments = [[NSMutableArray alloc] initWithArray:myDrive.payments];
    [newPayments addObject:person];
    myDriveRecord[@"requests"] = newRequests;
    myDriveRecord[@"payments"] = newPayments;
    CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                              initWithRecordsToSave:[[NSArray alloc] initWithObjects:myDriveRecord, nil] recordIDsToDelete:nil];
    modifyRecords.savePolicy=CKRecordSaveAllKeys;
    modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
    modifyRecords.modifyRecordsCompletionBlock=
    ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
        //   the completion block code here
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [References fullScreenToast:@"Rider approved, awaiting payment." inView:self withSuccess:YES andClose:NO];
            [self getMyDrive];
        });
    };
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
}

-(void)cancelDriveRequest:(UIButton*)sender {
    [References fullScreenToast:@"Rider rejected." inView:self withSuccess:YES andClose:NO];
    NSString *name = myDrive.requests[sender.tag];
    NSMutableArray *newRequests = [[NSMutableArray alloc] initWithArray:myDrive.requests];
    [newRequests removeObjectAtIndex:sender.tag];
    myDriveRecord[@"requests"] = newRequests;
    CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                              initWithRecordsToSave:[[NSArray alloc] initWithObjects:myDriveRecord, nil] recordIDsToDelete:nil];
    modifyRecords.savePolicy=CKRecordSaveAllKeys;
    modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
    modifyRecords.modifyRecordsCompletionBlock=
    ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
        NSString *string = [NSString stringWithFormat:@"email = '%@'",name];
        CKContainer *defaultContainer = [CKContainer defaultContainer];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
        CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"People" predicate:predicate];
        [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
            if (!error) {
                if (results.count > 0) {
                    for (int a = 0; a < results.count; a++) {
                        CKRecord *record = results[a];
                        NSMutableArray *rides = [record valueForKey:@"myRides"];
                        for (int b = 0; b < rides.count; b++) {
                            if ([rides[b] isEqualToString:myDrive.phone]) {
                                [rides removeObjectAtIndex:b];
                            }
                        }
                        record[@"myRides"] = rides;
                        [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                
                                [self getMyDrive];
                            });
                        }];
                    }
                } else {
                    
                }
            } else {
                NSLog(@"%@",error.localizedDescription);
            }
        }];
        
    };
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showRequests:(id)sender {
    [showRequests setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [showRiders setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [driveRequestsTable reloadData];
}

- (IBAction)showRiders:(id)sender {
    [showRiders setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [showRequests setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [driveRequestsTable reloadData];
}

- (IBAction)scrollButton:(id)sender {
    if (scroll.contentOffset.y == 0) {
        [References fadeButtonText:scrollButton text:@"Show Your Next Drive"];
        [scroll setContentOffset:CGPointMake(0, scroll.contentSize.height/2) animated:YES];
        [References moveDown:scrollButton yChange:50];
    } else {
        [References fadeButtonText:scrollButton text:@"Show Your Rides"];
        [References moveUp:scrollButton yChange:50];
        [scroll setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (IBAction)openMyDrive:(id)sender {
    selectionFeedback = [[UISelectionFeedbackGenerator alloc] init];
    [selectionFeedback prepare];
    [selectionFeedback selectionChanged];
    rideView *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rideView"];
    viewController.ride = myDrive;
    viewController.rideRecord = myDriveRecord;
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void)callPerson:(UIButton*)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",myDrive.riders[sender.tag]]] options:nil completionHandler:nil];
}

@end
