//
//  APYahooDataPullerGraph.m
//  StockPlot
//
//  Created by Jonathan Saggau on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "APYahooDataPullerGraph.h"


@implementation APYahooDataPullerGraph

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

-(void)reloadData
{
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    
    NSDecimalNumber *high = [dataPuller overallHigh];
    NSDecimalNumber *low = [dataPuller overallLow];
    NSDecimalNumber *length = [high decimalNumberBySubtracting:low];
    NSLog(@"high = %@, low = %@, length = %@", high, low, length);
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromInt([dataPuller.financialData count])];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:[low decimalValue] length:[length decimalValue]];
    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    
    axisSet.xAxis.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"10.0"];
    axisSet.xAxis.constantCoordinateValue = [NSDecimalNumber zero];
    axisSet.xAxis.minorTicksPerInterval = 1;
    
    axisSet.yAxis.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"50.0"];
    axisSet.yAxis.minorTicksPerInterval = 4;
    axisSet.yAxis.constantCoordinateValue = [NSDecimalNumber zero];
    
    [graph reloadData];
    [[self navigationItem] setTitle:[dataPuller symbol]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CPTheme *theme = [CPTheme themeNamed:@"Dark Gradients"];
	graph = [theme newGraph];
	graph.frame = self.view.bounds;
	[self.layerHost.layer addSublayer:graph];
    
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor redColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
	CPPlotSymbol *greenCirclePlotSymbol = [CPPlotSymbol plusPlotSymbol];
	greenCirclePlotSymbol.fill = [CPFill fillWithColor:[CPColor greenColor]];
    greenCirclePlotSymbol.size = CGSizeMake(2.0, 2.0);
    dataSourceLinePlot.defaultPlotSymbol = greenCirclePlotSymbol;	
        
    [self reloadData];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords {
    return self.dataPuller.financialData.count;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDecimalNumber *num = [NSDecimalNumber zero];
    if (fieldEnum == CPScatterPlotFieldX) 
    {
        num = (NSDecimalNumber *) [NSDecimalNumber numberWithInt:index + 1];
    }
    else if (fieldEnum == CPScatterPlotFieldY)
    {
        NSArray *financialData = self.dataPuller.financialData;
        
        NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:[financialData count] - index - 1];
        num = [fData objectForKey:@"close"];
        NSAssert(nil != num, @"grrr");
    }
    return num;
}

-(void)dataPullerDidFinishFetch:(APYahooDataPuller *)dp;
{

    [self reloadData];
}

#pragma mark accessors

@synthesize layerHost;

- (APYahooDataPuller *)dataPuller
{
    //NSLog(@"in -dataPuller, returned dataPuller = %@", dataPuller);
    
    return dataPuller; 
}
- (void)setDataPuller:(APYahooDataPuller *)aDataPuller
{
    //NSLog(@"in -setDataPuller:, old value of dataPuller: %@, changed to: %@", dataPuller, aDataPuller);
    
    if (dataPuller != aDataPuller) {
        [aDataPuller retain];
        [dataPuller release];
        dataPuller = aDataPuller;
        [dataPuller setDelegate:self];
        [self reloadData];
    }
}

- (void)dealloc {
    if(dataPuller.delegate == self)
        [dataPuller setDelegate:nil];
    [dataPuller release]; dataPuller = nil;
    [layerHost release]; layerHost = nil;
    [graph release]; graph = nil;
    
    [super dealloc];
}


@end
