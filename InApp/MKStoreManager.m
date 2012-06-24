

#import "MKStoreManager.h"
#import "GameOptionInfo.h"

@implementation MKStoreManager

@synthesize purchasableObjects;
@synthesize storeObserver;

// all your features should be managed one and only by StoreManager
//static NSString *featureAId = @"com.revolutiongamestoday.collectit.featureA";
//static NSString *featureAId = @"cat";
//static NSString *featureBId = @"dog";
//static NSString *featureCId = @"bird";
//static NSString *featureDId = @"graphics";
//static NSString *featureEId = @"food";
//static NSString *featureFId = @"sports";
//static NSString *featureGId = @"moutain";
//static NSString *featureHId = @"space";
//static NSString *featureIId = @"art";

static NSString *featureAId = @"SportsPack";
static NSString *featureBId = @"CatPack";
static NSString *featureCId = @"BirdPack";
static NSString *featureDId = @"DogPack";
static NSString *featureEId = @"GraphicsPack";
static NSString *featureFId = @"NaturePack";
static NSString *featureGId = @"SpacePack";
static NSString *featureHId = @"";
static NSString *featureIId = @"";

BOOL featureAPurchased;
BOOL featureBPurchased;
BOOL featureCPurchased;
BOOL featureDPurchased;
BOOL featureEPurchased;
BOOL featureFPurchased;
BOOL featureGPurchased;
BOOL featureHPurchased;
BOOL featureIPurchased;

//temp


static MKStoreManager* _sharedStoreManager; // self

- (void)dealloc {
	
	[_sharedStoreManager release];
	[storeObserver release];
	[super dealloc];
}

+ (BOOL) featurePurchased:(int)index {
	BOOL bRet;
	switch (index) {
		case 0: bRet = featureAPurchased; break;
		case 1:	bRet = featureBPurchased; break;
		case 2: bRet = featureCPurchased; break;
		case 3:	bRet = featureDPurchased; break;
		case 4:	bRet = featureEPurchased; break;
		case 5:	bRet = featureFPurchased; break;
		case 6:	bRet = featureGPurchased; break;
		case 7:	bRet = featureHPurchased; break;
		case 8:	bRet = featureIPurchased; break;
		default:
			break;
	}
	return bRet;
}
+ (BOOL) featureAPurchased {
	
	return featureAPurchased;
}

+ (BOOL) featureBPurchased {
	
	return featureBPurchased;
}

+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            [[self alloc] init]; // assignment not done here
			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];			
			[_sharedStoreManager requestProductData];
			
			[MKStoreManager loadPurchases];
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
        }
    }
    return _sharedStoreManager;
}


#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            _sharedStoreManager = [super allocWithZone:zone];			
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id)retain
{	
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;	
}


- (void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObjects: featureAId, featureBId, featureCId, featureDId, featureEId, featureFId, featureGId, featureHId, featureIId, nil]]; // add any other product here
	request.delegate = self;
	[request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[purchasableObjects addObjectsFromArray:response.products];
	// populate your UI Controls here
	for(int i=0;i<[purchasableObjects count];i++)
	{
		
		SKProduct *product = [purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
	}
	
	[request autorelease];
}

- (void) buyFeatureWithIndex:(int)index {
	NSString* str[] = { featureAId, featureBId, featureCId, featureDId,
                        featureEId, featureFId, featureGId, featureHId, featureIId };
	[self buyFeature:str[index]];
}
- (void) buyFeatureA
{
	[self buyFeature:featureAId];
}

- (void) buyFeature:(NSString*) featureId
{
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MyApp" message:@"You are not authorized to purchase from AppStore"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (void) restoreFeatures
{
    if ([SKPaymentQueue canMakePayments])
	{
		[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MyApp" message:@"You are not authorized to purchase from AppStore"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (void) buyFeatureB
{
	[self buyFeature:featureBId];
}


- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
}

-(void) provideContent: (NSString*) productIdentifier
{
	if([productIdentifier isEqualToString:featureAId]){
		featureAPurchased = YES;
        [g_GameOptionInfo setBuyPicState:0 buy:YES];
    }
	if([productIdentifier isEqualToString:featureBId]){
		featureBPurchased = YES;
        [g_GameOptionInfo setBuyPicState:1 buy:YES];
    }
	if([productIdentifier isEqualToString:featureCId]){
		featureCPurchased = YES;
        [g_GameOptionInfo setBuyPicState:2 buy:YES];
    }
	if([productIdentifier isEqualToString:featureDId]){
		featureDPurchased = YES;
        [g_GameOptionInfo setBuyPicState:3 buy:YES];
    }
	if([productIdentifier isEqualToString:featureEId]){
		featureEPurchased = YES;
        [g_GameOptionInfo setBuyPicState:4 buy:YES];
    }
	if([productIdentifier isEqualToString:featureFId]){
		featureFPurchased = YES;
        [g_GameOptionInfo setBuyPicState:5 buy:YES];
    }
	if([productIdentifier isEqualToString:featureGId]){
		featureGPurchased = YES;
        [g_GameOptionInfo setBuyPicState:6 buy:YES];
    }
	if([productIdentifier isEqualToString:featureHId]){
		featureHPurchased = YES;
        [g_GameOptionInfo setBuyPicState:7 buy:YES];
    }
	if([productIdentifier isEqualToString:featureIId]){
		featureIPurchased = YES;
        [g_GameOptionInfo setBuyPicState:8 buy:YES];
    }
	
	[MKStoreManager updatePurchases];
}


+(void) loadPurchases 
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];	
	featureAPurchased = [userDefaults boolForKey:featureAId]; 
	featureBPurchased = [userDefaults boolForKey:featureBId]; 	
	featureCPurchased = [userDefaults boolForKey:featureCId]; 
	featureDPurchased = [userDefaults boolForKey:featureDId]; 	
	featureEPurchased = [userDefaults boolForKey:featureEId]; 
	featureFPurchased = [userDefaults boolForKey:featureFId]; 	
	featureGPurchased = [userDefaults boolForKey:featureGId]; 	
	featureHPurchased = [userDefaults boolForKey:featureHId]; 	
	featureIPurchased = [userDefaults boolForKey:featureIId]; 	
}


+(void) updatePurchases
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:featureAPurchased forKey:featureAId];
	[userDefaults setBool:featureBPurchased forKey:featureBId];
	[userDefaults setBool:featureCPurchased forKey:featureCId];
	[userDefaults setBool:featureDPurchased forKey:featureDId];
	[userDefaults setBool:featureEPurchased forKey:featureEId];
	[userDefaults setBool:featureFPurchased forKey:featureFId];
	[userDefaults setBool:featureGPurchased forKey:featureGId];
	[userDefaults setBool:featureHPurchased forKey:featureHId];
	[userDefaults setBool:featureIPurchased forKey:featureIId];
}
@end
