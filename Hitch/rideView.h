//
//  rideView.h
//  Hitch
//
//  Created by Robert Crosby on 8/7/17.
//  Copyright © 2017 fully toasted. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "References.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "rideObject.h"
#import <CloudKit/CloudKit.h>
#import "driveRequestsCell.h"
#import "messageCell.h"
#import <PassKit/PassKit.h>
#import <Stripe.h>
#import <AFNetworking/AFNetworking.h>
#import "FBEncryptorAES.h"
#import "transactionObject.h"

@interface rideView : UIViewController <PKPaymentAuthorizationViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UITextFieldDelegate> {
    NSString *referralCode,*referredBy;
    CKRecord *currentUser;
    bool usedReferralCode;
    UIView *line;
    CGRect keyboard;
    bool isRideConfirmed,isAwaitingPayment;
    double amountToCharge;
    double balanceDeduction;
    double currentBalance;
    int indexOfPayment;
    MKPolyline *routeLine;
    NSMutableArray *transactions;
    MKPolylineView *routeLineView;
    NSMutableArray *messages;
    NSMutableArray *riderColorMatch;
    NSMutableArray *passengers;
    __weak IBOutlet MKMapView *map;
    __weak IBOutlet UILabel *from;
    __weak IBOutlet UILabel *to;
    __weak IBOutlet UILabel *date;
    __weak IBOutlet UILabel *seats;
    __weak IBOutlet UIScrollView *scroll;
    __weak IBOutlet UILabel *price;
    
    
    
    // contact

    __weak IBOutlet UIButton *requestRide;

    __weak IBOutlet UITableView *rideTable;
    
    __weak IBOutlet UILabel *ridePanelMessage;
    __weak IBOutlet UITextField *ridePanelMessageField;
    __weak IBOutlet UIButton *ridePanelSendMessage;
    
    __weak IBOutlet UIButton *rideManagerTrash;
    __weak IBOutlet UIButton *rideManagerMap;
    __weak IBOutlet UIButton *rideManagerShare;
    
    
    __weak IBOutlet UILabel *statusBar;
    __weak IBOutlet UIButton *ridersButton;
    __weak IBOutlet UIButton *messagesButton;
    __weak IBOutlet UILabel *noRiders;
    NSTimer *calculateValues;
    bool incomeDone;
    CGFloat keyboardHeight;
}


- (IBAction)requestRide:(id)sender;
@property (nonatomic, retain) rideObject *ride;
@property (nonatomic, retain) CKRecord *rideRecord;
- (IBAction)sendMessage:(id)sender;
- (IBAction)showMessages:(id)sender;
- (IBAction)showRiders:(id)sender;
- (IBAction)sendGroupMessage:(id)sender;

- (IBAction)back:(id)sender;

- (IBAction)shareRide:(id)sender;
- (IBAction)openDirections:(id)sender;
- (IBAction)deleteDrive:(id)sender;


@end
