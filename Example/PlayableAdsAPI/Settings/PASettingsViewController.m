//
//  PASettingsViewController.m
//  PlayableAdsAPI_Example
//
//  Created by Michael Tang on 2019/3/25.
//  Copyright © 2019 wzy2010416033@163.com. All rights reserved.
//

#import "PASettingsViewController.h"
#import "PASettingNormalCell.h"
#import "PASettingItem.h"
#import "PASettingsManager.h"

static NSString *cellID = @"PASettingNormalCellID";

@interface PASettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray<PASettingItem *>  *settingLists;

@end

@implementation PASettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    [self handleSettingData];
}

- (void)setupTableView{
    
    UINib *nib = [UINib nibWithNibName:@"PASettingNormalCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellID];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tableHeaderView = [[UIView alloc] init];
    self.title = self.customTitle;
}

- (void)handleSettingData{
    [self.settingLists removeAllObjects];
    
    PASettingsManager *manager = [PASettingsManager sharedManager];
    
    if (self.settingType == kSettingType_Overall) {
        PASettingItem *item1 = [[PASettingItem alloc] init];
        item1.title = @"Use UI Web View";
        item1.isOn = manager.isUIWebView_Overall;
        item1.valueIdentify = SettingValueIdentify_UIWebView_Overall;
        PASettingItem *item2 = [[PASettingItem alloc] init];
        item2.title = @"Test Model";
        item2.isOn = manager.isTestModel_Overall;
        item2.valueIdentify = SettingValueIdentify_TestModel_Overall;
        
        [self.settingLists addObject:item1];
        [self.settingLists addObject:item2];
        return;
    }
    if (self.settingType == kSettingType_Function01) {
        PASettingItem *item1 = [[PASettingItem alloc] init];
        item1.title = @"Support Mraid";
        item1.isOn = manager.isSupportMraid_01;
        item1.valueIdentify = SettingValueIdentify_SupportMraid_01;
        PASettingItem *item2 = [[PASettingItem alloc] init];
        item2.title = @"Support \"A\" Tag";
        item2.isOn = manager.isSupportATag_01;
        item2.valueIdentify = SettingValueIdentify_SupportATag_01;
        
        PASettingItem *item3 = [[PASettingItem alloc] init];
        item3.title = @"PreRender";
        item3.isOn = manager.isPreRender_01;
        item3.valueIdentify = SettingValueIdentify_PreRender_01;
        
        PASettingItem *item4 = [[PASettingItem alloc] init];
        item4.title = @"LoadHTMLorURL";
        item4.isOn = manager.isLoadHTMLorURL_01;
        item4.valueIdentify = SettingValueIdentify_LoadHTMLorURL_01;
        
        [self.settingLists addObject:item1];
        [self.settingLists addObject:item2];
        [self.settingLists addObject:item3];
        [self.settingLists addObject:item4];
        return;
    }
    if (self.settingType == kSettingType_Function02) {
        PASettingItem *item1 = [[PASettingItem alloc] init];
        item1.title = @"PreRender";
        item1.isOn = manager.isPreRender_02;
        item1.valueIdentify = SettingValueIdentify_PreRender_02;
        
        PASettingItem *item2 = [[PASettingItem alloc] init];
        item2.title = @"LoadHTMLorURL";
        item2.isOn = manager.isLoadHTMLorURL_02;
        item2.valueIdentify = SettingValueIdentify_LoadHTMLorURL_02;
        
        PASettingItem *item3 = [[PASettingItem alloc] init];
        item3.title = @"Support Mraid";
        item3.isOn = manager.isSupportMraid_02;
        item3.valueIdentify = SettingValueIdentify_SupportMraid_02;
        
        [self.settingLists addObject:item1];
        [self.settingLists addObject:item2];
        [self.settingLists addObject:item3];
        return;
    }
}

#pragma mark:UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.settingLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PASettingNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[PASettingNormalCell alloc] init];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    PASettingItem *item = self.settingLists[indexPath.row];
    
    [cell setSettingItem:item];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (NSMutableArray<PASettingItem *> *)settingLists{
    if (!_settingLists) {
        _settingLists = [NSMutableArray arrayWithCapacity:1];
    }
    return _settingLists;
}

@end
