/*
 * Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

import { image } from '@kit.ImageKit'
import { UIContext } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { CircleShape } from '@ohos.arkui.shape';
import { Animator as animator, AnimatorResult } from '@kit.ArkUI';
import display from '@ohos.display';

interface ContextMenuProps {
  pixmap?: image.PixelMap
  pixmapLast?: image.PixelMap
  cyRatio?: number
  cxRatio?: number
  duration?: number
  type?: string
  isAnimating?: boolean
}

@Component
export struct RNThemeSwitchAnimation {
  uiContexts: UIContext | undefined = undefined;
  public static readonly NAME = "RNThemeSwitchAnimation"
  @State realViewPoint: Object = [];
  @State pixmap: image.PixelMap = {} as PixelMap;
  @State pixmapLast: image.PixelMap = {} as PixelMap;
  @State cyRatio: number = 0;
  @State cxRatio: number = 0;
  @State duration: number = 0;
  @State type: string = '';
  @State isAnimating: boolean = false;
  @State opacitySize: number = 1
  @State myScale: number = 1;
  @State officeSize: number = 1;
  @State widthSize: string = ''
  @State heightSize: string = ''
  @State x: number = 0;
  @State y: number = 0;
  @State z: number = 0;
  private backAnimator: AnimatorResult | undefined = undefined

  aboutToAppear(): void {
    this.backAnimator = undefined;
    let longPress: ESObject = this.realViewPoint;
    this.pixmap = longPress.pixmap;
    this.pixmapLast = longPress.pixmapLast;
    this.cyRatio = longPress.cyRatio;
    this.cxRatio = longPress.cxRatio;
    this.duration = longPress.duration;
    this.type = longPress.type;
    this.isAnimating =  longPress.isAnimating;
    this.x = display.getDefaultDisplaySync().width
    this.y = display.getDefaultDisplaySync().height
    this.z = Math.floor(Math.sqrt((this.x * this.x) + (this.y * this.y))/2)

    console.log('type', this.type)
  }

  emit() {
    let eventData: emitter.EventData = {
      data: {}
    };
    let innerEvent: emitter.InnerEvent = {
      eventId: 1,
      priority: emitter.EventPriority.HIGH
    };
    emitter.emit(innerEvent, eventData);
  }

  emitInverted() {
    let eventData: emitter.EventData = {
      data: {}
    };
    let innerEvent: emitter.InnerEvent = {
      eventId: 2,
      priority: emitter.EventPriority.HIGH
    };
    emitter.emit(innerEvent, eventData);
  }

  fadeAnimate() {
    if (this.isAnimating) {
      animateToImmediately({
        delay: 0,
        duration: this.duration
      }, () => {
        this.opacitySize = 0
      })
      setTimeout(() => {
        this.emit()
      }, this.duration)
    }
  }

  invertedCircularAnimate() {
    let _this = this
    this.backAnimator = animator.create({
      duration: this.duration,
      easing: "linear",
      delay: 0,
      fill: "forwards",
      direction: "normal",
      iterations: 1,
      begin: this.z,
      end: 0
    })
    this.backAnimator.onFrame = (value:number)=> {
      _this.myScale = value
      _this.officeSize = -1 * (value / 2)
    }
  }

  circularAnimate() {
    let _this = this
    this.backAnimator = animator.create({
      duration: this.duration,
      easing: "linear",
      delay: 0,
      fill: "forwards",
      direction: "normal",
      iterations: 1,
      begin: 0,
      end: this.z + 200
    })
    this.backAnimator.onFrame = (value:number)=> {
      _this.myScale = value
      _this.officeSize = -1 * (value / 2)
    }
  }

  build() {
    Column(){
      if(this.type == 'fade') {
        Row(){
          Image(this.pixmap).onComplete(info => {
            this.fadeAnimate()
          }).opacity(this.opacitySize)
        }
      } else if(this.type == 'inverted-circular') {
        Row() {
          Image(this.pixmap).onComplete(info => {
            let wid = info?.width as number
            let hei = info?.height as number
            this.widthSize = wid * this.cxRatio + 'px'
            this.heightSize = hei * this.cyRatio + 'px'
            this.invertedCircularAnimate()
            if (this.backAnimator) {
              this.backAnimator.play()
            }
            setTimeout(() => {
              this.emit()
            }, this.duration)
          })
        }.clipShape(
          new CircleShape()
            .width(this.myScale)
            .height(this.myScale)
            .position({x: this.widthSize, y: this.heightSize})
            .offset({ x: this.officeSize, y: this.officeSize})
        )
      } else if(this.type == 'circular') {
        Stack() {
          Row() {
            Image(this.pixmap)
          }
          Row() {
            Image(this.pixmapLast).onComplete(info => {
              let wid = info?.width as number
              let hei = info?.height as number
              this.widthSize = wid * this.cxRatio + 'px'
              this.heightSize = hei * this.cyRatio + 'px'
              this.circularAnimate()
              if (this.backAnimator) {
                this.backAnimator.play()
              }
              setTimeout(() => {
                this.emitInverted()
              }, this.duration)
            })
          }.clipShape(
            new CircleShape()
              .width(this.myScale)
              .height(this.myScale)
              .position({x: this.widthSize, y: this.heightSize})
              .offset({ x: this.officeSize, y: this.officeSize})
          )
        }
      }
    }
  }
}
