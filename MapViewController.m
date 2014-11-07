//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"

@import MapKit;
@import CoreLocation;

@interface MapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property NSMutableArray *divvyBikeArray;

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
    }
//    [self frameAnnotations];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;
}

//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
//{
//    TaggedMKPointAnnotation *tappedAnnotation = view.annotation;
//    NSInteger tag = tappedAnnotation.tag;
//    NSNumber *tagNumber = [NSNumber numberWithInteger:tag];
//    [self performSegueWithIdentifier:@"detailSegue" sender:(NSNumber *)tagNumber];
//}

@end
