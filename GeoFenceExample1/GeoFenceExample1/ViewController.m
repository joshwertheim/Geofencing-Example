//
//  ViewController.m
//  GeoFenceExample1
//
//  Created by Joshua Wertheim on 12/4/13.
//  Copyright (c) 2013 Joshua Wertheim. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CLLocationManagerDelegate>
{
    BOOL _didStartMonitoringRegion;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *geofences;

@end

@implementation ViewController

static NSString *GeofenceCellIdentifier = @"GeofenceCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    
    // LocationManager Setup
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    self.geofences = [NSMutableArray arrayWithArray:[[self.locationManager monitoredRegions] allObjects]];
}

- (void)setupTableView
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCurrentLocation:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editTableView:)];
}

- (void)updateTableView {
    if (![self.geofences count]) {
        // Update Table View
        [self.tableView setEditing:NO animated:YES];
        // Update Edit Button
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Edit", nil)];
    } else {
        // Update Edit Button
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    // Update Add Button
    if ([self.geofences count] < 20) {
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    } else {
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }
}

- (void)addCurrentLocation:(id)sender {
    _didStartMonitoringRegion = NO;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations && [locations count] && !_didStartMonitoringRegion) {
        _didStartMonitoringRegion = YES;
        CLLocation *location = [locations objectAtIndex:0];
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:[location coordinate] radius:250.0 identifier:[[NSUUID UUID] UUIDString]];
        
        [self.locationManager startMonitoringForRegion:region];
        [self.locationManager stopUpdatingLocation];
        [self.geofences addObject:region];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:([self.geofences count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        
        [self updateTableView];
    }
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    NSTimeZone* timezone = [NSTimeZone defaultTimeZone];
    notification.timeZone = timezone;
    notification.alertBody = @"You have left your most recent region. Set a new one?";
    notification.alertAction = @"Open";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
//    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.geofences count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GeofenceCellIdentifier];

    CLCircularRegion *geofence = [self.geofences objectAtIndex:[indexPath row]];
    CLLocationCoordinate2D center = [geofence center];
    
    NSString *text = [NSString stringWithFormat:@"%.1f | %.1f", center.latitude, center.longitude];
    [cell.textLabel setText:text];
//    [cell.detailTextLabel setText:[geofence identifier]];
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)editTableView:(id)sender {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    
    if ([self.tableView isEditing]) {
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Done", nil)];
    } else {
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Edit", nil)];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CLRegion *region = [self.geofences objectAtIndex:[indexPath row]];
        [self.locationManager stopMonitoringForRegion:region];
        [self.geofences removeObject:region];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self updateTableView];
    }
}

@end
