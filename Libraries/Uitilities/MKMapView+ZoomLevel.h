//
//  MKMapView+ZoomLevel.h
//  MapApp
//
//  Created by Kai on 7/30/10.
//  Copyright 2010 NONAME STUDIO. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (MKCoordinateRegion)regionForCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSUInteger)zoomLevel;

- (MKCoordinateRegion)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                zoomLevel:(NSUInteger)zoomLevel
                                 animated:(BOOL)animated;

- (int)zoomLevel;

@end
