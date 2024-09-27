import { TurboModule } from '@rnoh/react-native-openharmony/ts';
import { TM } from '@rnoh/react-native-openharmony/generated/ts';
import { window, ComponentContent, Content } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import  { image } from '@kit.ImageKit';
import { emitter } from '@kit.BasicServicesKit';
import { RNThemeSwitchAnimation } from './RNThemeSwitchAnimation';
import { RNOHContext, TurboModuleContext } from '@rnoh/react-native-openharmony';
import { OverlayManager } from '@kit.ArkUI';

@Builder
function buildContextThemeSwitchPress(realViewPoint: ESObject) {
  RNThemeSwitchAnimation({realViewPoint: realViewPoint})
}

export interface ContextMenuProps {
  pixmap?: image.PixelMap
  pixmapLast?: image.PixelMap
  cyRatio?: number
  cxRatio?: number
  duration?: number
  type?: string
  isAnimating?: boolean
}

export class RNThemeSwitchTurboModule extends TurboModule implements TM.ThemeSwitchAnimationNativeModule.Spec {
  windowClass: window.Window = {} as window.Window;
  realViewPoint: ContextMenuProps = {};
  isAnimating: boolean = false;
  contentNodeD: Content = {} as Content;
  overlayNodeD: OverlayManager = {} as OverlayManager;
  contentNodeD2: Content = {} as Content;
  overlayNodeD2: OverlayManager = {} as OverlayManager;

  constructor(ctx: TurboModuleContext) {
    super(ctx)
    let innerEvent: emitter.InnerEvent = { eventId: 1 };
    let innerEventCircular: emitter.InnerEvent = { eventId: 2 };
    emitter.on(innerEvent, () => { this.animationContent() });
    emitter.on(innerEventCircular, () => { this.animationContentCircular() });
  }

  freezeScreen(): void {
    if (!this.isAnimating) {
      this.isAnimating = true;
    }
  }

  unfreezeScreen(type: string, duration: number, cxRatio: number, cyRatio: number): void {
    if (this.isAnimating) {
      this.realViewPoint.type = type;
      this.realViewPoint.duration = duration;
      this.realViewPoint.cxRatio = cxRatio;
      this.realViewPoint.cyRatio = cyRatio;
      this.realViewPoint.isAnimating = this.isAnimating;
      this.showShotScreen()
    }
  }

  showShotScreen() {
    window.getLastWindow(this.ctx.uiAbilityContext, (err: BusinessError, win) => {
      win.snapshot((err: BusinessError, pixelMap: image.PixelMap) => {
        this.realViewPoint.pixmap = pixelMap;
        const uiContext = win.getUIContext();
        const overlayNode = uiContext.getOverlayManager()
        const contentNode = new ComponentContent(uiContext!, wrapBuilder(buildContextThemeSwitchPress), this.realViewPoint);
        this.overlayNodeD = overlayNode
        this.contentNodeD = contentNode
        overlayNode.addComponentContent(contentNode)
        overlayNode.showComponentContent(contentNode)
      })
    });
  }

  getLastContent(): void {
    this.overlayNodeD.removeComponentContent(this.contentNodeD)
    setTimeout(() => {
      window.getLastWindow(this.ctx.uiAbilityContext, (err: BusinessError, win) => {
        win.snapshot((err: BusinessError, pixelMap: image.PixelMap) => {
          this.realViewPoint.pixmapLast = pixelMap;
          const uiContext = win.getUIContext();
          const overlayNode = uiContext.getOverlayManager()
          const contentNode = new ComponentContent(uiContext!, wrapBuilder(buildContextThemeSwitchPress), this.realViewPoint);
          this.overlayNodeD2 = overlayNode
          this.contentNodeD2 = contentNode
          overlayNode.addComponentContent(contentNode)
        })
      })
    },20)
  }

  animationContent() {
    this.overlayNodeD.hideComponentContent(this.contentNodeD)
    this.isAnimating = false;
  }

  animationContentCircular() {
    this.overlayNodeD2.hideComponentContent(this.contentNodeD2)
    this.isAnimating = false;
  }

  addListener(eventName: string): void {}

  removeListeners(count: number): void {}
}

