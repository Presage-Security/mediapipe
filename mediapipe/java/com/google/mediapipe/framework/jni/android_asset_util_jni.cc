// Copyright 2019 The MediaPipe Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "mediapipe/java/com/google/mediapipe/framework/jni/android_asset_util_jni.h"

#include <memory>

#include "mediapipe/framework/port/logging.h"
#include "mediapipe/framework/port/singleton.h"
#include "mediapipe/java/com/google/mediapipe/framework/jni/jni_util.h"
#include "mediapipe/util/android/asset_manager_util.h"

//__DEBUG
#include <unistd.h>
#include "absl/log/absl_log.h"

JNIEXPORT jboolean JNICALL ANDROID_ASSET_UTIL_METHOD(
    nativeInitializeAssetManager)(JNIEnv* env, jclass clz,
                                  jobject android_context,
                                  jstring cache_dir_path) {
  //__DEBUG
  auto cache_str = mediapipe::android::JStringToStdString(env, cache_dir_path);
  ABSL_LOG(WARNING) << "__DEBUG [JNI-AssetInit] nativeInitializeAssetManager BEGIN"
                    << "  cache_dir=\"" << cache_str << "\""
                    << "  tid=" << gettid();

  mediapipe::AssetManager* asset_manager =
      Singleton<mediapipe::AssetManager>::get();
  auto result = asset_manager->InitializeFromActivity(
      env, android_context, cache_str);

  //__DEBUG
  ABSL_LOG(WARNING) << "__DEBUG [JNI-AssetInit] nativeInitializeAssetManager END  result=" << (result ? "OK" : "FAILED")
                    << "  tid=" << gettid();
  return result;
}
