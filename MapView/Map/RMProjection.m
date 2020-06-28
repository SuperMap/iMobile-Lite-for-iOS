//
//  RMProjection.m
//
// Copyright (c) 2008-2009, Route-Me Contributors
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
#import "RMGlobalConstants.h"
#import "proj_api.h"
#import "RMProjection.h"
#import "MapView_Prefix.pch"


NS_INLINE RMLatLong RMPixelPointAsLatLong(RMProjectedPoint xypoint) {
    union _ {RMProjectedPoint xy; RMLatLong latLong;};
    return ((union _ *)&xypoint)->latLong;
}


@implementation RMProjection

@synthesize internalProjection;
@synthesize planetBounds;
@synthesize projectionWrapsHorizontally;
@synthesize bIsSM;
@synthesize epsgCode;

- (id) initWithString: (NSString*)params InBounds: (RMProjectedRect) projBounds
{
	if (![super init])
		return nil;
	
	internalProjection = pj_init_plus([params UTF8String]);
	if (internalProjection == NULL)
	{
		RMLog(@"Unhandled error creating projection. String is %@", params);
		[self release];
		return nil;
	}
	//左下角点
	planetBounds = projBounds;

	projectionWrapsHorizontally = YES;
	
	return self;
}

- (id) initWithString: (NSString*)params
{
	RMProjectedRect theBounds;
	theBounds = RMMakeProjectedRect(0,0,0,0);
	return [self initWithString:params InBounds:theBounds];
}

-(id)init
{
	return [self initWithString:@"+proj=latlong +ellps=WGS84"];
}

-(id)initForSMProjection
{
	self.bIsSM=true;
    return [self initWithString:@"+title= Google Mercator EPSG:900913\
            +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"];
}

-(id)projectionWithBounds:(RMProjectedRect) projBounds EPSGCode:(NSString*) _epsgCode
{
	self.planetBounds=projBounds;
    self.epsgCode=_epsgCode;
    return self;
}

-(id)projectionWithBounds:(RMProjectedRect) projBounds
{
    self.planetBounds=projBounds;
    return self;
}

-(void)dealloc
{
	if (internalProjection)
		pj_free(internalProjection);
	
	[super dealloc];
}

- (RMProjectedPoint) wrapPointHorizontally: (RMProjectedPoint) aPoint
{
    if (bIsSM) {
        
        if (aPoint.easting < (planetBounds.origin.easting))
            aPoint.easting = planetBounds.origin.easting;
        if (aPoint.easting > (planetBounds.origin.easting + planetBounds.size.width))
            aPoint.easting = planetBounds.origin.easting+planetBounds.size.width;
        if (aPoint.northing < planetBounds.origin.northing)
            aPoint.northing = planetBounds.origin.northing;
        else if (aPoint.northing > (planetBounds.origin.northing + planetBounds.size.height))
            aPoint.northing = planetBounds.origin.northing + planetBounds.size.height;
//        NSLog(@"planetBounds %f %f %f",planetBounds.origin.northing,planetBounds.origin.easting, planetBounds.size.width);
        return aPoint;
    }
    else
    {
        if (!projectionWrapsHorizontally
            || planetBounds.size.width == 0.0f || planetBounds.size.height == 0.0f)
            return aPoint;
        
        while (aPoint.easting < planetBounds.origin.easting)
            aPoint.easting += planetBounds.size.width;
        while (aPoint.easting > (planetBounds.origin.easting + planetBounds.size.width))
            aPoint.easting -= planetBounds.size.width;
    }
    
	
	
	return aPoint;
}

-(RMProjectedPoint) constrainPointToBounds: (RMProjectedPoint) aPoint
{
	if (planetBounds.size.width == 0.0f || planetBounds.size.height == 0.0f)
		return aPoint;
	
	[self wrapPointHorizontally:aPoint];
	
	if (aPoint.northing < planetBounds.origin.northing)
		aPoint.northing = planetBounds.origin.northing;
	else if (aPoint.northing > (planetBounds.origin.northing + planetBounds.size.height))
		aPoint.northing = planetBounds.origin.northing + planetBounds.size.height;
	
	return aPoint;
}

- (RMProjectedPoint)latLongToPoint:(RMLatLong)aLatLong
{
    if (bIsSM) {
        RMProjectedPoint result_pointSm = {
            aLatLong.longitude,
            aLatLong.latitude,
        };
        return result_pointSm;
    }
	projUV uv = {
		aLatLong.longitude * DEG_TO_RAD,
		aLatLong.latitude * DEG_TO_RAD
	};
    
	projUV result = pj_fwd(uv, internalProjection);
    
	RMProjectedPoint result_point = {
		result.u,
		result.v,
	};
	return result_point;
}

- (RMLatLong)pointToLatLong:(RMProjectedPoint)aPoint
{
	projUV uv = {
		aPoint.easting,
		aPoint.northing,
	};
	
	projUV result = pj_inv(uv, internalProjection);
	
	RMLatLong result_coordinate = {
		result.v * RAD_TO_DEG,
		result.u * RAD_TO_DEG,
	};
	
	return result_coordinate;
}

static RMProjection* _google = nil;
static RMProjection* _latlong = nil;
static RMProjection* _osgb = nil;
static RMProjection* _sm = nil;
static RMProjection* _userDefined = nil;

+ (RMProjection*)googleProjection
{
	if (_google)
	{
		return _google;
	}
	else
	{
/// \bug magic numbers embedded in code, this one's probably ok
		RMProjectedRect theBounds = RMMakeProjectedRect(-20037508.34, -20037508.34, 20037508.34 * 2, 20037508.34 * 2);
		
		_google = [[RMProjection alloc] initWithString:@"+title= Google Mercator EPSG:900913\
				   +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"
											  InBounds: theBounds];
		_google.bIsSM = false;
        return _google;
	}
}

+ (RMProjection*)smProjection:(RMProjectedRect)bounds //bottom:(double)dbottom right:(double)dwidth bottom:(double)dheight
{
	if (_sm)
	{
		return _sm;
	}
	else
	{
        /// \bug magic numbers embedded in code, this one's probably ok
		//RMProjectedRect theBounds = RMMakeProjectedRect(-20037508.34, -20037508.34, 20037508.34 * 2, 20037508.34 * 2);
		
		_sm = [[RMProjection alloc] initWithString:@"+title= Google Mercator EPSG:900913\
               +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"
                                          InBounds: bounds];
		_sm.bIsSM = true;
        return _sm;
	}
}

+ (RMProjection*)EPSGLatLong
{
	if (_latlong)
	{
		return _latlong;
	}
	else
	{
		RMProjectedRect theBounds = RMMakeProjectedRect(-kMaxLong, -kMaxLat, 360, kMaxLong);
		
		/// \bug magic numbers embedded in code, this one's probably ok
		_latlong = [[RMProjection alloc] initWithString:@"+proj=latlong +ellps=WGS84" InBounds: theBounds];
		_latlong.bIsSM = false;
        return _latlong;
	}
}

+(RMProjection*) OSGB
{
	if (_osgb)
	{
		return _osgb;
	}
	else
	{// OSGB36 and tmerc
		/// \bug TODO: This should use the new initWithString:InBounds: method... but I don't know what the bounds are!
		/// \bug magic numbers embedded in code, this one's probably ok
		_osgb = [[RMProjection alloc] initWithString:@"+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.999601 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs"];
		_osgb.projectionWrapsHorizontally = NO;
		_osgb.bIsSM = false;
        return _osgb;
	}
}

+(RMProjection*) userDefinedProjection{
    if (_userDefined) {
        return _userDefined;
    }
    double dHeight = 85.051128779806*2;
    double dWidth = 180*2;
    double dleft = -180;
    double dbottom = -85.051128779806;
    RMProjectedRect theBounds = RMMakeProjectedRect(dleft,dbottom,dWidth,dHeight);
    
    _userDefined = [[RMProjection alloc] initWithString:@"+title= Google Mercator EPSG:900913\
           +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"
                                      InBounds: theBounds];
    _userDefined.bIsSM = false;
    
    return _userDefined;
}

@end
