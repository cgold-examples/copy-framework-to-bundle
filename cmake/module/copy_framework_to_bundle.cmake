include(CMakeParseArguments) # cmake_parse_arguments

function(copy_framework_to_bundle)
  set(optional "")
  set(one BUNDLE)
  set(multiple FRAMEWORK)

  # Introduce:
  # * x_BUNDLE
  # * x_FRAMEWORK
  cmake_parse_arguments(x "${optional}" "${one}" "${multiple}" "${ARGV}")

  if(NOT "${x_UNPARSED_ARGUMENTS}" STREQUAL "")
    message(FATAL_ERROR "Unparsed arguments: ${x_UNPARSED_ARGUMENTS}")
  endif()

  # Check all arguments are targets {

  if(NOT TARGET "${x_BUNDLE}")
    message(FATAL_ERROR "Not a target: ${x_BUNDLE}")
  endif()

  foreach(x ${x_FRAMEWORK})
    if(NOT TARGET ${x})
      message(FATAL_ERROR "Not a target: ${x}")
    endif()
  endforeach()

  # }

  if(NOT APPLE)
    return()
  endif()

  get_target_property(bundle "${x_BUNDLE}" MACOSX_BUNDLE)

  if(NOT bundle)
    message("Target ${x_BUNDLE} is not a bundle, ignored.")
    return()
  endif()

  if(IOS)
    set_target_properties(
        ${x_BUNDLE}
        PROPERTIES
        XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/Frameworks"
    )
  else()
    # Layout:
    #
    #   foo.app/Contents/MacOS/foo
    #   foo.app/Frameworks

    set_target_properties(
        ${x_BUNDLE}
        PROPERTIES
        XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/../../Frameworks"
    )
  endif()

  foreach(x ${x_FRAMEWORK})
    get_target_property(framework "${x}" FRAMEWORK)
    if(NOT framework)
      message("Target ${x} is not a framework, ignored.")
      continue()
    endif()

    get_target_property(type "${x}" TYPE)
    if(NOT "${type}" STREQUAL "SHARED_LIBRARY")
      message("Target ${x} is not a shared library, ignored.")
      continue()
    endif()

    set_target_properties(
        ${x}
        PROPERTIES
        BUILD_WITH_INSTALL_NAME_DIR YES
        INSTALL_NAME_DIR "@rpath//"
    )

    message("Adding custom command for copying framework ${x} to bundle ${x_BUNDLE}")
    add_custom_command(
        TARGET
            ${x_BUNDLE}
        PRE_BUILD
        COMMAND
            ${CMAKE_COMMAND}
            -E
            remove_directory
            $<TARGET_BUNDLE_DIR:${x_BUNDLE}>/Frameworks/${x}.framework
        COMMAND
            ${CMAKE_COMMAND}
            -E
            copy_directory
            $<TARGET_BUNDLE_DIR:${x}>
            $<TARGET_BUNDLE_DIR:${x_BUNDLE}>/Frameworks/${x}.framework
    )
  endforeach()
endfunction()
