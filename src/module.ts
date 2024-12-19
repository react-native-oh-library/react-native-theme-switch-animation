/*
 * Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-theme-switch-animation' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;

const IS_SUPPORTED_PLATFORM =
  Platform.OS === 'android' || Platform.OS === 'ios' || Platform.OS as string == 'harmony';;

const module = (() => {
  if (IS_SUPPORTED_PLATFORM) {
    if (isTurboModuleEnabled) {
      return require('./NativeThemeSwitchAnimationModule').default;
    }
    if (NativeModules.ThemeSwitchAnimationModule) {
      return NativeModules.ThemeSwitchAnimationModule;
    }
    throw new Error(LINKING_ERROR);
  }
  return undefined;
})();

export default module;
