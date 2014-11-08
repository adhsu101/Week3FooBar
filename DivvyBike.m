//
//  DivvyBike.m
//  CodeChallenge3
//
//  Created by Mobile Making on 11/7/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "DivvyBike.h"

@implementation DivvyBike

- (instancetype)initWithDictionary:(NSDictionary *)divvyBikeD
{
    self = [super init];
    self.name = divvyBikeD[@"stAddress1"];
    self.availableBikes = [divvyBikeD[@"availableBikes"] stringValue];

    return self;
}



@end
