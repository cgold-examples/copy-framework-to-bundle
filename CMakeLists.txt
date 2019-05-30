# TARGET_BUNDLE_DIR:
# - https://cmake.org/cmake/help/v3.9/release/3.9.html#other
cmake_minimum_required(VERSION 3.9)

project(foo)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/module")

include(copy_framework_to_bundle)

add_library(boo boo.cpp)

set_target_properties(
    boo
    PROPERTIES
    MACOSX_FRAMEWORK_IDENTIFIER com.example.boo
)

add_library(baz baz.cpp)

set_target_properties(
    baz
    PROPERTIES
    MACOSX_FRAMEWORK_IDENTIFIER com.example.baz
)

add_executable(foo foo.cpp)
target_link_libraries(foo PRIVATE boo baz)

copy_framework_to_bundle(
    BUNDLE foo
    FRAMEWORK boo baz
)
