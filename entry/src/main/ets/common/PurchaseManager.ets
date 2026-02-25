import { iap } from '@kit.IAPKit'
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';
import { JWSUtil } from './JWSUtil';
import { FinishStatus, PurchaseData, PurchaseOrderPayload, SubStatus, SubGroupStatusPayload } from './IapDataModel';
import IAPLogger from './IAPLogger';

const PURCHASE_PREFERENCE_NAME = 'purchase_status';
const PURCHASE_STATUS_KEY = 'is_premium';
const PURCHASED_PRODUCT_ID_KEY = 'purchased_product_id';

export class PurchaseManager {
  private static instance: PurchaseManager;
  private context: common.UIAbilityContext | null = null;
  private isPremium: boolean = false;
  private purchasedProductId: string = '';

  private constructor() {}

  static getInstance(): PurchaseManager {
    if (!PurchaseManager.instance) {
      PurchaseManager.instance = new PurchaseManager();
    }
    return PurchaseManager.instance;
  }

  initialize(context: common.UIAbilityContext): void {
    this.context = context;
    this.loadPurchaseStatus();
  }

  private loadPurchaseStatus(): void {
    if (!this.context) return;

    try {
      const purchaseData = preferences.getPreferencesSync(this.context, { name: PURCHASE_PREFERENCE_NAME });
      this.isPremium = purchaseData.getSync(PURCHASE_STATUS_KEY, false) as boolean;
      this.purchasedProductId = purchaseData.getSync(PURCHASED_PRODUCT_ID_KEY, '') as string;
      IAPLogger.info('PurchaseManager', `Load purchase status: ${this.isPremium}, productId: ${this.purchasedProductId}`);
    } catch (err) {
      IAPLogger.error('PurchaseManager', `Failed to load purchase status: ${err}`);
      this.isPremium = false;
      this.purchasedProductId = '';
    }
  }

  savePurchaseStatus(isPremium: boolean, productId?: string): void {
    if (!this.context) return;

    try {
      const purchaseData = preferences.getPreferencesSync(this.context, { name: PURCHASE_PREFERENCE_NAME });
      purchaseData.putSync(PURCHASE_STATUS_KEY, isPremium);
      if (productId) {
        purchaseData.putSync(PURCHASED_PRODUCT_ID_KEY, productId);
        this.purchasedProductId = productId;
      }
      purchaseData.flush();
      this.isPremium = isPremium;
      IAPLogger.info('PurchaseManager', `Save purchase status: ${isPremium}, productId: ${productId}`);
    } catch (err) {
      IAPLogger.error('PurchaseManager', `Failed to save purchase status: ${err}`);
    }
  }

  getPurchaseStatus(): boolean {
    return this.isPremium;
  }

  getPurchasedProductId(): string {
    return this.purchasedProductId;
  }

  async queryAllPurchases(): Promise<void> {
    if (!this.context) {
      IAPLogger.error('PurchaseManager', 'Context not initialized');
      return;
    }

    try {
      await this.queryPurchasesByType(iap.ProductType.AUTORENEWABLE);
      await this.queryPurchasesByType(iap.ProductType.NONCONSUMABLE);
      IAPLogger.info('PurchaseManager', 'Query all purchases completed');
    } catch (err) {
      IAPLogger.error('PurchaseManager', `Failed to query purchases: ${err}`);
    }
  }

  private async queryPurchasesByType(productType: iap.ProductType): Promise<void> {
    if (!this.context) return;

    const param: iap.QueryPurchasesParameter = {
      productType: productType,
      queryType: iap.PurchaseQueryType.CURRENT_ENTITLEMENT
    };

    try {
      const res: iap.QueryPurchaseResult = await iap.queryPurchases(this.context, param);
      const purchaseDataList: string[] = res.purchaseDataList;

      if (purchaseDataList && purchaseDataList.length > 0) {
        for (let i = 0; i < purchaseDataList.length; i++) {
          await this.dealPurchaseData(purchaseDataList[i], productType);
        }
      } else {
        IAPLogger.info('PurchaseManager', `No purchases found for type: ${productType}`);
      }
    } catch (err) {
      const e = err as BusinessError;
      IAPLogger.error('PurchaseManager', `Failed to query purchases for type ${productType}. Code: ${e.code}, message: ${e.message}`);
    }
  }

  async dealPurchaseData(purchaseData: string, productType: iap.ProductType): Promise<void> {
    try {
      const data = JSON.parse(purchaseData) as PurchaseData;
      let isValid = false;
      let productId = '';

      if (productType === iap.ProductType.AUTORENEWABLE) {
        const jwsSubscriptionStatus = data.jwsSubscriptionStatus;
        if (jwsSubscriptionStatus) {
          const subscriptionStatus = JWSUtil.decodeJwsObj(jwsSubscriptionStatus);
          const subGroupStatusPayload = JSON.parse(subscriptionStatus) as SubGroupStatusPayload;
          const lastSubscriptionStatus = subGroupStatusPayload.lastSubscriptionStatus;

          if (lastSubscriptionStatus?.status === SubStatus.ACTIVE) {
            isValid = true;
            productId = lastSubscriptionStatus.renewalInfo?.productId || '';
            IAPLogger.info('PurchaseManager', `Active subscription found: ${productId}`);
          }

          if (lastSubscriptionStatus?.lastPurchaseOrder) {
            await this.finishPurchase(lastSubscriptionStatus.lastPurchaseOrder);
          }
        }
      } else {
        const jwsPurchaseOrder = data.jwsPurchaseOrder;
        if (jwsPurchaseOrder) {
          const purchaseOrderStr = JWSUtil.decodeJwsObj(jwsPurchaseOrder);
          const purchaseOrderPayload = JSON.parse(purchaseOrderStr) as PurchaseOrderPayload;

          if (purchaseOrderPayload) {
            isValid = true;
            productId = purchaseOrderPayload.productId;
            IAPLogger.info('PurchaseManager', `Non-consumable purchase found: ${productId}`);

            if (purchaseOrderPayload.finishStatus !== FinishStatus.FINISHED) {
              await this.finishPurchase(purchaseOrderPayload);
            }
          }
        }
      }

      if (isValid) {
        this.savePurchaseStatus(true, productId);
      }
    } catch (e) {
      IAPLogger.error('PurchaseManager', `dealPurchaseData parse error: ${e}`);
    }
  }

  private async finishPurchase(purchaseOrder: PurchaseOrderPayload): Promise<void> {
    if (!this.context) return;

    const finishPurchaseParam: iap.FinishPurchaseParameter = {
      productType: Number(purchaseOrder.productType),
      purchaseToken: purchaseOrder.purchaseToken,
      purchaseOrderId: purchaseOrder.purchaseOrderId
    };

    try {
      await iap.finishPurchase(this.context, finishPurchaseParam);
      IAPLogger.info('PurchaseManager', 'Succeeded in finishing purchase.');
    } catch (err) {
      const e = err as BusinessError;
      IAPLogger.error('PurchaseManager', `Failed to finish purchase. Code: ${e.code}, message: ${e.message}`);
    }
  }
}

export default PurchaseManager.getInstance();
