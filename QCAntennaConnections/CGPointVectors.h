//
//  CGPointVectors.h
//  QCAntennaConnections
//
//  Created by Bartosz Ciechanowski on 01.04.2014.
//  Copyright (c) 2014 Macoscope. All rights reserved.
//

#ifndef QCAntennaConnections_CGPointVectors_h
#define QCAntennaConnections_CGPointVectors_h

static inline CGPoint CGPointAdd(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

static inline CGPoint CGPointSub(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}

static inline CGPoint CGPointScale(CGPoint p, CGFloat s)
{
    return CGPointMake(p.x * s, p.y * s);
}


#endif
