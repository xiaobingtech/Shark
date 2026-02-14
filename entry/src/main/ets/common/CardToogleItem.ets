@Component
export struct CardToogleItem {
  @Prop isShow: boolean;
  textContent?: Resource | string;
  symbolSrc?: Resource;
  @Prop isOn: boolean = false;
  onChange: (value: boolean) => void = (value: boolean) => {};
  onclick: Function = () => {};
  onClose: Function = () => {};

  build() {
    Row() {
      if (this.symbolSrc) {
        SymbolGlyph(this.symbolSrc)
          .fontSize($r('sys.float.Title_M'))
          .fontColor([$r('sys.color.icon_secondary')])
      }
      Text(this.textContent)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: $r('sys.float.padding_level8') })
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: this.isOn })
        .onChange((value: boolean) => {
          this.onChange(value);
        })
    }
    .width('100%')
    .height(56)
    .onClick(() => {
      this.onclick();
    })
  }
}
