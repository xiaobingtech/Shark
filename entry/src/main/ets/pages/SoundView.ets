import { common } from '@kit.AbilityKit'
import { media } from '@kit.MediaKit'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { CardItem } from '../common/CardItem'
import { promptAction } from '@kit.ArkUI'

const DOMAIN: number = 0x0000
const SOUND_FILES: Array<string> = [
  'alarm',
  'anticipate',
  'bell',
  'birdsong',
  'bloom',
  'calypso',
  'chime',
  'choo',
  'descent',
  'electronic',
  'fanfare',
  'glass',
  'gotosleep',
  'healthnotification',
  'horn',
  'ladder',
  'mailsent',
  'minuet',
  'multiwayinvitation',
  'newmail',
  'newsflash',
  'noir',
  'paymentsuccess',
  'shake',
  'sherwoodforest',
  'silence',
  'spell',
  'suspense',
  'telegraph',
  'tiptoes',
  'typewriters',
  'update'
]

@Builder
export function SoundViewBuilder(name: string, param: Object) {
  SoundView()
}

@Component
export struct SoundView {
  @StorageLink('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  private avPlayer?: media.AVPlayer
  private playerState: string = 'idle'
  private pendingDescriptor?: media.AVFileDescriptor
  private pendingPrepare: boolean = false

  private async ensurePlayer(): Promise<void> {
    if (this.avPlayer !== undefined) {
      return
    }
    try {
      this.avPlayer = await media.createAVPlayer()
      this.avPlayer.on('stateChange', (state: string) => {
        this.playerState = state
        if (state === 'idle' && this.pendingDescriptor !== undefined) {
          let descriptor = this.pendingDescriptor
          this.pendingDescriptor = undefined
          this.applyDescriptor(descriptor)
        }
        if (state === 'initialized' && this.pendingPrepare) {
          this.pendingPrepare = false
          this.prepareAndPlay()
        }
      })
    } catch (err) {
      hilog.error(DOMAIN, 'SoundView', 'Failed to create AVPlayer: %{public}s', JSON.stringify(err))
    }
  }

  private applyDescriptor(descriptor: media.AVFileDescriptor): void {
    if (this.avPlayer === undefined) {
      return
    }
    let player: media.AVPlayer = this.avPlayer
    player.fdSrc = descriptor
    if (this.playerState === 'initialized') {
      this.prepareAndPlay()
    } else {
      this.pendingPrepare = true
    }
  }

  private prepareAndPlay(): void {
    if (this.avPlayer === undefined) {
      return
    }
    let player: media.AVPlayer = this.avPlayer
    player.prepare((prepareErr: BusinessError) => {
      if (prepareErr) {
        hilog.error(DOMAIN, 'SoundView', 'Failed to prepare: %{public}d %{public}s', prepareErr.code, prepareErr.message)
        return
      }
      player.play().catch((playErr: BusinessError) => {
        hilog.error(DOMAIN, 'SoundView', 'Failed to play: %{public}d %{public}s', playErr.code, playErr.message)
      })
    })
  }

  private async playSound(name: string): Promise<void> {
    await this.ensurePlayer()
    if (this.avPlayer === undefined) {
      return
    }
    let player: media.AVPlayer = this.avPlayer
    let context = getContext(this) as common.UIAbilityContext
    let fileDescriptor = await context.resourceManager.getRawFd(`${name}.mp3`)
    let avFileDescriptor: media.AVFileDescriptor = {
      fd: fileDescriptor.fd,
      offset: fileDescriptor.offset,
      length: fileDescriptor.length
    }
    if (this.playerState === 'idle') {
      this.applyDescriptor(avFileDescriptor)
      return
    }
    this.pendingDescriptor = avFileDescriptor
    this.pendingPrepare = true
    player.reset((resetErr: BusinessError) => {
      if (resetErr) {
        hilog.error(DOMAIN, 'SoundView', 'Failed to reset: %{public}d %{public}s', resetErr.code, resetErr.message)
        this.pendingDescriptor = undefined
        this.pendingPrepare = false
      }
    })
  }

  aboutToDisappear(): void {
    if (this.avPlayer === undefined) {
      return
    }
    let player = this.avPlayer
    player.release((err: BusinessError) => {
      if (err) {
        hilog.error(DOMAIN, 'SoundView', 'Failed to release: %{public}d %{public}s', err.code, err.message)
      }
    })
    this.avPlayer = undefined
  }

  build() {
    NavDestination() {
      List() {
        ListItemGroup() {
          ForEach(SOUND_FILES, (sound: string) => {
            ListItem({ style: ListItemStyle.CARD }) {
              CardItem({
                isShow: false,
                textContent: sound,
                symbolSrc: $r('sys.symbol.music'),
                onclick: () => {
                  this.playSound(sound)
                  let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, sound)
                  let systemPasteboard = pasteboard.getSystemPasteboard()
                  systemPasteboard.setData(data).catch((err: BusinessError) => {
                    hilog.error(DOMAIN, 'ServerView', 'Failed to copy url: %{public}d %{public}s', err.code, err.message)
                  })
                  promptAction.showToast({
                    message: "复制成功"
                  })
                }
              })
            }
            .height(undefined)
            .width('100%')
          }, (sound: string) => sound)
        }
        .divider({
          strokeWidth: 1,
          color: $r('sys.color.comp_divider'),
          startMargin: $r('sys.float.padding_level24'),
          endMargin: $r('sys.float.padding_level6')
        })
        .margin({ top: $r('sys.float.padding_level6') })
        .padding($r('sys.float.padding_level2'))
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius($r('sys.float.corner_radius_level8'))
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .width('100%')
      .height('100%')
      .padding({
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8')
      })
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .title('铃声列表')
    .onBackPressed(() => {
      this.navPathStack.pop()
      return true
    })
  }
}
