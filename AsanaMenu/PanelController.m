#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "AsanaAPI.h"

#import "Task.h"
#import "Workspace.h"
#import "Project.h"
#import "AccountPreferencesViewController.h"
#import "MASPreferencesWindowController.h"


#define OPEN_DURATION .15
#define CLOSE_DURATION .1

#define SEARCH_INSET 17

#define POPUP_HEIGHT 122
#define PANEL_WIDTH 500
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize searchField = _searchField;
@synthesize textField = _textField;

#pragma mark -

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
        self.tasks = [NSArray array];
        self.workspaces = [NSArray array];
        self.projects = [NSArray array];
        self.projectsDict = [NSMutableDictionary dictionary];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.searchField];
}

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    self.tableScrollView.layer.borderColor = [[NSColor lightGrayColor] CGColor];
    self.tableScrollView.layer.borderWidth = 1;
    self.tableScrollView.layer.cornerRadius = 0.5;
    
//    [self.addTaskField setTarget:self];
//    [self.addTaskField setAction:@selector(addTask:)];
    [self.addTaskField setDelegate:self];
    
    // Resize panel
//    NSRect panelRect = [[self window] frame];
//    panelRect.size.height = POPUP_HEIGHT;
//    [[self window] setFrame:panelRect display:NO];
    
    // Follow search string
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runSearch) name:NSControlTextDidChangeNotification object:self.searchField];    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs synchronize];
    NSString *apiKey = [prefs stringForKey:@"apiKey"];

    if(!apiKey){
        [self.textField setStringValue:@"Please set up your API key in Preferences, then click to reload."];
    }else
        [AsanaAPI getAllWorkspacesWithDelegate:self];
}


- (void)jsonRequest:(JSONRequest *)request willStartRequestWithIdentifier:(NSString *)requestIdentifier
{

    [self.addTaskField setEnabled:NO];
    [self.popUpButton setEnabled:NO];
    [self.tableView setEnabled:NO];
    [self.searchField setEnabled:NO];
    if([requestIdentifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodAllWorkspaces]])
        [self.textField setStringValue:@"Loading workspaces..."];
    
    else if([requestIdentifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodWorkspaceProjects]])
        [self.textField setStringValue:@"Loading projects..."];
    
    else if([requestIdentifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodWorkspaceTasks]])
        [self.textField setStringValue:@"Loading tasks..."];
}

-(void)jsonRequest:(JSONRequest *)request processResponse:(id)jsonResponse identifier:(NSString *)identifier urlResponse:(NSHTTPURLResponse *)urlResponse urlRequest:(NSURLRequest *)urlRequest
{

        
    
    if([identifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodAllWorkspaces]])
    {
        self.workspaces = [Workspace workspacesFromJSON:jsonResponse];
    }
    else if([identifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodWorkspaceProjects]])
    {
        self.projects = [Project projectsFromJSON:jsonResponse];
        self. projects = [self.projects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 name] localizedCaseInsensitiveCompare:[obj2 name]];
        }];
        [self.projects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.projectsDict setObject:[obj name] forKey:[obj id]];
        }];
    }
    else if([identifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodWorkspaceTasks]])
    {
        
        self.tasks = [Task tasksFromJSON:jsonResponse];
        [self.tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Task *task = obj;
            [task setProjects:[self.projectsDict objectForKey:task.projectId]];
        }];
    }
    else if([identifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodCreateTask]])
    {
        
        [self.textField setStringValue:@"Task added."];
        [AsanaAPI getAllTasksOfWorkspace:[self.workspaces objectAtIndex:0] delegate:self];
    }
    else if([identifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodMarkTaskComplete]])
    {
        Task *task = [Task taskFromJSON:jsonResponse];
        __block NSInteger selected = -1;
        NSMutableArray *tasks = [NSMutableArray arrayWithArray:self.tasks];
        [self.tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([[obj id] isEqualToString:task.id] )
                selected = idx;
        }];
        [tasks removeObjectAtIndex:selected];
        [self setTasks:tasks];
        [self.tableView reloadData];
    }
    

}

- (void)jsonRequest:(JSONRequest *)request didFinishedRequestWithIdentifier:(NSString *)requestIdentifier
{
    if(request.error){
        NSString *error = [NSString stringWithFormat:@"Please check your API Key. %@", request.error];
        [self.textField setStringValue:error];
        return ;
    }
    
    if([requestIdentifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodAllWorkspaces]])
    {
        [AsanaAPI getAllProjectsOfWorkspace:[self.workspaces objectAtIndex:0] delegate:self];
        
    }
    
    if([requestIdentifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodWorkspaceProjects]])
    {
        [AsanaAPI getAllTasksOfWorkspace:[self.workspaces objectAtIndex:0] delegate:self];
    }
    
    if([requestIdentifier isEqualToString:[AsanaAPI identifierForAsanaAPI:AsanaAPIMethodWorkspaceTasks]])
    {
        
        [self.tableView reloadData];
        [self.textField setStringValue:@"Tasks"];


    }
    [self.addTaskField setEnabled:YES];
    [self.popUpButton setEnabled:YES];
    [self.tableView setEnabled:YES];
    [self.searchField setEnabled:YES];
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.tasks count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [self.tasks objectAtIndex:row];
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
    
    NSRect searchRect = [self.searchField frame];
    searchRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
    searchRect.origin.x = SEARCH_INSET;
    searchRect.origin.y = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET - NSHeight(searchRect);
    
    if (NSIsEmptyRect(searchRect))
    {
        [self.searchField setHidden:YES];
    }
    else
    {
        [self.searchField setFrame:searchRect];
        [self.searchField setHidden:NO];
    }
    
    NSRect textRect = [self.textField frame];
    textRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
    textRect.origin.x = SEARCH_INSET;
    textRect.size.height = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET * 3 - NSHeight(searchRect);
    textRect.origin.y = SEARCH_INSET;
    
    if (NSIsEmptyRect(textRect))
    {
        [self.textField setHidden:YES];
    }
    else
    {
        [self.textField setFrame:textRect];
        [self.textField setHidden:NO];
    }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

- (void)runSearch
{
    NSString *searchFormat = @"";
    self.searchString = [self.searchField stringValue];
    if ([self.searchString length] > 0)
    {
        searchFormat = NSLocalizedString(@"Search for ‘%@’…", @"Format for search request");
        NSString *searchRequest = [NSString stringWithFormat:searchFormat, self.searchString];
        [self.textField setStringValue:searchRequest];
    }
    else
        [self.textField setStringValue:@"Tasks"];
    
    [self.tableView reloadData];
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];

    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
    
    [panel performSelector:@selector(makeFirstResponder:) withObject:self.searchField afterDelay:openDuration];
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}

- (NSArray *) tasks
{
    if([self.searchString length]>0){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR projects CONTAINS[cd] %@",
                                  self.searchString, self.searchString];
    
        NSArray *filteredArray = [_tasks filteredArrayUsingPredicate:predicate];
        return filteredArray;
    }
    return _tasks;
}

-(void)controlTextDidEndEditing:(NSNotification *)notification
{
    // See if it was due to a return
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        if([self.addTaskField.stringValue length] > 0) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert addButtonWithTitle:@"Cancel"];
            NSString *question = [NSString stringWithFormat:@"Add the task to %@?", [[self.projects objectAtIndex: [self.popUpButton indexOfSelectedItem]] name] ];
            [alert setMessageText:question];
            [alert setInformativeText:self.addTaskField.stringValue];
            [alert setAlertStyle:NSInformationalAlertStyle];
            NSInteger result = [alert runModal];
            [self handleResult:alert withResult:result];
            
        }
    }
}

-(void)handleResult:(NSAlert *)alert withResult:(NSInteger)result
{
	// report which button was clicked
	switch(result)
	{
		case  NSAlertFirstButtonReturn:
            [self.textField setStringValue:@"Adding Task..."];
            [AsanaAPI addNewTask:self.addTaskField.stringValue project:[[self.projects objectAtIndex:[self.popUpButton indexOfSelectedItem]] id] workspace:[[self.workspaces objectAtIndex:0] id] delegate:self];
            
            [self.addTaskField setStringValue:@""];
			break;
            
		case NSAlertSecondButtonReturn:
			break;
            
        default:
            break;
	}
	
}
- (void)markTaskAsComplete:(NSString *)taskId
{
    [AsanaAPI markCompletionOfTask:taskId delegate:self];
}

- (IBAction)refresh:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs synchronize];
    NSString *apiKey = [prefs stringForKey:@"apiKey"];
    if(!apiKey){
        [self.textField setStringValue:@"Please set up your API key in Preferences, then click to reload."];
    }else
        [AsanaAPI getAllWorkspacesWithDelegate:self];
}


- (IBAction)displayPreferences:(id)sender {
    if(_preferencesWindow == nil){
        
        NSViewController *generalViewController = [[AccountPreferencesViewController alloc] initWithNibName:@"AccountPreferences" bundle:[NSBundle mainBundle]];
        
        NSArray *views = [NSArray arrayWithObjects:generalViewController, nil];
        NSString *title = NSLocalizedString(@"Preferences", @"Asana Menu Preferences");
        _preferencesWindow = [[MASPreferencesWindowController alloc] initWithViewControllers:views title:title];
    }
    [self.preferencesWindow showWindow:self];
}

- (IBAction)exitApp:(NSButton*)sender {
    // custom termination code
    [NSApp terminate:self];
}


@end
