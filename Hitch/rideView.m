//
//  rideView.m
//  Hitch
//
//  Created by Robert Crosby on 8/7/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import "rideView.h"

@interface rideView ()

@end

@implementation rideView

- (void)viewDidLoad {
    [References cardshadow:from];
    [References cardshadow:to];
    [References cardshadow:date];
    [References cardshadow:from];
    [References cardshadow:rideManagerShare];
    [References cardshadow:rideManagerMap];
    [References cardshadow:rideManagerTrash];
    [References cardshadow:statusBar];
    [References cardshadow:seats];
    [References cardshadow:price];
    [References cornerRadius:requestRide radius:8.0f];
    [References cornerRadius:messagesButton radius:8.0f];
    [References cornerRadius:ridersButton radius:8.0f];
    [self IsMyDrive];
    [self isRidePending];
    [self isRideConfirmed];
    [self isAwaitingPayment];
    from.text = _ride.plainStart;
    to.text = _ride.plainEnd;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h a"];
    date.text = [NSString stringWithFormat:@"%@ around %@",[dateFormatter stringFromDate:_ride.date],[timeFormatter stringFromDate:_ride.date]];

    if (_ride.price.intValue > 0) {
        price.text = [NSString stringWithFormat:@"$%i for one way",_ride.price.intValue];
    } else {
        price.text = @"Free Ride for one way";
    }
    [self loadMap];
    seats.text = [NSString stringWithFormat:@"%i seats available",_ride.seats.intValue];
    [rideManagerMap setBackgroundColor:[UIColor clearColor]];
    [rideManagerShare setBackgroundColor:[UIColor clearColor]];
    [rideManagerTrash setBackgroundColor:[UIColor clearColor]];
    [super viewDidLoad];
    if (_ride.messages.count > 0) {
            [rideTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_ride.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else {
        rideTable.hidden = YES;
        noRiders.hidden = NO;
    }
    riderColorMatch = [[NSMutableArray alloc] initWithArray:_ride.riders];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    // Do any additional setup after loading the view.
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    // Write code to adjust views accordingly using deltaHeight
    keyboardHeight = kbSize.height-1;
    [References moveUp:ridePanelMessage yChange:keyboardHeight];
    [References moveUp:ridePanelMessageField yChange:keyboardHeight];
    [References moveUp:ridePanelSendMessage yChange:keyboardHeight];
    [References moveUp:line yChange:keyboardHeight];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    // Write code to adjust views accordingly using kbSize.height
    [References moveDown:ridePanelMessage yChange:keyboardHeight];
    [References moveDown:ridePanelMessageField yChange:keyboardHeight];
    [References moveDown:ridePanelSendMessage yChange:keyboardHeight];
    [References moveDown:line yChange:keyboardHeight];
    keyboardHeight = 0.0f;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(id)sender {
        [References fullScreenToast:@"Coming Soon" inView:self withSuccess:NO andClose:NO];
    
}

- (IBAction)showMessages:(id)sender {
    ridePanelSendMessage.enabled = YES;
    ridePanelMessageField.enabled = YES;
    if (_ride.messages.count == 0) {
        rideTable.hidden = YES;
        noRiders.hidden = NO;
        noRiders.text = @"No Messages";
    } else {
        rideTable.hidden = NO;
        noRiders.hidden = YES;
        noRiders.text = @"No Messages";
    }
    [ridersButton setTitleColor:[References colorFromHexString:@"#929292"] forState:UIControlStateNormal];
    [messagesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [rideTable reloadData];
    if (_ride.messages.count > 0) {
            [rideTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_ride.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (IBAction)showRiders:(id)sender {
    if (_ride.riders.count == 0) {
        rideTable.hidden = YES;
        noRiders.hidden = NO;
        noRiders.text = @"No Riders";
    } else {
        rideTable.hidden = NO;
        noRiders.hidden = YES;
        noRiders.text = @"No Riders";
    }
    
    ridePanelSendMessage.enabled = NO;
    ridePanelMessageField.enabled = NO;
    [messagesButton setTitleColor:[References colorFromHexString:@"#929292"] forState:UIControlStateNormal];
    [ridersButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [rideTable reloadData];
    if (_ride.riders.count > 0) {
        [rideTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (IBAction)sendGroupMessage:(id)sender {
    if (ridePanelMessageField.text.length > 0) {
        messages = [[NSMutableArray alloc] initWithArray:[_rideRecord objectForKey:@"messages"]];
        [messages addObject:[NSString stringWithFormat:@"%@^&^%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"name"],ridePanelMessageField.text]];
        _rideRecord[@"messages"] = messages;
        CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                                  initWithRecordsToSave:[[NSArray alloc] initWithObjects:_rideRecord, nil] recordIDsToDelete:nil];
        modifyRecords.savePolicy=CKRecordSaveAllKeys;
        modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
        modifyRecords.modifyRecordsCompletionBlock=
        ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
            //   the completion block code here
            dispatch_async(dispatch_get_main_queue(), ^(void){
                CKRecord *record = savedRecords[0];
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
                rideObject *ride = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd andPhone:[record valueForKey:@"email"] andRequests:requests andPayments:payments andID:rideID];
                _rideRecord = record;
                _ride = ride;
                [rideTable reloadData];
                [ridePanelMessageField setText:@""];
            });
        };
        noRiders.hidden = YES;
        rideTable.hidden = NO;
        CKContainer *defaultContainer = [CKContainer defaultContainer];
        [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
    }
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return YES;
}

//- (IBAction)showKeyboard:(id)sender {
//    if (ridePanelMessage.frame.origin.y> scroll.contentSize.height-50) {
//        [References moveUp:ridePanelMessage yChange:kHeight-1];
//        [References moveUp:ridePanelMessageField yChange:kHeight-1];
//        [References moveUp:ridePanelSendMessage yChange:kHeight-1];
//        [References moveUp:line yChange:kHeight-1];
//        [References fadeColor:ridePanelMessage color:[References colorFromHexString:@"#D2D5DC"]];
//    }
//}

-(bool)textFieldShouldReturn:(UITextField *)textField {
//    if (ridePanelMessage.frame.origin.y< scroll.contentSize.height-50) {
//        [References moveDown:ridePanelMessage yChange:kHeight-1];
//        [References moveDown:line yChange:kHeight-1];
//        [References moveDown:ridePanelMessageField yChange:kHeight-1];
//        [References moveDown:ridePanelSendMessage yChange:kHeight-1];
//        [References fadeColor:ridePanelMessage color:[UIColor whiteColor]];
//        
//    }
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareRide:(id)sender {
    NSString *textToShare;
    if ([_ride.phone isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]) {
        textToShare = @"Check out my drive on Hitch for iOS\n\n";
    } else if (isRideConfirmed == YES) {
        textToShare = @"Check out this ride I found on Hitch for iOS\n\n";
    }
    NSString *string =[NSString stringWithFormat:@"hitch://openRide/ride?creator=%@",_ride.rideID];
    NSURL *url = [NSURL URLWithString:string];
    NSArray *objectsToShare = @[textToShare,url];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypeAddToReadingList];
    
    activityVC.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)openDirections:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Open Apple Maps" message:@"Note: Directions are done based on city zip codes to ensure privacy." preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Apple Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
            NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",_ride.start.coordinate.latitude, _ride.start.coordinate.longitude, _ride.end.coordinate.latitude, _ride.end.coordinate.longitude];
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: directionsURL]];
    }]];
    
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

- (IBAction)deleteDrive:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"All riders will be removed from the drive, and refunds will be made if necessary." preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [References fullScreenToast:@"Ride Deleted." inView:self withSuccess:YES andClose:YES];
        // Distructive button tapped.
        for (int a = 0; a < _ride.riders.count; a++) {
            NSString *string = [NSString stringWithFormat:@"email = '%@'",_ride.riders[a]];
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
                                if ([rides[b] isEqualToString:_ride.phone]) {
                                    [rides removeObjectAtIndex:b];
                                }
                            }
                            record[@"myRides"] = rides;
                            [[CKContainer defaultContainer].publicCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                                
                            }];
                        }
                    } else {
                        
                    }
                } else {
                    NSLog(@"%@",error.localizedDescription);
                }
            }];
        }
            [[CKContainer defaultContainer].publicCloudDatabase deleteRecordWithID:_rideRecord.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
                

            }];
        }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)loadMap {
    MKCoordinateRegion region = map.region;
    region.span.longitudeDelta /= 8.0;
    region.span.latitudeDelta /= 8.0;
    
    [map setRegion:region animated:YES];
    MKPointAnnotation *start = [[MKPointAnnotation alloc] init];
    start.coordinate = _ride.start.coordinate;
    [start setTitle:_ride.plainStart];
    MKPointAnnotation *end = [[MKPointAnnotation alloc] init];
    [end setTitle:_ride.plainEnd];
    end.coordinate = _ride.end.coordinate;
    [map addAnnotation:start];
    [map addAnnotation:end];
    [self zoomToFitMapAnnotations:map];
}

-(void)zoomToFitMapAnnotations:(MKMapView*)mapView
{
    if([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(CLLocation* annotation in mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 5.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 5.1; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
    for(MKAnnotationView *annotation in mapView.annotations)
    {
        [mapView removeAnnotation:annotation];
    }
}

- (IBAction)requestRide:(id)sender {
    if (isAwaitingPayment == YES){
            [self tappedApplePay];
    } else {
        [self addToMyRides];
    }
        
//        NSMutableArray *newRequests = [[NSMutableArray alloc] initWithArray:[_rideRecord objectForKey:@"requests"]];
//        [newRequests addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
//        _rideRecord[@"requests"] = newRequests;
//        CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
//                                                  initWithRecordsToSave:[[NSArray alloc] initWithObjects:_rideRecord, nil] recordIDsToDelete:nil];
//        modifyRecords.savePolicy=CKRecordSaveAllKeys;
//        modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
//        modifyRecords.modifyRecordsCompletionBlock=
//        ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
//            //   the completion block code here
//            dispatch_async(dispatch_get_main_queue(), ^(void){
//                [self addToMyRides];
//            });
//        };
//        CKContainer *defaultContainer = [CKContainer defaultContainer];
//        [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
}

-(void)addToMyRides{
    NSString *string = [NSString stringWithFormat:@"email = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"People" predicate:predicate];
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            CKRecord *record = results[0];
            NSMutableArray *newRequests = [[NSMutableArray alloc] initWithArray:[record objectForKey:@"myRides"]];
            [newRequests addObject:_ride.rideID];
            record[@"myRides"] = newRequests;
            CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                                      initWithRecordsToSave:[[NSArray alloc] initWithObjects:record, nil] recordIDsToDelete:nil];
            modifyRecords.savePolicy=CKRecordSaveAllKeys;
            modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
            modifyRecords.modifyRecordsCompletionBlock=
            ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
                //   the completion block code here
                NSMutableArray *newRequests = [[NSMutableArray alloc] initWithArray:_ride.requests];
                [newRequests addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
                _rideRecord[@"requests"] = newRequests;
                CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                                          initWithRecordsToSave:[[NSArray alloc] initWithObjects:_rideRecord, nil] recordIDsToDelete:nil];
                modifyRecords.savePolicy=CKRecordSaveAllKeys;
                modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
                modifyRecords.modifyRecordsCompletionBlock=
                ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
                    //   the completion block code here
                };
                CKContainer *defaultContainer = [CKContainer defaultContainer];
                [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [References fullScreenToast:@"Ride requested, the driver will be notified." inView:self withSuccess:YES andClose:NO];
                    [requestRide setTitle:@"Ride Request Pending" forState:UIControlStateNormal];
                    [requestRide setEnabled:NO];
                    [requestRide setTitleColor:[[self view] tintColor] forState:UIControlStateNormal];
                });
            };
            CKContainer *defaultContainer = [CKContainer defaultContainer];
            [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
        }
        else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
}

-(void)IsMyDrive {
    if ([_ride.phone isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]) {
        requestRide.hidden = YES;
        isRideConfirmed = YES;
        [rideManagerTrash setEnabled:YES];
        [requestRide setTitleColor:[[self view] tintColor] forState:UIControlStateNormal];
        [requestRide setTitle:@"See Your Drive Messages" forState:UIControlStateNormal];
        scroll.contentSize = CGSizeMake([References screenWidth], scroll.frame.size.height-20);
        [References createLine:scroll xPos:0 yPos:ridePanelMessage.frame.origin.y inFront:TRUE];
        if (_ride.messages.count > 0) {
                    [rideTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_ride.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }

        if (_ride.messages.count < 1) {
            rideTable.hidden = YES;
            noRiders.hidden = NO;
            noRiders.text = @"No Messages";
        } else if (_ride.riders.count == 0) {
            rideTable.hidden = YES;
            noRiders.hidden = NO;
            noRiders.text = @"No Riders";
        }
    }
}

-(void)isRidePending {
    for (int a = 0; a < _ride.requests.count; a++) {
        if ([_ride.requests[a] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]) {
            [requestRide setTitle:@"Pending" forState:UIControlStateNormal];
            [requestRide setEnabled:NO];
            [requestRide setTitleColor:[[self view] tintColor] forState:UIControlStateNormal];
            [rideManagerTrash setEnabled:NO];
            [messagesButton setEnabled:NO];
            [ridersButton setEnabled:NO];
        }
    }
}

-(void)isAwaitingPayment {
    for (int a = 0; a < _ride.payments.count; a++) {
        if ([_ride.payments[a] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]) {
            [requestRide setTitle:@"Apple Pay" forState:UIControlStateNormal];
            [self getTransactions];
            [requestRide setEnabled:YES];
            [messagesButton setEnabled:NO];
            [ridersButton setEnabled:NO];
            isAwaitingPayment = YES;
            indexOfPayment = a;
            [requestRide setEnabled:YES];
            [requestRide setTitleColor:[[self view] tintColor] forState:UIControlStateNormal];
            [rideManagerTrash setEnabled:NO];
            [self getReferralCode];
        }
    }
}

-(void)getReferralCode {
    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"email = '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]];
    CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"People" predicate:predicate];
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if (results.count > 0) {
                    currentUser = results[0];
                    referralCode = [currentUser valueForKey:@"referredBy"];
                    if (referralCode.length > 0) {
                        CKContainer *defaultContainer = [CKContainer defaultContainer];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"referralCode = '%@'",referralCode]];
                        CKDatabase *publicDatabase = [defaultContainer publicCloudDatabase];
                        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"People" predicate:predicate];
                        [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
                            if (!error) {
                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                    if (results.count > 0) {
                                        CKRecord *person = results[0];
                                        referredBy = [person valueForKey:@"email"];
                                    }
                                });
                            } else {
                                NSLog(@"%@",error.localizedDescription);
                            }
                        }];
                    }
                }
            });
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}

-(void)isRideConfirmed {
    for (int a = 0; a < _ride.riders.count; a++) {
        if ([_ride.riders[a] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]]) {
            [requestRide setTitleColor:[[self view] tintColor] forState:UIControlStateNormal];
            isRideConfirmed = YES;
            [requestRide setEnabled:YES];
            [messagesButton setEnabled:NO];
            [ridersButton setEnabled:NO];
            [rideManagerTrash setEnabled:NO];
            [requestRide setTitle:@"See Your Ride Messages" forState:UIControlStateNormal];
            scroll.contentSize = CGSizeMake([References screenWidth], scroll.frame.size.height);
            [References createLine:scroll xPos:0 yPos:ridePanelMessage.frame.origin.y inFront:TRUE];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (ridersButton.titleLabel.textColor == [UIColor blackColor]) {
        return _ride.riders.count;
    } else {
        return _ride.messages.count;
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (ridersButton.titleLabel.textColor == [UIColor blackColor]) {
        return 57;
    } else {
        int multiples =ceil([_ride.messages[indexPath.row] length] / 30);
        if (multiples <= 1) {
            return 57;
        } else {
            int adddition = 10*multiples;
            return 57+adddition;
        }
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (ridersButton.titleLabel.textColor == [UIColor blackColor]) {
        static NSString *simpleTableIdentifier = @"driveRequestsCell";
        
        driveRequestsCell *cell = (driveRequestsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"driveRequestsCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        [References cornerRadius:cell.picutre radius:cell.picutre.frame.size.width/2];
        cell.initial.text = [NSString stringWithFormat:@"%c",[_ride.riders[indexPath.row] characterAtIndex:0]];
        cell.initial.text = [cell.initial.text uppercaseString];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.name.text = _ride.riders[indexPath.row];
        if (isRideConfirmed == YES) {
            [cell.confirm setBackgroundImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
            [References tintUIButton:cell.confirm color:[[self view] tintColor]];
            cell.tag = indexPath.row;
            [cell.confirm addTarget:self action:@selector(callPerson:) forControlEvents:UIControlEventTouchUpInside];
        }
//            for (int a = 0; a < riderColorMatch.count; a++) {
//                if ([_ride.riders[indexPath.row] isEqualToString:riderColorMatch[a]]) {
//                    if (a == 0) {
//                        [cell.picutre setBackgroundColor:[References systemColor:@"RED"]];
//                    }
//                    if (a == 1) {
//                        [cell.picutre setBackgroundColor:[References systemColor:@"YELLOW"]];
//                    }
//                    if (a == 2) {
//                        [cell.picutre setBackgroundColor:[References systemColor:@"ORANGE"]];
//                    }
//                    if (a == 3) {
//                        [cell.picutre setBackgroundColor:[References systemColor:@"LBLUE"]];
//                    }
//                    if (a == 4) {
//                        [cell.picutre setBackgroundColor:[References systemColor:@"LRED"]];
//                    }
//                }
//        }
        return cell;
    } else {
        static NSString *simpleTableIdentifier = @"messageCell";
        
        messageCell *cell = (messageCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"messageCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        NSArray *messageBody = [_ride.messages[indexPath.row] componentsSeparatedByString:@"^&^"];
        cell.initial.text = [NSString stringWithFormat:@"%c",[messageBody[0] characterAtIndex:0]];
        cell.initial.text = [cell.initial.text uppercaseString];
        int multiples =ceil([messageBody[1] length] / 30);
        multiples++;
        cell.message.text = messageBody[1];
        [cell.message setNumberOfLines:multiples];
        cell.message.frame = CGRectMake(cell.message.frame.origin.x, cell.message.frame.origin.y, cell.message.frame.size.width, 22*multiples);
        [References cornerRadius:cell.picture radius:cell.picture.frame.size.width/2];
        
        [cell setBackgroundColor:[UIColor clearColor]];
//        if ([messageBody[0] isEqualToString:_ride.name]) {
//            [cell.picture setBackgroundColor:[References systemColor:@"BLUE"]];
//        } else {
//        for (int a = 0; a < riderColorMatch.count; a++) {
//            if ([messageBody[0] isEqualToString:riderColorMatch[a]]) {
//                    if (a == 0) {
//                        [cell.picture setBackgroundColor:[References systemColor:@"RED"]];
//                    }
//                    if (a == 1) {
//                        [cell.picture setBackgroundColor:[References systemColor:@"YELLOW"]];
//                    }
//                if (a == 2) {
//                    [cell.picture setBackgroundColor:[References systemColor:@"ORANGE"]];
//                }
//                if (a == 3) {
//                    [cell.picture setBackgroundColor:[References systemColor:@"LBLUE"]];
//                }
//                if (a == 4) {
//                    [cell.picture setBackgroundColor:[References systemColor:@"LRED"]];
//                }
//                }
//            }
//        }
        return cell;
    }
}

-(void)callPerson:(UIButton*)sender {
    NSLog(@"%@",_ride.riders[sender.tag]);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_ride.riders[sender.tag]]]];
}

- (UIButton *)applePayButton {
    UIButton *button;
    if ([PKPaymentButton class]) { // Available in iOS 8.3+
        button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
    } else {
        // TODO: Create and return your own apple pay button
        // button = ...
    }
    button.frame = CGRectMake([References screenWidth]-50, 25, 30, 20);
    [button addTarget:self action:@selector(tappedApplePay) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
    
}

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken *token, NSError *error) {
        if (error) {
            completion(PKPaymentAuthorizationStatusFailure);
            return;
        }
        [self createBackendChargeWithToken:token completion:completion];
    }];
}

- (void)createBackendChargeWithToken:(STPToken *)token completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    //We are printing Stripe token here, you can charge the Credit Card using this token from your backend.
    NSString *paymentID = [References randomStringWithLength:8];
    NSURL *url = [NSURL URLWithString:@"http://104.236.94.16:5000/charge"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // NSError *actualerror = [[NSError alloc] init];
    // Parameters
    NSDictionary *tmp = [[NSDictionary alloc] init];
    tmp = @{
            @"token"     : [NSString stringWithFormat:@"%@",token],
            @"amount"   : [NSString stringWithFormat:@"%i",(((int)amountToCharge*100))],
            @"email"    : [[NSUserDefaults standardUserDefaults] objectForKey:@"email"],
            @"pFrom"     :[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],
            @"pTo"   : _ride.phone,
            @"paymentID" :  paymentID
            };
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    [request setHTTPBody:postdata];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   // Returned Error
                                   NSLog(@"Unknown Error Occured");
                               } else {
                                   NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"%@",responseBody);
                                   completion(PKPaymentAuthorizationStatusSuccess);
                                   if ([responseBody isEqualToString:@"Success"]) {
                                           NSMutableArray *newRequests = [[NSMutableArray alloc] initWithArray:_ride.payments];
                                           [newRequests removeObjectAtIndex:indexOfPayment];
                                           NSMutableArray *newRiders = [[NSMutableArray alloc] initWithArray:_ride.riders];
                                           [newRiders addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
                                           int newSeatsAvailable = _ride.seats.intValue;
                                           newSeatsAvailable = newSeatsAvailable - 1;
                                           _rideRecord[@"payments"] = newRequests;
                                           _rideRecord[@"riders"] = newRiders;
                                           _rideRecord[@"seats"] = [NSNumber numberWithInt:newSeatsAvailable];
                                           CKModifyRecordsOperation *modifyRecords= [[CKModifyRecordsOperation alloc]
                                                                                     initWithRecordsToSave:[[NSArray alloc] initWithObjects:_rideRecord, nil] recordIDsToDelete:nil];
                                           modifyRecords.savePolicy=CKRecordSaveAllKeys;
                                           modifyRecords.qualityOfService=NSQualityOfServiceUserInitiated;
                                           modifyRecords.modifyRecordsCompletionBlock=
                                           ^(NSArray * savedRecords, NSArray * deletedRecordIDs, NSError * operationError){
                                               CKRecord *record = savedRecords[0];
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
                                               rideObject *ride = [[rideObject alloc] initWithType:start andEnd:end andDate:date andTime:time andSeats:seats andPrice:price andMessages:messages andRiders:riders andName:name andPlainStart:plainStart andPlainEnd:plainEnd andPhone:[record valueForKey:@"email"] andRequests:requests andPayments:payments andID:rideID];
                                               _rideRecord = record;
                                               _ride = ride;
                                              
                                              
                                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                                    [ridePanelMessageField setText:@""];
                                                    [rideTable reloadData];
                                                   [References fullScreenToast:@"Ride Confirmed" inView:self withSuccess:YES andClose:NO];
                                                   [requestRide setTitleColor:[[self view] tintColor] forState:UIControlStateNormal];
                                                   isRideConfirmed = YES;
                                                   [requestRide setEnabled:YES];
                                                   [requestRide setTitle:@"See Your Ride Messages" forState:UIControlStateNormal];
                                                   scroll.contentSize = CGSizeMake([References screenWidth], scroll.frame.size.height);
                                                   [References createLine:scroll xPos:0 yPos:ridePanelMessage.frame.origin.y inFront:TRUE];
                                               });
                                           };
                                           CKContainer *defaultContainer = [CKContainer defaultContainer];
                                           [[defaultContainer publicCloudDatabase] addOperation:modifyRecords];
                                       CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%i",arc4random() %500]];
                                       CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Invoices" recordID:recordID];
                                       record[@"amount"] = [NSString stringWithFormat:@"%i",(_ride.price.intValue)*100];
                                       record[@"chargeAmount"] = [NSString stringWithFormat:@"%i",(int)amountToCharge*100];
                                       record[@"from"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
                                       record[@"to"] = _ride.phone;
                                       record[@"rideID"] = _ride.rideID;
                                       record[@"paymentID"] = paymentID;
                                       CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
                                       [publicDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                                           if(error) {
                                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                                   NSLog(@"%@",error.localizedDescription);
                                               });
                                           } else {
                                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                                   NSLog(@"saved invoice");
                                               });
                                           }
                                       }];
                                       if (amountToCharge != _ride.price.intValue+1) {
                                           balanceDeduction = (_ride.price.intValue+1) - amountToCharge;
                                           CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%i",arc4random() %500]];
                                           CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Invoices" recordID:recordID];
                                           record[@"amount"] = [NSString stringWithFormat:@"%i",(int)balanceDeduction*100];
                                           record[@"from"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
                                           record[@"to"] = @"Hitch";
                                           record[@"rideID"] = @"Code";
                                           record[@"paymentID"] = @"Code";
                                           CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
                                           [publicDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                                               if(error) {
                                                   dispatch_async(dispatch_get_main_queue(), ^(void){
                                                       NSLog(@"%@",error.localizedDescription);
                                                   });
                                               } else {
                                                   dispatch_async(dispatch_get_main_queue(), ^(void){
                                                       NSLog(@"saved balance");
                                                   });
                                               }
                                           }];
                                       }
                                       if (usedReferralCode == true) {
                                           currentUser[@"referredBy"] = @"";
                                           [[CKContainer defaultContainer].publicCloudDatabase saveRecord:currentUser completionHandler:^(CKRecord *record, NSError *error) {
                                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                                   CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%i",arc4random() %500]];
                                                   CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Invoices" recordID:recordID];
                                                   int value = 5;
                                                   record[@"amount"] = [NSString stringWithFormat:@"%i",value*100];
                                                   record[@"from"] = @"Hitch";
                                                   record[@"to"] = referredBy;
                                                   record[@"rideID"] = @"REFERRAL";
                                                   record[@"paymentID"] = @"REFERRAL";
                                                   CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
                                                   [publicDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                                                       if(error) {
                                                           NSLog(@"%@",error.localizedDescription);
                                                           dispatch_async(dispatch_get_main_queue(), ^(void){
                                                               [References fullScreenToast:@"Something Isn't Right" inView:self withSuccess:NO andClose:NO];
                                                           });
                                                       } else {
                                                           dispatch_async(dispatch_get_main_queue(), ^(void){
                                                               NSLog(@"rewarded other user");
                                                           });
                                                           
                                                           
                                                       }
                                                   }];
                                               });
                                           }];
                                       }
                                   }
                                   
                               }
                           }];
    
    //Displaying user Thank you message for payment.
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    //we are going to make all fields blank after user is done paying or canceling paymen
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tappedApplePay{
        PKPaymentRequest *paymentRequest = [self paymentRequest:_ride.price.stringValue];
        PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
}

- (PKPaymentRequest *)paymentRequest:(NSString *)amount {
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantIdentifier = @"merchant.hitch";
    paymentRequest.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.countryCode = @"US";
    paymentRequest.currencyCode = @"USD";
    double cost = _ride.price.doubleValue + 1.00;
    if (currentBalance > 0) {
        cost = cost - currentBalance;
        if (referredBy.length > 0) {
            usedReferralCode = true;
            cost = cost - 5;
            paymentRequest.paymentSummaryItems =
            @[
              [PKPaymentSummaryItem summaryItemWithLabel:@"Ride" amount:[NSDecimalNumber decimalNumberWithString:amount]],
              [PKPaymentSummaryItem summaryItemWithLabel:@"Hitch Fee" amount:[NSDecimalNumber decimalNumberWithString:@"1"]],
              [PKPaymentSummaryItem summaryItemWithLabel:@"Referral Code" amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"-5"]]],
              [PKPaymentSummaryItem summaryItemWithLabel:@"Current Balance" amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"-%.2f",currentBalance]]],
              [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",cost]]]
              ];
        } else {
            usedReferralCode = false;
            paymentRequest.paymentSummaryItems =
            @[
              [PKPaymentSummaryItem summaryItemWithLabel:@"Ride" amount:[NSDecimalNumber decimalNumberWithString:amount]],
              [PKPaymentSummaryItem summaryItemWithLabel:@"Hitch Fee" amount:[NSDecimalNumber decimalNumberWithString:@"1"]],
              [PKPaymentSummaryItem summaryItemWithLabel:@"Current Balance" amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"-%.2f",currentBalance]]],
              [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",cost]]]
              ];
        }
        
    } else {
        if (referredBy.length > 0) {
            usedReferralCode = true;
            cost = cost - 5;
            paymentRequest.paymentSummaryItems =
            @[
              [PKPaymentSummaryItem summaryItemWithLabel:@"Ride" amount:[NSDecimalNumber decimalNumberWithString:amount]],
              [PKPaymentSummaryItem summaryItemWithLabel:@"Hitch Fee" amount:[NSDecimalNumber decimalNumberWithString:@"1"]],
              [PKPaymentSummaryItem summaryItemWithLabel:@"Referral Code" amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"-5"]]],
              [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",cost]]]
              ];
        } else {
            usedReferralCode = false;
    paymentRequest.paymentSummaryItems =
    @[
      [PKPaymentSummaryItem summaryItemWithLabel:@"Ride" amount:[NSDecimalNumber decimalNumberWithString:amount]],
      [PKPaymentSummaryItem summaryItemWithLabel:@"Hitch Fee" amount:[NSDecimalNumber decimalNumberWithString:@"1"]],
      [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",cost]]]
      ];
        }
    }
    amountToCharge = cost;
    return paymentRequest;
}

-(void)getTransactions {
    incomeDone = false;
    calculateValues = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                       target:self
                                                     selector:@selector(calculateValue)
                                                     userInfo:nil
                                                      repeats:YES];
    [transactions removeAllObjects];
    transactions = [[NSMutableArray alloc] init];
    NSString *toPaymentString = [NSString stringWithFormat:@"to == '%@'",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    CKQuery *toPaymentQuery = [[CKQuery alloc] initWithRecordType:@"Invoices" predicate:[NSPredicate predicateWithFormat:toPaymentString]];
    [[CKContainer defaultContainer].publicCloudDatabase performQuery:toPaymentQuery
                                                        inZoneWithID:nil
                                                   completionHandler:^(NSArray *results, NSError *error) {
                                                       
                                                       for (int a = 0; a < results.count; a++) {
                                                           CKRecord *record = results[a];
                                                           NSString *amount = [record valueForKey:@"amount"];
                                                           NSString *chargeAmount = [record valueForKey:@"chargeAmount"];
                                                           NSDate *date = [record valueForKey:@"createdAt"];
                                                           double betterAmount = amount.doubleValue * 0.01;
                                                           double betterCharge = chargeAmount.doubleValue * 0.01;
                                                           transactionObject *transaction = [[transactionObject alloc] initWithType:[record valueForKey:@"rideID"] andAmount:betterAmount andIsIncome:YES andDate:date isFrom:[record valueForKey:@"from"] isTo:[record valueForKey:@"to"] andChargeAmount:betterCharge];
                                                           [transactions addObject:transaction];
                                                       }
                                                       dispatch_async(dispatch_get_main_queue(), ^(void){
                                                           incomeDone = true;
                                                       });
                                                   }];
}

-(void)calculateValue {
    if (incomeDone == true) {
        [calculateValues invalidate];
    currentBalance = 0;
    double value = 0;
    for (int a = 0; a < transactions.count; a++) {
        transactionObject *transaction = transactions[a];
        if (transaction.isIncome.boolValue == YES) {
            value = value + transaction.amount.doubleValue;
        }
    }
    currentBalance = value;
    }
}

-(bool)prefersStatusBarHidden {
    return YES;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -100) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
