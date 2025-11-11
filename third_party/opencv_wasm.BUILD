# Description:
#   OpenCV libraries for video/image processing on Linux

licenses(["notice"])  # BSD license

exports_files(["LICENSE"])

OPENCVWASM_BUILD_PATH = ""

OPENCVWASM_INSTALL_PATH = ""

cc_library(
    name = "opencv",
    srcs = glob([OPENCVWASM_BUILD_PATH + "lib/*.a"]),
    hdrs = glob([
        OPENCVWASM_INSTALL_PATH + "include/opencv4/opencv2/**/*.h*",
    ]),
    includes = [
        OPENCVWASM_INSTALL_PATH + "include/opencv4/",
    ],
    visibility = ["//visibility:public"],
)
