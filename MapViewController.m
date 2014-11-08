//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"

#define kCoordSpanDelta 0.05

@import MapKit;
@import CoreLocation;

@interface MapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property NSMutableArray *divvyBikeArray;
@property NSMutableString *directionsString;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.divvyBikeArray = [NSMutableArray array];
    [self.divvyBikeArray addObject:self.myLocationDivvy];
    [self.divvyBikeArray addObject:self.divvyBike];
    
    self.mapView.delegate = self;
    
    [self addAnnotationsToMapView];
    [self getDirections];
}

#pragma mark - Map View Delegates

- (void)addAnnotationsToMapView
{
    for (DivvyBike *divvyBike in self.divvyBikeArray)
    {
        CLLocationCoordinate2D coord = divvyBike.location.coordinate;
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = coord;
        annotation.title = divvyBike.name;
        annotation.subtitle = divvyBike.availableBikes;
        [self.mapView addAnnotation:annotation];
        
        if ([divvyBike isEqual:self.divvyBikeArray[1]])
        {
            [self frameBikeAnnotation:annotation];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.image = [UIImage imageNamed:@"bikeImage"];

    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Directions" message:self.directionsString preferredStyle:UIAlertControllerStyleAlert];

//    NSArray *subViewArray = alert.view.subviews;
//    for(int x = 0; x < [subViewArray count]; x++){
//        
//        //If the current subview is a UILabel...
//        if([[[subViewArray objectAtIndex:x] class] isSubclassOfClass:[UILabel class]]) {
//            UILabel *label = [subViewArray objectAtIndex:x];
//            label.textAlignment = NSTextAlignmentLeft;
//        }
//    }

    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - helper methods

- (void)getDirections
{
    DivvyBike *destination = self.divvyBikeArray[1];
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destination.mapItem;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSArray *routes = response.routes;
        MKRoute *route = routes.firstObject;
        
        int x = 1;
        self.directionsString = [NSMutableString string];
        
        for (MKRouteStep *step in route.steps)
        {
            [self.directionsString appendFormat:@"%d: %@\n", x, step.instructions];
            x++;
        }

    }];

}

- (void)frameBikeAnnotation:(MKPointAnnotation *)annotation
{
    CLLocationCoordinate2D center = [annotation coordinate];
    MKCoordinateSpan coordinateSpan;
    coordinateSpan.latitudeDelta = kCoordSpanDelta;
    coordinateSpan.longitudeDelta = kCoordSpanDelta;
    MKCoordinateRegion region = MKCoordinateRegionMake(center, coordinateSpan);
    [self.mapView setRegion:region animated:YES];
}


@end
