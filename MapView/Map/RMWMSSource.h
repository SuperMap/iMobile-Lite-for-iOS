//
//  RMWMSSource.h
//
// Copyright (c) 2008-2011, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>

#import "RMAbstractMercatorWebSource.h"
#import "RMTile.h"
#import "RMWMS.h"
 /**
 * Class: RMWMSSource
 * Subclass of RMAbstractMercatorWebSource for access to OGC WMS Server.
 * (code)
 * Example:
 * RMWMS *wms = [[RMWMS alloc] init];
 * [wms setUrlPrefix:@"http://vmap0.tiles.osgeo.org/wms/vmap0"];
 * [wms setLayers:@"basic"];
 * RMWMSSource *wmsSource = [[RMWMSSource alloc] init];
 * [wmsSource setWms:wms];
 * [mapContents setTileSource:wmsSource];
 * [wmsSource release];
 * [wms release];
 * (end)
 *
 *  Inherits from:
 *  - <RMAbstractMercatorWebSource>
 */
@interface RMWMSSource : RMAbstractMercatorWebSource <RMAbstractMercatorWebSource> {

    float initialResolution;
    float originShift;
    
    float minZoom;
    float maxZoom;
    NSString *name;
    NSString *uniqueTilecacheKey;
    
    RMWMS *wms;
    
}

@property float minZoom;
@property float maxZoom;
@property (retain) NSString *name;
@property (retain) NSString *uniqueTilecacheKey;
@property (retain) RMWMS *wms;

-(NSString*) bboxForTile: (RMTile) tile;
-(float) resolutionAtZoom : (int) zoom ;
-(CGPoint) pixelsToMetersAtZoom: (int) px PixelY:(int)py atResolution:(float) resolution ;

@end
