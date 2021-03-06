//
//  ViewController.m
//  Day 6 SF
//
//  Created by Grant Timmerman on 8/14/14.
//  Copyright (c) 2014 Grant Timmerman. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController ()
            

@end

@implementation ViewController

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)
#define kmToMiles(km) (km * 0.6214)

float sfLat = 37.775;
float sfLong = -122.4183333;
CLLocationCoordinate2D sfCoordinate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup background
    float r = 252;
    float g = 66;
    float b = 29;
    UIColor *backgroundColor = [UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:255];
    [self.view setBackgroundColor:backgroundColor];
    
    // Title label
    CGRect titleFrame = CGRectMake(0, 85, self.view.frame.size.width, 100);
    _titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    [_titleLabel setText:@"You are"];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_titleLabel setFont:[UIFont systemFontOfSize:40]];
    [self.view addSubview:_titleLabel];
    
    // Distance label
    CGRect distanceFrame = CGRectMake(0, 180, self.view.frame.size.width, 100);
    _distanceLabel = [[UILabel alloc] initWithFrame:distanceFrame];
    [_distanceLabel setTextColor:[UIColor whiteColor]];
    [_distanceLabel setTextAlignment:NSTextAlignmentCenter];
    [_distanceLabel setFont:[UIFont systemFontOfSize:70]];
    [self.view addSubview:_distanceLabel];
    
    // Direction label
    CGRect directionFrame = CGRectMake(0, 260, self.view.frame.size.width, 100);
    _directionLabel = [[UILabel alloc] initWithFrame:directionFrame];
    [_directionLabel setTextColor:[UIColor whiteColor]];
    [_directionLabel setTextAlignment:NSTextAlignmentCenter];
    [_directionLabel setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:_directionLabel];
        
    // Update location
    sfCoordinate = CLLocationCoordinate2DMake(sfLat, sfLong);
    [self updateCurrentLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Gets the distance from the user's location and SF
- (CLLocationDistance)getDistanceFromSF:(CLLocationCoordinate2D)origin {
    return kmToMiles([self distanceBetweenCoordinates:origin otherCoord:sfCoordinate]);
}

// Gets the distance between two coordinates in km
- (CLLocationDistance)distanceBetweenCoordinates:(CLLocationCoordinate2D)coord1 otherCoord:(CLLocationCoordinate2D)coord2 {
    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:coord1.latitude longitude:coord1.longitude];
    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:coord2.latitude longitude:coord2.longitude];
    return [location1 distanceFromLocation:location2]/1000;
}

// Starts updates of the current location of the user
- (void) updateCurrentLocation {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
}

// Location update manager
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    float distanceFromSF = [self getDistanceFromSF:newLocation.coordinate];
    NSString *distanceText = [NSString stringWithFormat:@"%.2f", distanceFromSF];
    float compassBearing = [self getHeadingForDirectionFromCoordinate:sfCoordinate toCoordinate:newLocation.coordinate];
    NSString *compassDirectionString = [self getCompassDirection:compassBearing];
    NSString *directionText = [NSString stringWithFormat:@"miles %@ from San Francisco.", compassDirectionString];
    [_distanceLabel setText:distanceText];
    [_directionLabel setText:directionText];
}

// Gets the bearing between two points
- (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc {
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    float degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    return (degree >= 0) ? degree : 360 + degree;
}

// Gets the compass direction from the bearing
- (NSString*)getCompassDirection:(float)bearing {
    NSArray *directions = @[@"NE", @"E", @"SE", @"S", @"SW", @"W", @"NW", @"N"];
    float indexFloat = bearing - 22.5;
    if (indexFloat < 0) {
        indexFloat += 360;
    }
    int index = floorf(indexFloat / 45);
    return directions[index];
}

@end
