//
//  DivvyBike.h
//  CodeChallenge3
//
//  Created by Mobile Making on 11/7/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;
@import MapKit;

@interface DivvyBike : NSObject

@property NSString *name;
@property NSString *availableBikes;
@property MKMapItem *mapItem;
@property MKPlacemark *placemark;
@property CLLocation *location;
@property float distance;

- (instancetype)initWithDictionary:(NSDictionary *)divvyBikeD;

@end
