load("@build_bazel_rules_apple//apple:ios.bzl", "ios_framework")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load(
    "//mediapipe/examples/ios:bundle_id.bzl",
    "BUNDLE_ID_PREFIX",
    "example_provisioning",
)
licenses(["notice"])  # Apache 2.0

MIN_IOS_VERSION = "11.1"

IOS_FAMILIES = [
    "iphone",
    "ipad",
]

FRAMEWORK_HEADERS = [
	"MPIrisTracker.h", 
	"MyCameraInputSource.h"
]

ios_framework(
    name = "MPIrisTracker",
	hdrs= FRAMEWORK_HEADERS,
    infoplists = [
		"//mediapipe/examples/ios/common:Info.plist",
		"Info.plist"],
	bundle_name = "MPIrisTracker",
	bundle_id = BUNDLE_ID_PREFIX,
    families = IOS_FAMILIES,
    minimum_os_version = MIN_IOS_VERSION,
    deps = [
        ":IrisTrackerLibrary",
        "@ios_opencv//:OpencvFramework",
    ],
)

objc_library(
    name = "IrisTrackerLibrary",
	srcs= glob(["*.mm"]),
	hdrs = FRAMEWORK_HEADERS,
    copts = ["-std=c++17"],
    data = [
        "//mediapipe/graphs/iris_tracking:iris_tracking_gpu.binarypb",
        "//mediapipe/modules/face_detection:face_detection_short_range.tflite",
        "//mediapipe/modules/face_landmark:face_landmark.tflite",
        "//mediapipe/modules/iris_landmark:iris_landmark.tflite",
    ],
    deps = [
        "//mediapipe/objc:mediapipe_framework_ios",
        "//mediapipe/objc:mediapipe_input_sources_ios",
        "//mediapipe/objc:mediapipe_layer_renderer",
    ] + select({
        "//mediapipe:ios_i386": [],
        "//mediapipe:ios_x86_64": [],
        "//conditions:default": [
            "//mediapipe/graphs/iris_tracking:iris_tracking_gpu_deps",
            "//mediapipe/framework/formats:landmark_cc_proto",
        ],
    }),
)
