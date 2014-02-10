//
//  ALGPSHelper.h
//  TestGPS
//
//  Created by Albert on 13-8-29.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CSqlite.h"
#import <MapKit/MapKit.h>

@interface ALGPSHelper : NSObject <CLLocationManagerDelegate>
{
    CSqlite *_m_sqlite;
    CLLocationManager *_locationManager;
}

+ (ALGPSHelper *)OpenGPS;
- (void)initMapWithFrame:(CGRect)frame superView:(UIView *)superView;

@property (readonly, nonatomic)  CLLocationDegrees latitude;
@property (readonly, nonatomic)  CLLocationDegrees longitude;
@property (readonly, nonatomic)  CLLocationDegrees offLatitude;
@property (readonly, nonatomic)  CLLocationDegrees offLongitude;
@property (readonly, nonatomic)  NSString *LocationName;

@property (readonly, nonatomic)  MKMapView *m_map;

@end
