load("@build_bazel_rules_apple//apple:ios.bzl", "ios_framework")
load(
    "//mediapipe/examples/ios:bundle_id.bzl",
    "BUNDLE_ID_PREFIX",
    "example_provisioning",
)
licenses(["notice"])  # Apache 2.0

MIN_IOS_VERSION = "11.1"
FRAMEWORK_HEADERS = glob(["*.h"])
IOS_FAMILIES = [
    "iphone",
    "ipad",
]


ios_framework(
  name = "MPIrisTracker",
  hdrs = FRAMEWORK_HEADERS,
  infoplists = ["Info.plist"],
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

      #"//mediapipe/examples/ios/presage_v2/graphs:graph_HRRR_04_17_23.binarypb",# added from jims  proj
      #"//mediapipe/graphs/face_mesh/subgraphs:face_renderer_gpu",               # added from jims  proj
      #"//mediapipe/modules/face_landmark:face_landmark_front_gpu",              # added from jims  proj
      #"//mediapipe/modules/face_landmark:face_landmark_with_attention.tflite",  # definitely needed (required for face_landmark when attention=True)



 data = [
    "//mediapipe/examples/ios/presage_graph_mpiris/graph:iris_tracking_gpu.binarypb", # now we are using a custom graph

    # these all came from mpiris project
    # "//mediapipe/graphs/iris_tracking:iris_tracking_gpu.binarypb",  # original iris graph file
    "//mediapipe/modules/face_detection:face_detection_short_range.tflite",
    "//mediapipe/modules/face_landmark:face_landmark.tflite",
    "//mediapipe/modules/iris_landmark:iris_landmark.tflite",
    "//mediapipe/modules/pose_landmark:pose_landmark_gpu",
    "//mediapipe/modules/pose_detection:pose_detection.tflite",
    "//mediapipe/modules/pose_landmark:pose_landmark_lite.tflite", #"//mediapipe/modules/pose_landmark:pose_landmark_full.tflite",
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
          "//mediapipe/examples/ios/presage_graph_mpiris/graph:iris_tracking_gpu_deps",
          "//mediapipe/framework/formats:landmark_cc_proto",
      ],
  }),

)
