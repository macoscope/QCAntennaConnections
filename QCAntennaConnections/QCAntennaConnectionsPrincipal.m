//
//  QCAntennaConnectionsPrincipal.m
//  QCAntennaConnections
//
//  Created by Bartosz Ciechanowski on 01.04.2014.
//  Copyright (c) 2014 Macoscope. All rights reserved.
//

#import "QCAntennaConnectionsPrincipal.h"
#import "CGPointVectors.h"

@implementation QCAntennaConnectionsPrincipal

+ (void)initialize
{
    SwizzleInstanceMethod([GFGraphView class], @selector(boundsForConnection:fromPoint:toPoint:), @selector(BC_boundsForConnection:fromPoint:toPoint:));
    SwizzleInstanceMethod([QCPatchView class], @selector(drawConnection:fromPoint:toPoint:), @selector(BC_drawConnection:fromPoint:toPoint:));
    SwizzleInstanceMethod([QCPatchView class], @selector(_drawConnection:fromPort:point:toPoint:), @selector(BC__drawConnection:fromPort:point:toPoint:));
}

+ (void)registerNodesWithManager:(GFNodeManager*)manager
{
    
}

void SwizzleInstanceMethod(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@end



@implementation QCPatchView(CustomConnectionDrawing)

- (BOOL) BC_isInteractionPort:(GFPort *)port
{
    return [port.originalPort isKindOfClass:[QCInteractionPort class]];
}

- (void)BC_drawConnection:(QCLink *)link fromPoint:(NSPoint)from toPoint:(NSPoint)to
{
    [self BC_drawActualConnection:link fromPort:link.sourcePort fromPoint:from toPoint:to];
}

- (void)BC__drawConnection:(QCLink *)link fromPort:(GFPort *)port point:(NSPoint)from toPoint:(NSPoint)to
{
    [self BC_drawActualConnection:link fromPort:port fromPoint:from toPoint:to];
}

- (void)BC_drawActualConnection:(QCLink *)link fromPort:(GFPort *)port fromPoint:(NSPoint)from toPoint:(NSPoint)to
{
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    CGPoint diff = CGPointSub(to, from);
    
    CGFloat angle = atan2(diff.y, diff.x);
    
    CGPoint centers[] = {from, to};
    CGFloat offsets[] = {13.0, -13.0};
    CGFloat angles[] = {angle, angle + M_PI};
    
    void (^strokeBlock)(NSBezierPath *) = ^(NSBezierPath *path) {
        [path setLineCapStyle:NSRoundLineCapStyle];
        
        [path setLineWidth:4.0];
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.7] setStroke];
        [path stroke];
        
        [path setLineWidth:2.0];
        [[self _colorForConnection:link] setStroke];
        [path stroke];
    };
    
    
    for (int i = 0; i < 2; i++) {
        
        NSBezierPath *stem = [NSBezierPath bezierPath];
        [stem moveToPoint:centers[i]];
        [stem lineToPoint:CGPointAdd(centers[i], CGPointMake(offsets[i], 0))];
        
        strokeBlock(stem);
        
        
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:centers[i].x + offsets[i] yBy:centers[i].y];
        [transform rotateByRadians:angles[i]];
        
        NSBezierPath *AntennaPath = [self BC_AntennaBezierPath];
        [AntennaPath transformUsingAffineTransform:transform];
        
        [AntennaPath setLineWidth:1.0];
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.7] setStroke];
        [AntennaPath stroke];
        
        [[self _colorForConnection:link] setFill];
        [AntennaPath fill];
        
        
        for (int wave = 0; wave < 3; wave++) {
            NSBezierPath *wavePath = [self BC_wavesBezierPathWithRadius:wave * 4.0 + 2.0];
            [wavePath transformUsingAffineTransform:transform];
            
            strokeBlock(wavePath);
        }
    }

    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}


- (NSBezierPath *)BC_AntennaBezierPath
{
    const CGFloat radius = 9.0;
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    
    [path appendBezierPathWithArcWithCenter:CGPointMake(radius, 0)
                                     radius:radius
                                 startAngle:130
                                   endAngle:230
                                  clockwise:NO];
    
    [path closePath];
    
    return path;
}

- (NSBezierPath *)BC_wavesBezierPathWithRadius:(CGFloat)radius
{
    const CGFloat CenterOffset = 5.0;
    const CGFloat Aperture = 80.0;
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path appendBezierPathWithArcWithCenter:CGPointMake(-radius, 0)
                                     radius:radius
                                 startAngle:0
                                   endAngle:Aperture
                                  clockwise:NO];
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:CenterOffset yBy:0];
    [transform rotateByDegrees:-Aperture/2.0];
    [transform translateXBy:radius yBy:0];

    [path transformUsingAffineTransform:transform];
    
    
    return path;
}

@end


@implementation GFGraphView(CustomConnectionDrawing)

- (NSRect)BC_boundsForConnection:(id)fp8 fromPoint:(NSPoint)from toPoint:(NSPoint)to
{
    return CGRectInset(CGRectMake(MIN(from.x, to.x), MIN(from.y, to.y), fabs(from.x - to.x), fabs(from.y - to.y)), -30, -30);
}

@end