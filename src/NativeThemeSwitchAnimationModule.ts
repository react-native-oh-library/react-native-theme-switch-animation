/*
 * Copyright (c) 2024 Huawei Device Co., Ltd. All rights reserved
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import type { Int32 } from 'react-native/Libraries/Types/CodegenTypes';

export interface Spec extends TurboModule {
  freezeScreen(): void;
  unfreezeScreen(
    type: string,
    duration: Int32,
    cxRatio: Int32,
    cyRatio: Int32
  ): void;

  addListener: (eventName: string) => void;
  removeListeners: (count: number) => void;
  getLastContent(): void;
}

export default TurboModuleRegistry.get<Spec>('ThemeSwitchAnimationNativeModule') as Spec | null;