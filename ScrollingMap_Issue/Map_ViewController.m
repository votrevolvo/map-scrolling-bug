//
//  Map_ViewController.m
//  ScrollingMap_Issue
//
//  Created by Juraj Mikula on 26/09/14.
//  Copyright (c) 2014 eikim. All rights reserved.
//

#import "AppDelegate.h"

#import "Map_ViewController.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"

#import "mach/mach.h"



@interface Map_ViewController ()

@end

@implementation Map_ViewController
{
    NSMutableArray *array_geo_id;
    NSMutableArray *array_gps_latitude;
    NSMutableArray *array_gps_longitude;
    NSMutableArray *array_marker_type;
    
    NSMutableArray *array_company_name;
    NSMutableArray *array_company_descr;
    NSMutableArray *array_category;
    
    NSMutableArray *array_marker_id;
    NSMutableArray *person;
    
}



- (void)loadView
{
    [super loadView];
    mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 200.0)];
    [mapView setBackgroundColor:[UIColor whiteColor]];
    mapView.delegate = self;
    self.view = mapView;
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:1];
    is_moving = NO;

}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    mapSrc = [[RMDBMapSource alloc] initWithPath:@"mymap.sqlite"];
    RMMapContents *content = [[RMMapContents alloc] initWithView:mapView tilesource:mapSrc];
    
    markerManager = [[RMMarkerManager alloc] initWithContents:content];
    [mapView setConstraintsSW:CLLocationCoordinate2DMake(mapSrc.bottomRightOfCoverage.latitude, mapSrc.topLeftOfCoverage.longitude)
                           NE:CLLocationCoordinate2DMake(mapSrc.topLeftOfCoverage.latitude, mapSrc.bottomRightOfCoverage.longitude)];
    [mapView moveToLatLong:mapSrc.centerOfCoverage];

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(1.230278, 103.83);
    [mapView.contents moveToLatLong:center];
    [mapView.contents setZoom:11.0f];  // 11.5f
    [self addMarkers];
}


- (void) addMarkers
{
    
    
    NSString *geo_id              = @"";
    NSString *guide_parent_id     = @"";
    NSString *gps_latitude        = @"";
    NSString *gps_longitude       = @"";
    NSString *marker_type         = @"";
    
    
    array_geo_id           = [[NSMutableArray alloc] init];
    array_gps_latitude     = [[NSMutableArray alloc] init];
    array_gps_longitude    = [[NSMutableArray alloc] init];
    array_marker_type      = [[NSMutableArray alloc] init];
    array_marker_id        = [[NSMutableArray alloc] init];
    
    
    //person = [[NSMutableArray alloc]init];
    
    
    CLLocationCoordinate2D location;
    UIImage *image;
    RMMarker *marker;
    
    
    NSLog(@"Opened DB");
    sqlite3 *contactDB; //Declare a pointer to sqlite database structure
    NSString *databasePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"data.sqlite"];
    NSLog(@"databasePath: %@\n", databasePath);
    
    const char *dbpath = [databasePath UTF8String]; // Convert NSString to UTF-8
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        //Database opened successfully
        NSLog(@"SQLite: Database opened successfully");
    } else {
        //Failed to open database
        NSLog(@"SQLite: Failed to open database");
    }
    
    sqlite3_stmt *statement;
    NSString *querySQL = @"";
    querySQL = [NSString stringWithFormat:@"SELECT id, parent_id, gps_latitude, gps_longitude, marker_type FROM geopoints ORDER BY id ASC;"];
    
    NSLog(@"SQL query: %@\n", querySQL);
    const char *query_stmt = [querySQL UTF8String];
    NSLog(@"could not prepare statement: %s\n", sqlite3_errmsg(contactDB));
    
    if (sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            geo_id              = @"";
            guide_parent_id     = @"";
            gps_latitude        = @"";
            gps_longitude       = @"";
            marker_type         = @"";
            
            
            char* local_geo_id  = (char*)sqlite3_column_text(statement, 0);
            if(local_geo_id !=NULL)
            {
                geo_id = [NSString stringWithUTF8String: local_geo_id];
            }
            char* local_parent_id  = (char*)sqlite3_column_text(statement, 1);
            if(local_parent_id !=NULL)
            {
                guide_parent_id = [NSString stringWithUTF8String: local_parent_id];
            }
            char* local_gps_latitude  = (char*)sqlite3_column_text(statement, 2);
            if(local_gps_latitude !=NULL)
            {
                gps_latitude = [NSString stringWithUTF8String: local_gps_latitude];
            }
            char* local_gps_longitude  = (char*)sqlite3_column_text(statement, 3);
            if(local_gps_longitude !=NULL)
            {
                gps_longitude = [NSString stringWithUTF8String: local_gps_longitude];
            }
            char* local_marker_type  = (char*)sqlite3_column_text(statement, 4);
            if(local_marker_type !=NULL)
            {
                marker_type = [NSString stringWithUTF8String: local_marker_type];
            }
            
            [array_geo_id addObject:geo_id];
            [array_gps_latitude addObject:gps_latitude];
            [array_gps_longitude addObject:gps_longitude];
            [array_marker_type addObject:marker_type];

            float float_gps_latitude = [gps_latitude floatValue];
            float float_gps_longitude = [gps_longitude floatValue];
            location = CLLocationCoordinate2DMake(float_gps_latitude, float_gps_longitude);
            
            image = [UIImage imageNamed:marker_type];
            marker = [[RMMarker alloc] initWithUIImage:image];
            
            marker.anchorPoint = CGPointMake(0.5, 1);
            [marker setTextForegroundColor:[UIColor blackColor]];
            [marker setTextBackgroundColor:[UIColor blackColor]];
            
            NSLog(@"Marker: %@\ngeoId: %@\n", marker, geo_id);
            [array_marker_id addObject:marker];

            [self addLabelToMarker:marker text:geo_id];
            [markerManager addMarker:marker AtLatLong:location];
        }
        sqlite3_finalize(statement);
    }
    else
    {
        NSLog(@"SQLite error: %s\n", sqlite3_errmsg(contactDB));
    }
    
    sqlite3_close(contactDB);
    NSLog(@"adding marker");
}


- (void) addLabelToMarker:(RMMarker*)marker text:(NSString*)text
{
    NSString *geo_id              = @"";
    NSString *guide_parent_id     = @"";
    NSString *company_name        = @"";
    NSString *company_descr       = @"";
    NSString *category            = @"";

    UIView *view;
    UILabel *label;
    UILabel *descr;
    UILabel *label_cat;
    
    
    NSLog(@"Opened DB");
    sqlite3 *contactDB; //Declare a pointer to sqlite database structure
    NSString *databasePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"data.sqlite"];
    NSLog(@"databasePath: %@\n", databasePath);
    
    const char *dbpath = [databasePath UTF8String]; // Convert NSString to UTF-8
    
    if (sqlite3_open(dbpath, &contactDB) == SQLITE_OK)
    {
        //Database opened successfully
        NSLog(@"SQLite: Database opened successfully");
    } else {
        //Failed to open database
        NSLog(@"SQLite: Failed to open database");
    }
    
    sqlite3_stmt *statement;
    NSString *querySQL = @"";
    querySQL = [NSString stringWithFormat:@"SELECT id, parent_id, company_name, company_descr, category FROM geopoints WHERE id='%@' LIMIT 1;", text];
    
    NSLog(@"SQL query: %@\n", querySQL);
    const char *query_stmt = [querySQL UTF8String];
    NSLog(@"could not prepare statement: %s\n", sqlite3_errmsg(contactDB));
    
    if (sqlite3_prepare_v2(contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
    {
        //NSLog(@"SQLite OK");
        NSLog(@"SQLite ok");
        
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            geo_id              = @"";
            guide_parent_id     = @"";
            company_name        = @"";
            company_descr       = @"";
            category            = @"";
            
            
            char* local_geo_id  = (char*)sqlite3_column_text(statement, 0);
            if(local_geo_id !=NULL)
            {
                geo_id = [NSString stringWithUTF8String: local_geo_id];
            }
            char* local_parent_id  = (char*)sqlite3_column_text(statement, 1);
            if(local_parent_id !=NULL)
            {
                guide_parent_id = [NSString stringWithUTF8String: local_parent_id];
            }
            char* local_company_name  = (char*)sqlite3_column_text(statement, 2);
            if(local_company_name !=NULL)
            {
                company_name = [NSString stringWithUTF8String: local_company_name];
            }
            char* local_company_descr  = (char*)sqlite3_column_text(statement, 3);
            if(local_company_descr !=NULL)
            {
                company_descr = [NSString stringWithUTF8String: local_company_descr];
            }
            char* local_category  = (char*)sqlite3_column_text(statement, 4);
            if(local_category !=NULL)
            {
                category = [NSString stringWithUTF8String: local_category];
            }
            
            local_geo_id = nil;
            local_parent_id = nil;
            local_company_name = nil;
            local_company_descr = nil;
            local_category = nil;
            
            
            //We create the view that will act as a label for the marker
            //This will set the position of the marker
            view = [[UIView alloc] initWithFrame:CGRectMake(-45 , 65, 170, 100)];
            view.layer.cornerRadius = 4;
            view.layer.borderColor = [[UIColor grayColor] CGColor];
            view.layer.borderWidth = 1;
            view.backgroundColor = [UIColor whiteColor];
            view.alpha = 0.8;
            
            
            //the presentation text
            label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 150, 15)];
            label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = company_name;
            label.numberOfLines = 1;
            [label sizeToFit];
            
            
            descr = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 150, 70)];
            descr.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
            descr.text = company_descr;
            descr.textAlignment = NSTextAlignmentCenter;
            descr.numberOfLines = 5;
            [descr sizeToFit];
            
            
            label_cat = [[UILabel alloc] initWithFrame:CGRectMake(10, 85, 150, 15)];
            label_cat.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
            label_cat.text = category;
            label_cat.textAlignment = NSTextAlignmentCenter;
            label_cat.numberOfLines = 1;
            [label_cat sizeToFit];
            

            label.textColor = [UIColor blackColor];
            descr.textColor = [UIColor blackColor];
            label_cat.textColor = [UIColor blackColor];
            
            
            //add the button and the label to the label
            [view addSubview:label];
            [view addSubview:descr];
            [view addSubview:label_cat];
            
            
            [marker setLabel:view];
            [marker hideLabel];
        }
        sqlite3_finalize(statement);
    }
    else
    {
        NSLog(@"SQLite error: %s\n", sqlite3_errmsg(contactDB));
    }
}

- (void) singleTapOnMap: (RMMapView*) map At: (CGPoint) point;
{
    for (RMMarker *marker in [markerManager markers]) {
        NSLog(@"marker not");
        [marker hideLabel];
    }
    
}
- (void) tapOnMarker: (RMMarker*) tappedMarker onMap: (RMMapView*) map
{
    //callback for the tap on any marker on the map
    //We fetch all the other marker, hide their label
    //if the marker is the one we tapped on, we display the label
    
    NSLog(@"tapOnMarker: %@\n", tappedMarker);
    for (RMMarker *marker in [markerManager markers]) {
        if (marker == tappedMarker) {
            NSLog(@"marker tapped");
            [marker toggleLabel];
            
            NSLog(@"Tapped marker description: %@\n", marker.label);
            
            
            target = [map pixelToLatLong:marker.position];

            [self moveToTargetWithAnimation];
            
        } else {
            NSLog(@"marker not");
            [marker hideLabel];
        }
    }
}

- (void)moveToTargetWithAnimation {
    // if we are on the move, return right away. we want the current move to finish.
    if (is_moving)
        return;
    // remember that we are moving
    is_moving = true;
    
    // get the current location
    from = [mapView pixelToLatLong:mapView.center];
    
    
    // initialize step and steps (member variables)
    step = 1;
    
    nsteps = 30;
    //nsteps = 1;
    //[markerManager hideAllMarkers];
    // create 'nsteps' operation objects that will be executed in the queue thread
    for (int i = 0; i < nsteps; i++) {
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(moveToLocationWithOperation)
                                                                                  object:nil];
        
        [queue addOperation:operation];
    }
}

- (void) moveToLocationWithOperation {
    [self performSelectorOnMainThread:@selector(makeMapViewChange) withObject:nil waitUntilDone:NO];
    usleep(20000); // adjust for your tastes
    step++;
    
    
    // not moving anymore if we reached the desired number of steps
    if (step == nsteps)
        is_moving = false;
}


- (void) makeMapViewChange {
    // intermediate target
    CLLocationCoordinate2D tmpTarget;
    float p = (1.0 * (nsteps - step)) / nsteps;
    float q = (1.0 * step) / nsteps;
    // this is a linear function. could get fancy with p and q depending on step.
    tmpTarget.latitude = from.latitude * p + target.latitude * q;
    tmpTarget.longitude = from.longitude * p + target.longitude * q;
    

    CLLocationCoordinate2D secondLocation;
	secondLocation.latitude = -43.63;
	secondLocation.longitude = 172.66;
	[[mapView contents] moveToLatLong:tmpTarget];

    [mapView moveToLatLong:tmpTarget];
    if (step == nsteps) {
        [mapView moveToLatLong:target];
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
