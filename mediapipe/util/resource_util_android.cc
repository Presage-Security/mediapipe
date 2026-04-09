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

#include <vector>

#include "absl/log/absl_log.h"
#include "absl/strings/match.h"
#include "mediapipe/framework/port/file_helpers.h"
#include "mediapipe/framework/port/ret_check.h"
#include "mediapipe/framework/port/singleton.h"
#include "mediapipe/framework/port/statusor.h"
#include "mediapipe/util/android/asset_manager_util.h"
#include "mediapipe/util/android/file/base/helpers.h"

//__DEBUG
#include <unistd.h>

namespace mediapipe {

namespace {
absl::StatusOr<std::string> PathToResourceAsFileInternal(
    const std::string& path) {
  //__DEBUG
  ABSL_LOG(WARNING) << "__DEBUG [ResUtil] CachedFileFromAsset BEGIN  path=\"" << path << "\"  tid=" << gettid();
  auto result = Singleton<AssetManager>::get()->CachedFileFromAsset(path);
  //__DEBUG
  if (result.ok()) {
    ABSL_LOG(WARNING) << "__DEBUG [ResUtil] CachedFileFromAsset OK     cached=\"" << *result << "\"  tid=" << gettid();
  } else {
    ABSL_LOG(ERROR) << "__DEBUG [ResUtil] CachedFileFromAsset FAILED  path=\"" << path
                    << "\"  status=" << result.status() << "  tid=" << gettid();
  }
  return result;
}
}  // namespace

namespace internal {
absl::Status DefaultGetResourceContents(const std::string& path,
                                        std::string* output,
                                        bool read_as_binary) {
  if (!read_as_binary) {
    ABSL_LOG(WARNING)
        << "Setting \"read_as_binary\" to false is a no-op on Android.";
  }
  if (absl::StartsWith(path, "/")) {
    //__DEBUG
    ABSL_LOG(WARNING) << "__DEBUG [ResUtil] GetResourceContents reading absolute path=\"" << path << "\"  tid=" << gettid();
    return file::GetContents(path, output, file::Defaults());
  }

  if (absl::StartsWith(path, "content://")) {
    MP_RETURN_IF_ERROR(
        Singleton<AssetManager>::get()->ReadContentUri(path, output));
    return absl::OkStatus();
  }

  // Try the test environment.
  absl::string_view workspace = "mediapipe";
  const char* test_srcdir = std::getenv("TEST_SRCDIR");
  auto test_path =
      file::JoinPath(test_srcdir ? test_srcdir : "", workspace, path);
  if (file::Exists(test_path).ok()) {
    return file::GetContents(path, output, file::Defaults());
  }

  //__DEBUG
  ABSL_LOG(WARNING) << "__DEBUG [ResUtil] GetResourceContents reading asset path=\"" << path << "\"  tid=" << gettid();
  RET_CHECK(Singleton<AssetManager>::get()->ReadFile(path, output))
      << "could not read asset: " << path;
  return absl::OkStatus();
}
}  // namespace internal

absl::StatusOr<std::string> PathToResourceAsFile(const std::string& path) {
  //__DEBUG
  ABSL_LOG(WARNING) << "__DEBUG [ResUtil] PathToResourceAsFile  path=\"" << path << "\"  tid=" << gettid();

  // Return full path.
  if (absl::StartsWith(path, "/")) {
    return path;
  }

  // Try to load a relative path or a base filename as is.
  {
    auto status_or_path = PathToResourceAsFileInternal(path);
    if (status_or_path.ok()) {
      ABSL_LOG(INFO) << "Successfully loaded: " << path;
      return status_or_path;
    }
    //__DEBUG
    ABSL_LOG(WARNING) << "__DEBUG [ResUtil] full-path attempt failed, trying basename  path=\"" << path << "\"";
  }

  // If that fails, assume it was a relative path, and try just the base name.
  {
    const size_t last_slash_idx = path.find_last_of("\\/");
    RET_CHECK(last_slash_idx != std::string::npos)
        << path << " doesn't have a slash in it";  // Make sure it's a path.
    auto base_name = path.substr(last_slash_idx + 1);
    auto status_or_path = PathToResourceAsFileInternal(base_name);
    if (status_or_path.ok()) {
      ABSL_LOG(INFO) << "Successfully loaded: " << base_name;
      return status_or_path;
    }
    //__DEBUG
    ABSL_LOG(ERROR) << "__DEBUG [ResUtil] basename attempt also failed  base=\"" << base_name << "\"";
  }

  // Try the test environment.
  absl::string_view workspace = "mediapipe";
  auto test_path = file::JoinPath(std::getenv("TEST_SRCDIR"), workspace, path);
  if (file::Exists(test_path).ok()) {
    return test_path;
  }

  return path;
}

}  // namespace mediapipe
