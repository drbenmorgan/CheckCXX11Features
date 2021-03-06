# - Check which parts of the C++11 standard the compiler supports
#
# When included in a project via include(), checks are run on the current
# C++ compiler to:
#
#  - Determine the flags needed to enable C++11 support
#  - Determine availability of C++11 features via Compile/Run/Fail tests
#
# If the project is being cross-compiled, only compile tests are performed.
# After the checks are performed, the following variables are set in the
# CMake cache:
#
#  CXX11_COMPILER_FLAGS         - the compiler flags needed to get C++11 features
#
#  HAS_CXX11_ALGORITHM_ALL_OF   - algorithm header provides all_of
#  HAS_CXX11_ALGORITHM_ANY_OF   - algorithm header provides any_of
#  HAS_CXX11_ALGORITHM_COPY_N   - algorithm header provides copy_n
#  HAS_CXX11_ALGORITHM_FIND_IF_NOT - algorithm header provides find_if_not
#  HAS_CXX11_ALGORITHM_IS_PARTITIONED - algorithm header provides is_partitioned
#  HAS_CXX11_ALGORITHM_IS_SORTED - algorithm header provides is_sorted
#  HAS_CXX11_ALGORITHM_MIN_MAX   - algorithm header provides minmax
#  HAS_CXX11_ALGORITHM_NONE_OF  - algorithm header provides none_of
#  HAS_CXX11_ALGORITHM_PARTITION_POINT - algorithm header provides partition_point
#  HAS_CXX11_ALGORITHM_SHUFFLE  - algorithm header provides shuffle
#  HAS_CXX11_ARRAY              - array header
#  HAS_CXX11_AUTO               - auto keyword
#  HAS_CXX11_AUTO_RET_TYPE      - function declaration with deduced return types
#  HAS_CXX11_CLASS_OVERRIDE     - override and final keywords for classes and methods
#  HAS_CXX11_CMATH_C99          - cmath header provides c99 functions in std
#  HAS_CXX11_CMATH_FPCLASSIFY   - cmath header provides classify/comparison
#  HAS_CXX11_CONSTEXPR          - constexpr keyword
#  HAS_CXX11_CSTDINT_H          - cstdint header
#  HAS_CXX11_CSTDDEF_NULLPTR_T  - cstddef header provides nullptr_t
#  HAS_CXX11_DECLTYPE           - decltype keyword
#  HAS_CXX11_DEFAULT_TEMPLATE_ARGUMENTS - default arguments for function templates
#  HAS_CXX11_EXPLICIT_CONVERSION_OPERATORS - conversion operators can be explicit
#  HAS_CXX11_FUNC               - __func__ preprocessor constant
#  HAS_CXX11_FUNCTIONAL_BIND    - functional header provides bind
#  HAS_CXX11_FUNCTIONAL_FUNCTION - functional header provides function
#  HAS_CXX11_FUNCTIONAL_HASH    - functional header provides hash
#  HAS_CXX11_FUNCTIONAL_MEM_FN  - functional header provides mem_fn
#  HAS_CXX11_FUNCTIONAL_REF     - functional header provides ref/cref
#  HAS_CXX11_INITIALIZER_LIST   - initializer list
#  HAS_CXX11_LAMBDA             - lambdas
#  HAS_CXX11_LIB_REGEX          - regex library
#  HAS_CXX11_LONG_LONG          - long long signed & unsigned types
#  HAS_CXX11_MAP_EMPLACE        - std::map has emplace methods
#  HAS_CXX11_MEMORY_SHARED_PTR  - memory header provides shared_ptr
#  HAS_CXX11_MEMORY_UNIQUE_PTR  - memory header provides unique_ptr
#  HAS_CXX11_NOEXCEPT           - noexcept specifier
#  HAS_CXX11_NULLPTR            - nullptr
#  HAS_CXX11_NUMERIC_IOTA       - numeric header provides iota
#  HAS_CXX11_RANDOM             - random header
#  HAS_CXX11_RANGE_BASED_FOR    - range-based for loops
#  HAS_CXX11_RVALUE_REFERENCES  - rvalue references
#  HAS_CXX11_SIZEOF_MEMBER      - sizeof() non-static members
#  HAS_CXX11_STATIC_ASSERT      - static_assert()
#  HAS_CXX11_STRING_NUMERIC_CONVERSIONS - string header provides numeric conversion functions
#  HAS_CXX11_SYSTEM_ERROR       - system_error header
#  HAS_CXX11_TUPLE              - tuple header
#  HAS_CXX11_TYPE_TRAITS        - type_traits header
#  HAS_CXX11_UTILITY_DECLVAL    - utility header provides declval
#  HAS_CXX11_VARIADIC_TEMPLATES - variadic templates
#  HAS_CXX11_VECTOR_EMPLACE     - std::vector has emplace member functions

#=============================================================================
# Copyright 2011,2012 Rolf Eike Beer <eike@sf-mail.de>
# Copyright 2012 Andreas Weis
# Copyright 2014 Ben Morgan <bmorgan.warwick@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file LICENSE.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

#
# Each feature may have up to 3 checks, every one of them in it's own file
# FEATURE.cpp              - example that must build and return 0 when run
# FEATURE_fail.cpp         - example that must build, but may not return 0 when run
# FEATURE_fail_compile.cpp - example that must fail compilation
#
# The first one is mandatory, the latter 2 are optional and do not depend on
# each other (i.e. only one may be present).
#

if(NOT CMAKE_CXX_COMPILER_LOADED)
  message(FATAL_ERROR "CheckCXX11Features modules only works if language CXX is enabled")
endif()

cmake_minimum_required(VERSION 2.8.3)

#
### Check for available/needed compiler flags
#
include(CheckCXXCompilerFlag)

# For the "-std" family, can have 'c++1z' (C++17), 'c++14' (C++14),
# 'c++1y' (C++14), 'c++11' (C++11), 'c++0x' (C++11)

check_cxx_compiler_flag("-std=c++11" _HAS_CXX11_FLAG)
if(NOT _HAS_CXX11_FLAG)
  check_cxx_compiler_flag("-std=c++0x" _HAS_CXX0X_FLAG)
endif()

# Activate standard library
check_cxx_compiler_flag("-stdlib=libc++" _HAS_CXXSTDLIB_FLAG)

if(_HAS_CXX11_FLAG)
  # Xcode attributes don't get exported to try_compile/run...
  # Though we should ideally set them...
  #set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")
  #set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
  # To get try_{compile,run} working correctly with the Xcode generator,
  # there is an issue with it not forwarding compiler flags to linker,
  # see the bug report here:
  #  http://cmake.org/Bug/view.php?id=10552
  # Means that for Xcode, not sufficient to add -stdlib argument to
  # compiler flags - must be added to CMAKE_EXE_LINKER_FLAGS linker flags as
  # well. That can be done via the CMAKE_FLAGS argument of try_{compile,run}
  # Alternately, CMAKE_FLAGS can be used to set the Xcode attributes above.
  # That might be better as it should only affect things when we
  # run the Xcode generator, whereas setting LINKER_FLAGS applies everywhere
  #
  set(CXX11_COMPILER_FLAGS "-std=c++11")
elseif(_HAS_CXX0X_FLAG)
  set(CXX11_COMPILER_FLAGS "-std=c++0x")
endif()

#-----------------------------------------------------------------------
# function cxx11_check_feature(<name> <result>)
#
function(cxx11_check_feature FEATURE_NAME RESULT_VAR)
  if(NOT DEFINED ${RESULT_VAR})
    set(_bindir "${CMAKE_CURRENT_BINARY_DIR}/CheckCXX11Features/cxx11_${FEATURE_NAME}")

    set(_SRCFILE_BASE ${CMAKE_CURRENT_LIST_DIR}/CheckCXX11Features/cxx11-test-${FEATURE_NAME})
    set(_LOG_NAME "\"${FEATURE_NAME}\"")
    message(STATUS "Checking C++11 support for ${_LOG_NAME}")

    set(_SRCFILE "${_SRCFILE_BASE}.cpp")
    set(_SRCFILE_FAIL "${_SRCFILE_BASE}_fail.cpp")
    set(_SRCFILE_FAIL_COMPILE "${_SRCFILE_BASE}_fail_compile.cpp")

    if(CMAKE_CROSSCOMPILING)
      try_compile(${RESULT_VAR} "${_bindir}" "${_SRCFILE}"
        COMPILE_DEFINITIONS "${CXX11_COMPILER_FLAGS}")
      if(${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL})
        try_compile(${RESULT_VAR} "${_bindir}_fail" "${_SRCFILE_FAIL}"
          COMPILE_DEFINITIONS "${CXX11_COMPILER_FLAGS}")
      endif()
    else()
      try_run(_RUN_RESULT_VAR _COMPILE_RESULT_VAR
        "${_bindir}" "${_SRCFILE}"
        #CMAKE_FLAGS "-DCMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY='libc++'"
        COMPILE_DEFINITIONS "${CXX11_COMPILER_FLAGS}")
      if(_COMPILE_RESULT_VAR AND NOT _RUN_RESULT_VAR)
        set(${RESULT_VAR} TRUE)
      else()
        set(${RESULT_VAR} FALSE)
      endif()

      if(${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL})
        try_run(_RUN_RESULT_VAR _COMPILE_RESULT_VAR
          "${_bindir}_fail" "${_SRCFILE_FAIL}"
          #CMAKE_FLAGS "-DCMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY='libc++'"
          COMPILE_DEFINITIONS "${CXX11_COMPILER_FLAGS}")
        if(_COMPILE_RESULT_VAR AND _RUN_RESULT_VAR)
          set(${RESULT_VAR} TRUE)
        else()
          set(${RESULT_VAR} FALSE)
        endif()
      endif()
    endif()

    if(${RESULT_VAR} AND EXISTS ${_SRCFILE_FAIL_COMPILE})
      try_compile(_TMP_RESULT "${_bindir}_fail_compile" "${_SRCFILE_FAIL_COMPILE}"
        #CMAKE_FLAGS "-DCMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY='libc++'"
        COMPILE_DEFINITIONS "${CXX11_COMPILER_FLAGS}")
      if(_TMP_RESULT)
        set(${RESULT_VAR} FALSE)
      else()
        set(${RESULT_VAR} TRUE)
      endif()
    endif()

    if(${RESULT_VAR})
      message(STATUS "Checking C++11 support for ${_LOG_NAME}: works")
    else()
      message(STATUS "Checking C++11 support for ${_LOG_NAME}: not supported")
    endif()

    set(${RESULT_VAR} ${${RESULT_VAR}} CACHE INTERNAL "C++11 support for ${_LOG_NAME}")
  endif()
endfunction()

#-----------------------------------------------------------------------
# Run all checks
#
cxx11_check_feature("__func__" HAS_CXX11_FUNC)
cxx11_check_feature("algorithm_all_of" HAS_CXX11_ALGORITHM_ALL_OF)
cxx11_check_feature("algorithm_any_of" HAS_CXX11_ALGORITHM_ANY_OF)
cxx11_check_feature("algorithm_copy_n" HAS_CXX11_ALGORITHM_COPY_N)
cxx11_check_feature("algorithm_find_if_not" HAS_CXX11_ALGORITHM_FIND_IF_NOT)
cxx11_check_feature("algorithm_is_partitioned" HAS_CXX11_ALGORITHM_IS_PARTITIONED)
cxx11_check_feature("algorithm_is_sorted" HAS_CXX11_ALGORITHM_IS_SORTED)
cxx11_check_feature("algorithm_minmax" HAS_CXX11_ALGORITHM_MIN_MAX)
cxx11_check_feature("algorithm_none_of" HAS_CXX11_ALGORITHM_NONE_OF)
cxx11_check_feature("algorithm_partition_point" HAS_CXX11_ALGORITHM_PARTITION_POINT)
cxx11_check_feature("algorithm_shuffle" HAS_CXX11_ALGORITHM_SHUFFLE)
cxx11_check_feature("array" HAS_CXX11_ARRAY)
cxx11_check_feature("auto" HAS_CXX11_AUTO)
cxx11_check_feature("auto_ret_type" HAS_CXX11_AUTO_RET_TYPE)
cxx11_check_feature("class_override_final" HAS_CXX11_CLASS_OVERRIDE)
cxx11_check_feature("cmath_c99" HAS_CXX11_CMATH_C99)
cxx11_check_feature("cmath_fpclassify" HAS_CXX11_CMATH_FPCLASSIFY)
cxx11_check_feature("constexpr" HAS_CXX11_CONSTEXPR)
cxx11_check_feature("cstdint" HAS_CXX11_CSTDINT_H)
cxx11_check_feature("cstddef_nullptr_t" HAS_CXX11_CSTDDEF_NULLPTR_T)
cxx11_check_feature("decltype" HAS_CXX11_DECLTYPE)
cxx11_check_feature("default_template_arguments" HAS_CXX11_DEFAULT_TEMPLATE_ARGUMENTS)
cxx11_check_feature("explicit_conversion_operators" HAS_CXX11_EXPLICIT_CONVERSION_OPERATORS)
cxx11_check_feature("functional_bind" HAS_CXX11_FUNCTIONAL_BIND)
cxx11_check_feature("functional_function" HAS_CXX11_FUNCTIONAL_FUNCTION)
cxx11_check_feature("functional_hash" HAS_CXX11_FUNCTIONAL_HASH)
cxx11_check_feature("functional_mem_fn" HAS_CXX11_FUNCTIONAL_MEM_FN)
cxx11_check_feature("functional_ref" HAS_CXX11_FUNCTIONAL_REF)
cxx11_check_feature("initializer_list" HAS_CXX11_INITIALIZER_LIST)
cxx11_check_feature("lambda" HAS_CXX11_LAMBDA)
cxx11_check_feature("lib_regex" HAS_CXX11_LIB_REGEX)
cxx11_check_feature("long_long" HAS_CXX11_LONG_LONG)
cxx11_check_feature("map_emplace" HAS_CXX11_MAP_EMPLACE)
cxx11_check_feature("memory_shared_ptr" HAS_CXX11_MEMORY_SHARED_PTR)
cxx11_check_feature("memory_unique_ptr" HAS_CXX11_MEMORY_UNIQUE_PTR)
cxx11_check_feature("noexcept" HAS_CXX11_NOEXCEPT)
cxx11_check_feature("nullptr" HAS_CXX11_NULLPTR)
cxx11_check_feature("numeric_iota" HAS_CXX11_NUMERIC_IOTA)
cxx11_check_feature("random" HAS_CXX11_RANDOM)
cxx11_check_feature("range_based_for" HAS_CXX11_RANGE_BASED_FOR)
cxx11_check_feature("rvalue-references" HAS_CXX11_RVALUE_REFERENCES)
cxx11_check_feature("sizeof_member" HAS_CXX11_SIZEOF_MEMBER)
cxx11_check_feature("static_assert" HAS_CXX11_STATIC_ASSERT)
cxx11_check_feature("string_numeric_conversions" HAS_CXX11_STRING_NUMERIC_CONVERSIONS)
cxx11_check_feature("system_error" HAS_CXX11_SYSTEM_ERROR)
cxx11_check_feature("tuple" HAS_CXX11_TUPLE)
cxx11_check_feature("type_traits" HAS_CXX11_TYPE_TRAITS)
cxx11_check_feature("utility_declval" HAS_CXX11_UTILITY_DECLVAL)
cxx11_check_feature("variadic_templates" HAS_CXX11_VARIADIC_TEMPLATES)
cxx11_check_feature("vector_emplace" HAS_CXX11_VECTOR_EMPLACE)
