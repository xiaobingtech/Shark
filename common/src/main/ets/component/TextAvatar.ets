/**
 * TextAvatar 组件
 * 根据用户昵称生成文字头像,背景色随机选择
 */

@Component
export struct TextAvatar {
  @Prop nickname: string = ''
  @Prop iconsize: number = 48
  
  // 适中的背景色组 - 不过分浓
  private readonly bgColors: string[] = [
    '#FF7F9EF1', // 浅蓝
    '#FF66C2A4', // 浅绿
    '#FFB19CD9', // 浅紫
    '#FFFF9999', // 浅红
    '#FFFFB366', // 浅橙
    '#FF80CBC4', // 青色
    '#FFA5D6A7', // 绿色
    '#FFE6AA68', // 棕色
    '#FF90A4AE', // 蓝灰
    '#FFCE93D8', // 粉紫
    '#FFA1887F', // 棕灰
    '#FF81C784', // 草绿
  ]
  
  /**
   * 提取昵称首字符
   * 如果是中文取第一个汉字,否则取第一个字符
   */
  getFirstChar(): string {
    if (!this.nickname || this.nickname.length === 0) {
      return '?'
    }
    
    const firstChar = this.nickname.charAt(0)
    
    // 判断是否是中文字符 (基本汉字范围: \u4e00-\u9fa5)
    const chineseRegex = /[\u4e00-\u9fa5]/
    if (chineseRegex.test(firstChar)) {
      return firstChar
    }
    
    // 如果是英文,返回大写
    return firstChar.toUpperCase()
  }
  
  /**
   * 根据昵称生成随机但固定的背景色
   * 使用昵称的哈希值来确保同一昵称总是得到相同的颜色
   */
  getBackgroundColor(): string {
    if (!this.nickname || this.nickname.length === 0) {
      return this.bgColors[0]
    }
    
    // 简单哈希函数
    let hash = 0
    for (let i = 0; i < this.nickname.length; i++) {
      hash = this.nickname.charCodeAt(i) + ((hash << 5) - hash)
      hash = hash & hash // Convert to 32bit integer
    }
    
    // 确保索引为正数
    const index = Math.abs(hash) % this.bgColors.length
    return this.bgColors[index]
  }
  
  build() {
    Stack() {
      Text(this.getFirstChar())
        .fontSize(this.iconsize * 0.45) // 字体大小为头像的45%
        .fontColor('#FFFFFFFF')
        .fontWeight(FontWeight.Medium)
    }
    .width(this.iconsize)
    .height(this.iconsize)
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(this.iconsize / 6) // 圆角半径为宽度的1/6,与其他头像保持一致
  }
}
