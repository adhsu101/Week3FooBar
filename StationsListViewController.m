//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "MapViewController.h"
#import "DivvyBike.h"
#import "CustomTableViewCell.h"

#define kURL @"http://www.bayareabikeshare.com/stations/json"
#define kMeterToMileDivisor 1609.34

@interface StationsListViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate>

@property CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *divvyBikes;
@property NSMutableArray *sortedBikes;
@property NSMutableArray *searchExclusionArray;
@property DivvyBike *myLocationDivvy;

@end

@implementation StationsListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.searchExclusionArray = [NSMutableArray array];
    [self loadJSON];

}


#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sortedBikes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DivvyBike *divvyBike = self.sortedBikes[indexPath.row];
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = divvyBike.name;
    cell.bikeAvailLabel.text = divvyBike.availableBikes;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f miles", divvyBike.distance];
    
    return cell;
}

#pragma mark - Search bar delegate methods


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

    //reset list
    
    if ([searchBar.text isEqualToString:@""])
    {
        [self.sortedBikes addObjectsFromArray:self.searchExclusionArray]; //TODO: does this work?
        [self.searchExclusionArray removeAllObjects];
    }
    else
    {
        for (int x = 0; x < self.sortedBikes.count; x++)
        {
            DivvyBike *divvyBike = self.sortedBikes[x];
            NSRange range = [divvyBike.name rangeOfString:searchBar.text];
            if (range.length == 0)
            {
                [self.sortedBikes removeObject:divvyBike];
                [self.searchExclusionArray addObject:divvyBike];
                x--;
            }
        }

        for (int x = 0; x < self.searchExclusionArray.count; x++)
        {
            DivvyBike *divvyBike = self.searchExclusionArray[x];
            NSRange range = [divvyBike.name rangeOfString:searchBar.text];
            if (range.length > 0)
            {
                [self.searchExclusionArray removeObject:divvyBike];
                [self.sortedBikes addObject:divvyBike];
                x--;
            }
        }
    }
    
    [self.tableView reloadData];
    NSLog(@"%@", searchBar.text);
    
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

            [self.locationManager stopUpdatingLocation];
            
            // initialize a DivvyBike object for current location
            
            self.myLocationDivvy = [[DivvyBike alloc] init];
            [self reverseGeocodeWithLocation:location forDivvyBike:self.myLocationDivvy];
            self.myLocationDivvy.location = location;
            self.myLocationDivvy.name = @"Current Location";
            
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
                [self getDistanceTo:divvyBike];
                
                [self.divvyBikes addObject:divvyBike];
            }
            [self sortByNearest];
            [self.tableView reloadData];
        }
    }];

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

- (void)getDistanceTo:(DivvyBike *)divvyBike
{
    CLLocationDistance distance = [divvyBike.location distanceFromLocation:self.myLocationDivvy.location];
    float distanceInMiles = distance/kMeterToMileDivisor;
    
    divvyBike.distance = distanceInMiles;
}

- (void)sortByNearest
{
    self.sortedBikes = [[NSMutableArray alloc] init];
    NSInteger indexLimit = self.divvyBikes.count;
    
    for (NSInteger x = 0; x < indexLimit; x++)
    {
        DivvyBike *nearbyBike = [[DivvyBike alloc] init];
        nearbyBike = self.divvyBikes[0];
        DivvyBike *compareLocation = self.divvyBikes[0];
        for (int y = 0; y < self.divvyBikes.count; y++)
        {
            compareLocation = self.divvyBikes[y];
            if (nearbyBike.distance > compareLocation.distance)
            {
                nearbyBike = compareLocation;
            }
        }
        [self.sortedBikes addObject:nearbyBike];
        [self.divvyBikes removeObject:nearbyBike];
    }
    
}

#pragma mark - segue life cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:sender
{
    MapViewController *vc = segue.destinationViewController;
    vc.divvyBike = self.sortedBikes[[self.tableView indexPathForSelectedRow].row];
    vc.myLocationDivvy = self.myLocationDivvy;
}


@end
