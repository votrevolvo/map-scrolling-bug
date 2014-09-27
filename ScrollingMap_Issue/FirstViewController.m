//
//  FirstViewController.m
//  ScrollingMap_Issue
//
//  Created by Juraj Mikula on 25/09/14.
//  Copyright (c) 2014 eikim. All rights reserved.
//

#import "FirstViewController.h"

#import "RMMapView.h"

@interface FirstViewController ()

@property (strong, nonatomic) IBOutlet UIView *MyMapContainer;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    // Set Positions
    
    
    
    //if (self.view.bounds.size.height == 568)
    if (self.view.bounds.size.height == 519)    // len pri NavController a bez hornych tabov
    {
        // 4" phone (1136 X 640)
        
        // [MAP CONTAINER] UIView mapy
        CGRect MyMapContainer_frame = self.MyMapContainer.frame;
        MyMapContainer_frame.origin.x = 0;
        MyMapContainer_frame.origin.y = 0;
        MyMapContainer_frame.size.width = 320;
        MyMapContainer_frame.size.height = 524;
        self.MyMapContainer.frame = MyMapContainer_frame;
        
        
        
    }
    else
    {
        // 3.5" phone (960 X 640)
        
        // [MAP CONTAINER] UIView mapy
        CGRect MyMapContainer_frame = self.MyMapContainer.frame;
        MyMapContainer_frame.origin.x = 0;
        MyMapContainer_frame.origin.y = 0;
        MyMapContainer_frame.size.width = 320;
        MyMapContainer_frame.size.height = 436;
        self.MyMapContainer.frame = MyMapContainer_frame;
        
    }
    
}

@end
