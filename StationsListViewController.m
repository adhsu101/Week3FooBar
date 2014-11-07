//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "DivvyBike.h"

#define kURL @"http://www.bayareabikeshare.com/stations/json"

@interface StationsListViewController () <UITabBarDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property CLLocation *location;
@property NSMutableArray *divvyBikes;

@end

@implementation StationsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    [self loadJSON];
    
}


#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.divvyBikes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DivvyBike *currentDivvyBike = self.divvyBikes[indexPath.row];
    if ([currentDivvyBike.location isEqual:self.location])
    {
        return nil;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    DivvyBike *divvyBike = self.divvyBikes[indexPath.row];
    cell.textLabel.text = divvyBike.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ bikes", divvyBike.availableBikes];
    
    return cell;
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        if (location.verticalAccuracy < 500 && location.horizontalAccuracy < 500)
        {
            self.location = location;
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

#pragma mark - helper methods

- (void)loadJSON
{
    self.divvyBikes = [NSMutableArray array];
    
    NSURL *url = [NSURL URLWithString:kURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Error" message:connectionError.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (NSDictionary *divvyBikeD in jsonData[@"stationBeanList"])
            {
                CLLocation *location = [[CLLocation alloc] initWithLatitude:[divvyBikeD[@"latitude"] floatValue] longitude:[divvyBikeD[@"longitude"] floatValue]];
                
                DivvyBike *divvyBike = [[DivvyBike alloc] initWithDictionary:divvyBikeD];
                divvyBike.location = location;
                [self reverseGeocodeWithLocation:location forDivvyBike:divvyBike];
                [self.divvyBikes addObject:divvyBike];
            }
            [self.tableView reloadData];
        }
    }];

    // initialize DivvyBike object for current location
    
    DivvyBike *currentLocationObject = [[DivvyBike alloc] init];
    [self reverseGeocodeWithLocation:self.location forDivvyBike:currentLocationObject];
    currentLocationObject.location = self.location;
    currentLocationObject.name = @"Current Location";
    [self.divvyBikes insertObject:currentLocationObject atIndex:0];
}

- (void)reverseGeocodeWithLocation:(CLLocation *)location forDivvyBike:(DivvyBike *)divvyBike
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        divvyBike.placemark = (MKPlacemark *)placemark;
        divvyBike.mapItem = [[MKMapItem alloc] initWithPlacemark:(MKPlacemark *)placemark];
 
    }];
}


@end