/*
 * Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

import { Platform, Dimensions, NativeEventEmitter } from 'react-native';
import type {
  AnimationConfig,
  CircularAnimationConfig,
  CircularAnimationConfigExact,
  ThemeSwitcherHookProps,
} from './types';
import ThemeSwitchAnimationListener from './ThemeSwitchAnimationListener';
import {
  calculateActualRation,
  calculateRatio,
  validateCoordinates,
} from './helpers';
import module from './module';

const IS_SUPPORTED_PLATFORM =
  Platform.OS === 'android' || Platform.OS === 'ios' || Platform.OS as string == 'harmony';
let ThemeSwitchAnimation: any = null;
let switchFunction: () => void = () => {};
let eventEmitter = new NativeEventEmitter(module);
let localAnimationConfig: AnimationConfig = {
  type: 'fade',
  duration: 500,
};

if (IS_SUPPORTED_PLATFORM) {
  ThemeSwitchAnimation = module;

  const themeSwitchAnimationListener = new ThemeSwitchAnimationListener();

  themeSwitchAnimationListener.addEventListener(() => {
    if (localAnimationConfig) {
      unfreezeWrapper();
      if(switchFunction) {
        setTimeout(() => {
          switchFunction();
          if(localAnimationConfig.type == 'circular'){
            setTimeout(() => {
              ThemeSwitchAnimation.getLastContent()
            })
          }
        },30)
      }
    }
  });
}

const switchTheme = ({
  switchThemeFunction: incomingSwitchThemeFunction,
  animationConfig,
}: ThemeSwitcherHookProps) => {
  if (IS_SUPPORTED_PLATFORM) {
    localAnimationConfig = animationConfig || localAnimationConfig;
    ThemeSwitchAnimation.freezeScreen();
    switchFunction = incomingSwitchThemeFunction;
    eventEmitter.emit("FINISHED_FREEZING_SCREEN", null)
  } else {
    incomingSwitchThemeFunction();
  }
};

const unfreezeWrapper = () => {
  const defaultRatio = 0.5;
  setImmediate(() => {
    if (
      localAnimationConfig.type === 'circular' ||
      localAnimationConfig.type === 'inverted-circular'
    ) {
      if (
        'cx' in localAnimationConfig.startingPoint &&
        'cy' in localAnimationConfig.startingPoint
      ) {
        const { cx, cy } = (
          localAnimationConfig as CircularAnimationConfigExact
        )?.startingPoint;
        const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } =
          Dimensions.get('screen');
        if (
          validateCoordinates(cx, SCREEN_WIDTH, 'cx') &&
          validateCoordinates(cy, SCREEN_HEIGHT, 'cy')
        ) {
          const cxRatio = calculateRatio(cx, SCREEN_WIDTH);
          const cyRatio = calculateRatio(cy, SCREEN_HEIGHT);

          ThemeSwitchAnimation.unfreezeScreen(
            localAnimationConfig.type,
            localAnimationConfig.duration,
            cxRatio,
            cyRatio
          );
        } else {
          // cleanup
          ThemeSwitchAnimation.unfreezeScreen('fade', 200, 0.5, 0.5);
        }
      } else if (
        'cxRatio' in localAnimationConfig.startingPoint &&
        'cyRatio' in localAnimationConfig.startingPoint
      ) {
        const { cxRatio, cyRatio } = (
          localAnimationConfig as CircularAnimationConfig
        )?.startingPoint;

        if (
          validateCoordinates(cxRatio, 1, 'cxRatio') &&
          validateCoordinates(cyRatio, 1, 'cyRatio')
        ) {
          const cxRatioActual = calculateActualRation(cxRatio);
          const cyRatioActual = calculateActualRation(cyRatio);

          ThemeSwitchAnimation.unfreezeScreen(
            localAnimationConfig.type,
            localAnimationConfig.duration,
            cxRatioActual,
            cyRatioActual
          );
        } else {
          // cleanup
          ThemeSwitchAnimation.unfreezeScreen('fade', 500, 0.5, 0.5);
        }
      }
    } else {
      ThemeSwitchAnimation.unfreezeScreen(
        localAnimationConfig.type,
        localAnimationConfig.duration,
        defaultRatio,
        defaultRatio
      );
    }
  });
};

export default switchTheme;
