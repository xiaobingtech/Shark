import { hilog } from '@kit.PerformanceAnalysisKit';

export default class IAPLogger {
  private static IAP_PREFIX: string = '[IAP]';
  private static IAP_LOG_DOMAIN = 0x0fff;
  private static TWO_PLACEHOLDER_FORMAT: string = '%{public}s    %{public}s';

  public static info(tag: string, log: string) {
    hilog.info(IAPLogger.IAP_LOG_DOMAIN, IAPLogger.IAP_PREFIX, IAPLogger.TWO_PLACEHOLDER_FORMAT, tag, log);
  }

  public static debug(tag: string, log: string) {
    hilog.debug(IAPLogger.IAP_LOG_DOMAIN, IAPLogger.IAP_PREFIX, IAPLogger.TWO_PLACEHOLDER_FORMAT, tag, log);
  }

  public static warn(tag: string, log: string) {
    hilog.warn(IAPLogger.IAP_LOG_DOMAIN, IAPLogger.IAP_PREFIX, IAPLogger.TWO_PLACEHOLDER_FORMAT, tag, log);
  }

  public static error(tag: string, log: string) {
    hilog.error(IAPLogger.IAP_LOG_DOMAIN, IAPLogger.IAP_PREFIX, IAPLogger.TWO_PLACEHOLDER_FORMAT, tag, log);
  }
}
