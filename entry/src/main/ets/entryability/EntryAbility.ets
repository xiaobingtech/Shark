import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { efRcp } from '@yunkss/ef_rcp';

const DOMAIN = 0x0000;
const PREFERENCES_NAME: string = 'shark.db';
const DEVICE_TOKEN_KEY: string = 'deviceToken';
const DEVICE_TOKEN_READY_KEY: string = 'hasDeviceToken';
const DEVICE_KEY: string = 'deviceKey';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
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
    let data = preferences.getPreferencesSync(this.context, { name: PREFERENCES_NAME })
    let savedToken = data.getSync(DEVICE_TOKEN_KEY, '') as string
    let savedReady = data.getSync(DEVICE_TOKEN_READY_KEY, false) as boolean
    let savedDeviceKey = data.getSync(DEVICE_KEY, '') as string
    AppStorage.setOrCreate(DEVICE_TOKEN_KEY, savedToken)
    AppStorage.setOrCreate(DEVICE_TOKEN_READY_KEY, savedReady)
    AppStorage.setOrCreate(DEVICE_KEY, savedDeviceKey)

    windowStage.loadContent('pages/TabPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
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
