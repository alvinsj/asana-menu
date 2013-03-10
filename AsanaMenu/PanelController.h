#import "BackgroundView.h"
#import "StatusItemView.h"
#import "AsanaAPI.h"
#import "ClickableTextView.h"

@class PanelController;

@protocol PanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller;

@end

#pragma mark -

@interface PanelController : NSWindowController <NSWindowDelegate, NSTableViewDataSource, JSONRequestDelegate, NSTextFieldDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PanelControllerDelegate> _delegate;
    __unsafe_unretained NSSearchField *_searchField;
    __unsafe_unretained ClickableTextView *_textField;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (nonatomic, unsafe_unretained) IBOutlet NSSearchField *searchField;
@property (nonatomic, unsafe_unretained) IBOutlet ClickableTextView *textField;

@property (nonatomic, unsafe_unretained) IBOutlet NSPopUpButton  *popUpButton;
@property (nonatomic, unsafe_unretained) IBOutlet NSTableView *tableView;
@property (nonatomic, unsafe_unretained) IBOutlet NSScrollView *tableScrollView;
@property (weak) IBOutlet NSTextField *addTaskField;

@property (nonatomic, unsafe_unretained) IBOutlet NSProgressIndicator *activityIndicatorView;

@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, strong) NSArray *workspaces;
@property (nonatomic, strong) NSArray *projects;
@property (nonatomic, strong) NSMutableDictionary *projectsDict;
@property (nonatomic, strong) NSString *searchString;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PanelControllerDelegate> delegate;

@property (strong) NSWindowController *preferencesWindow;


- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate;
- (void)openPanel;
- (void)closePanel;
- (void)markTaskAsComplete:(NSString *)taskId;
- (IBAction)refresh:(id)sender;
- (IBAction)displayPreferences:(id)sender;

- (IBAction)exitApp:(NSButton*)sender;

@end
