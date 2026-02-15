import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { distributedDataObject, preferences } from '@kit.ArkData';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { efRcp } from '@yunkss/ef_rcp';

const DOMAIN = 0x0000;
const PREFERENCES_NAME: string = 'shark.db';
const DEVICE_TOKEN_KEY: string = 'deviceToken';
const DEVICE_TOKEN_READY_KEY: string = 'hasDeviceToken';
const DEVICE_KEY: string = 'deviceKey';
const HISTORY_DATA_KEY: string = 'historyDataObject';
const HISTORY_DATA_VALUE_KEY: string = 'historyStoreData';
const HISTORY_TAB_INDEX_KEY: string = 'tabIndex';

class HistoryStoreData {
  titles: Array<string> = [];
  bodies: Array<string> = [];
  times: Array<number> = [];
}

interface WantMessageParameters {
  title?: string;
  body?: string;
  time?: number;
}

export default class EntryAbility extends UIAbility {
  private historyDataObject: distributedDataObject.DataObject | null = null;
  private historyStoreData: HistoryStoreData | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    this.handleWant(want)
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onNewWant');
    this.handleWant(want)
  }

  handleWant(want: Want): void {
    hilog.debug(DOMAIN, 'testTag', `want.parameters:${want.parameters}`)
    this.appendHistoryMessage(want)
    AppStorage.setOrCreate(HISTORY_TAB_INDEX_KEY, 1)
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    efRcp.setBaseURL('http://192.168.6.7:8080')
      .disableLoading()
      .enableLogInterceptor()
      .create()

    AppStorage.setOrCreate('navPathStack', new NavPathStack())
    AppStorage.setOrCreate('tabBarHidden', false)
    AppStorage.setOrCreate(HISTORY_TAB_INDEX_KEY, 0)
    let data = preferences.getPreferencesSync(this.context, { name: PREFERENCES_NAME })
    let savedToken = data.getSync(DEVICE_TOKEN_KEY, '') as string
    let savedReady = data.getSync(DEVICE_TOKEN_READY_KEY, false) as boolean
    let savedDeviceKey = data.getSync(DEVICE_KEY, '') as string
    AppStorage.setOrCreate(DEVICE_TOKEN_KEY, savedToken)
    AppStorage.setOrCreate(DEVICE_TOKEN_READY_KEY, savedReady)
    AppStorage.setOrCreate(DEVICE_KEY, savedDeviceKey)
    this.ensureHistoryDataObject()

    windowStage.loadContent('pages/TabPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  private ensureHistoryDataObject(): distributedDataObject.DataObject {
    if (this.historyDataObject != null) {
      return this.historyDataObject
    }
    let existingDataObject: distributedDataObject.DataObject | undefined =
      AppStorage.get<distributedDataObject.DataObject>(HISTORY_DATA_KEY)
    let existingData: HistoryStoreData | undefined =
      AppStorage.get<HistoryStoreData>(HISTORY_DATA_VALUE_KEY)
    if (existingDataObject != undefined && existingData != undefined) {
      this.historyDataObject = existingDataObject
      this.historyStoreData = existingData
      return this.historyDataObject
    }
    let data: HistoryStoreData = new HistoryStoreData()
    let dataObject: distributedDataObject.DataObject = distributedDataObject.create(this.context, data)
    this.historyDataObject = dataObject
    this.historyStoreData = data
    AppStorage.setOrCreate(HISTORY_DATA_KEY, dataObject)
    AppStorage.setOrCreate(HISTORY_DATA_VALUE_KEY, data)
    return dataObject
  }

  private appendHistoryMessage(want: Want): void {
    let parameters = want.parameters as WantMessageParameters
    let title: string = ''
    let body: string = ''
    let timestamp: number = Date.now()
    if (parameters != undefined && parameters != null) {
      if (parameters.title != undefined && parameters.title.length > 0) {
        title = parameters.title
      }
      if (parameters.body != undefined && parameters.body.length > 0) {
        body = parameters.body
      }
      if (parameters.time != undefined && parameters.time > 0) {
        timestamp = parameters.time
      }
    }
    if (title.length == 0) {
      title = '推送标题'
    }
    if (body.length == 0) {
      body = '推送内容'
    }
    this.ensureHistoryDataObject()
    if (this.historyStoreData == null || this.historyDataObject == null) {
      return
    }
    let data = this.historyStoreData
    data.titles.push(title)
    data.bodies.push(body)
    data.times.push(timestamp)
    this.historyDataObject.save('local', (err: BusinessError, result: distributedDataObject.SaveSuccessResponse) => {
      if (err != undefined && err.code != 0) {
        hilog.error(DOMAIN, 'HistoryStore', 'Failed to save history: %{public}s', JSON.stringify(err))
      }
    })
  }


  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
