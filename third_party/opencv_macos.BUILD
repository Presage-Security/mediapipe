# Description:
#   OpenCV libraries for video/image processing on MacOS

licenses(["notice"])  # BSD license

exports_files(["LICENSE"])

load("@bazel_skylib//lib:paths.bzl", "paths")

# The path to OpenCV is a combination of the path set for "macos_opencv"
# in the WORKSPACE file and the prefix here.
PREFIX = ""

cc_library(
    name = "opencv",
    # have to include the *.408.dylib link and *.4.8.0.dylib file paths, possibly because someone decided that
    # you "don't always want to follow the links like that", i.e. see
    # discussion here: https://groups.google.com/g/bazel-discuss/c/B2ZZIr1AeZM
    srcs = glob(
        [
            paths.join(PREFIX, "lib/libopencv_core.dylib"),
            paths.join(PREFIX, "lib/libopencv_core.408.dylib"),
            paths.join(PREFIX, "lib/libopencv_core.4.8.0.dylib"),
            paths.join(PREFIX, "lib/libopencv_calib3d.dylib"),
            paths.join(PREFIX, "lib/libopencv_calib3d.408.dylib"),
            paths.join(PREFIX, "lib/libopencv_calib3d.4.8.0.dylib"),
            paths.join(PREFIX, "lib/libopencv_features2d.dylib"),
            paths.join(PREFIX, "lib/libopencv_features2d.408.dylib"),
            paths.join(PREFIX, "lib/libopencv_features2d.4.8.0.dylib"),
            paths.join(PREFIX, "lib/libopencv_highgui.dylib"),
            paths.join(PREFIX, "lib/libopencv_highgui.408.dylib"),
            paths.join(PREFIX, "lib/libopencv_highgui.4.8.0.dylib"),
            paths.join(PREFIX, "lib/libopencv_imgcodecs.dylib"),
            paths.join(PREFIX, "lib/libopencv_imgcodecs.408.dylib"),
            paths.join(PREFIX, "lib/libopencv_imgcodecs.4.8.0.dylib"),
            paths.join(PREFIX, "lib/libopencv_imgproc.dylib"),
            paths.join(PREFIX, "lib/libopencv_imgproc.408.dylib"),
            paths.join(PREFIX, "lib/libopencv_imgproc.4.8.0.dylib"),
            paths.join(PREFIX, "lib/libopencv_video.dylib"),
            paths.join(PREFIX, "lib/libopencv_video.408.dylib"),
            paths.join(PREFIX, "lib/libopencv_video.4.8.0.dylib"),
            paths.join(PREFIX, "lib/libopencv_videoio.dylib"),
            paths.join(PREFIX, "lib/libopencv_videoio.408.dylib"),
            paths.join(PREFIX, "lib/libopencv_videoio.4.8.0.dylib"),
        ],
    ),
    hdrs = glob([paths.join(PREFIX, "include/opencv4/opencv2/**/*.h*")]),
    includes = [paths.join(PREFIX, "include/opencv4/")],
    linkstatic = 1,
    visibility = ["//visibility:public"],
    linkopts = [
        "-Wl,-rpath,/usr/local/lib",
    ],
)
