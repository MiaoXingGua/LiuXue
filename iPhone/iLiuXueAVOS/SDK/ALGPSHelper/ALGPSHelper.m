//
//  ALGPSHelper.m
//  TestGPS
//
//  Created by Albert on 13-8-29.
//
//

#import "ALGPSHelper.h"
#import "ALUserEngine.h"

static ALGPSHelper *gps = nil;

@class Annotation;

@interface ALGPSHelper()
@property (nonatomic, retain) CSqlite *m_sqlite;
@property (nonatomic, retain) CLLocationManager *locationManager;
@end

@implementation ALGPSHelper

- (void)dealloc
{
    [_m_sqlite release];
    [super dealloc];
}

- (void)setLatitude:(CLLocationDegrees)latitude
{
    _latitude = latitude;
}

- (void)setLongitude:(CLLocationDegrees)longitude
{

    _longitude = longitude;
}

- (void)setOffLatitude:(CLLocationDegrees)offLatitude
{

    _offLatitude = offLatitude;
}

- (void)setOffLongitude:(CLLocationDegrees)offLongitude
{

    _offLongitude = offLongitude;
}

- (void)setLocationName:(NSString *)LocationName
{

    _LocationName = LocationName;
}

- (void)setM_map:(MKMapView *)m_map
{
    [_m_map release];
    _m_map = [m_map retain];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.m_sqlite = [[[CSqlite alloc] init] autorelease];
//        m_sqlite
        
    }
    return self;
}

+ (ALGPSHelper *)OpenGPS
{
    if (!gps) {
        gps = [[ALGPSHelper alloc] init];
        [gps OpenGPS];
        [gps.m_sqlite openSqlite];
    }
    
    return gps;
}

- (BOOL)OpenGPS
{
    if ([CLLocationManager locationServicesEnabled])
    { // 检查定位服务是否可用
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter=200;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation]; // 开始定位
        NSLog(@"GPS 启动成功");
        
        return YES;
    }
    else
    {
        NSLog(@"GPS 启动失败！！！");
        return NO;
    }
}

- (void)initMapWithFrame:(CGRect)frame superView:(UIView *)superView
{
    self.m_map = [[[MKMapView alloc] initWithFrame:frame] autorelease];
    self.m_map.showsUserLocation = YES;//显示ios自带的我的位置显示
    
    [self OpenGPS];
}

// 定位成功时调用
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D mylocation = newLocation.coordinate;//手机GPS
    self.latitude = mylocation.latitude;
    self.longitude = mylocation.longitude;
    
    mylocation = [self zzTransGPS:mylocation];///火星GPS
    self.offLatitude = mylocation.latitude;
    self.offLongitude = mylocation.longitude;
    
    //显示火星坐标
    if (self.m_map) [self SetMapPoint:mylocation];
    
    /////////获取位置信息
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray* placemarks,NSError *error)
     {
         if (placemarks.count > 0)
         {
             CLPlacemark * plmark = [placemarks objectAtIndex:0];
             //NSString *location = plmark.addressDictionary[@"FormattedAddressLines"];
             

             NSLog(@"定位成功，位置：%@",plmark.locality);
             
             
//             NSString * country = plmark.country;
//             NSString * city    = plmark.locality;
//
//             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@,%@,%@",country,city,plmark.name] delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil, nil];
//             [alert show];
//             [alert release];
             
             NSLog(@"%@,%@,%@,%@,%@,%@",[plmark.addressDictionary objectForKey:@"Country"],[[plmark.addressDictionary objectForKey:@"FormattedAddressLines"] objectAtIndex:0],[plmark.addressDictionary objectForKey:@"Name"],[plmark.addressDictionary objectForKey:@"State"],[plmark.addressDictionary objectForKey:@"SubLocality"],[plmark.addressDictionary objectForKey:@"Thoroughfare"]);
             
             NSString *_place = [NSString stringWithFormat:@"%@%@",[plmark.addressDictionary objectForKey:@"State"],[plmark.addressDictionary objectForKey:@"SubLocality"]];
             
             if (_place.length==0)
             {
                 self.LocationName=@"";
             }
             else
             {
                 self.LocationName=[_place retain];
             }
             
//             NSLog(@"plmark=%@",plmark.addressDictionary);
//             NSLog(@"plmark=%@",plmark.thoroughfare);
//             NSLog(@"plmark=%@",plmark.subThoroughfare);
//             NSLog(@"plmark=%@",plmark.name);
//             NSLog(@"plmark=%@",plmark.locality);
//             NSLog(@"plmark=%@",plmark.subLocality);
//             NSLog(@"plmark=%@",plmark.administrativeArea);
//             NSLog(@"plmark=%@",plmark.subAdministrativeArea);
//
             //上传坐标
             [[ALUserEngine defauleEngine] uploadPointWithLatitude:self.latitude longitude:self.longitude place:_place block:^(BOOL succeeded, NSError *error) {
                 
                 if (succeeded)
                 {
                     NSLog(@"succeed");
                 }
             }];
//             self.LocationName = plmark.locality;
         }
         
//         NSLog(@"placemarks = %@ plmark.name = %@",placemarks,self.LocationName);
         
     }];
    
    [geocoder release];
    
}

// 定位失败时调用
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"定位失败!!!");
}

//坐标修正
-(CLLocationCoordinate2D)zzTransGPS:(CLLocationCoordinate2D)yGps
{
    int TenLat=0;
    int TenLog=0;
    TenLat = (int)(yGps.latitude*10);
    TenLog = (int)(yGps.longitude*10);
    NSString *sql = [[NSString alloc]initWithFormat:@"select offLat,offLog from gpsT where lat=%d and log = %d",TenLat,TenLog];
   // NSLog(sql);
    sqlite3_stmt* stmtL = [self.m_sqlite NSRunSql:sql];
    int offLat=0;
    int offLog=0;
    while (sqlite3_step(stmtL)==SQLITE_ROW)
    {
        offLat = sqlite3_column_int(stmtL, 0);
        offLog = sqlite3_column_int(stmtL, 1);
        
    }
    
    yGps.latitude = yGps.latitude+offLat*0.0001;
    yGps.longitude = yGps.longitude + offLog*0.0001;
    return yGps;
}

//地图
-(void)SetMapPoint:(CLLocationCoordinate2D)myLocation
{
    Annotation* m_poi = [[Annotation alloc] initWithCoords:myLocation];
    
    [self.m_map addAnnotation:m_poi];
    
    MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
    theRegion.center=myLocation;
    [self.m_map setZoomEnabled:YES];
    [self.m_map setScrollEnabled:YES];
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    [self.m_map setRegion:theRegion animated:YES];
}
@end

@interface Annotation : NSObject <MKAnnotation> {
    
    CLLocationCoordinate2D coordinate;
    NSString *subtitle;
    NSString *title;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *title;

-(id) initWithCoords:(CLLocationCoordinate2D) coords;

@end

@implementation Annotation

@synthesize coordinate,subtitle,title;

- (id) initWithCoords:(CLLocationCoordinate2D) coords{
    
    self = [super init];
    
    if (self != nil) {
        coordinate = coords;
    }
    return self;
}
@end