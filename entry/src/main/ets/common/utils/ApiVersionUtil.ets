import { deviceInfo } from '@kit.BasicServicesKit'

export function isSdkApi23OrHigher(): boolean {
  return deviceInfo.sdkApiVersion >= 23
}

export function isApi23OrHigher(): boolean {
  return isSdkApi23OrHigher() && canIUse('SystemCapability.UIDesign.HDSComponent.Core')
}

export function getPhoneHdsTabsContentEndOffset(currentBreakpoint: string): number {
  return (deviceInfo.deviceType !== 'tv'
    && currentBreakpoint !== 'lg'
    && currentBreakpoint !== 'xl'
    && isApi23OrHigher()) ? 100 : 0
}
