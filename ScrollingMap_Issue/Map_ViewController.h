//
//  Map_ViewController.h
//  ScrollingMap_Issue
//
//  Created by Juraj Mikula on 26/09/14.
//  Copyright (c) 2014 eikim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"
#import "RMDBMapSource.h"
#import "RMMapViewDelegate.h"

@interface Map_ViewController : UIViewController <RMMapViewDelegate>
{
    RMMapView *mapView;
    RMDBMapSource *mapSrc;
    RMMarkerManager *markerManager;
    NSOperationQueue *queue;
    BOOL is_moving;
    int step;
    int nsteps;
    CLLocationCoordinate2D from;
    CLLocationCoordinate2D target;
}

@end
