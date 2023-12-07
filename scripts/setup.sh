#!/bin/bash
#
# Perform devops environment setup.

# -x: print a trace (debug)
# -u: treat unset variables
# -o pipefail: return value of a pipeline
set -uo pipefail

# Constant variables

readonly -a APT_PACKAGES=(
  ansible
  ansible-lint
  python3-pip
)

# Internal functions

########################
# Update apt package dependencies.
# Arguments:
#   None
# Returns:
#   None
#########################
pkg_apt_update() {
  apt update -qqq
}

########################
# Install apt package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
pkg_apt_install() {
  local package="${1:?package is missing}"

  local -i retval=0

  if ! command -v "${package}" &>/dev/null; then
    apt install -y -qqq "${package}"
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Install apt package list dependencies.
# Arguments:
#   $@ - list of packages
# Returns:
#   Boolean
#########################
pkg_apt_install_list() {
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    pkg_apt_update

    pkg_apt_install "${package}"
    ((result = $?))
    ((retval |= "${result}"))

    log_message "setup" "${package}" "${result}"
  done

  return "${retval}"
}

# Control flow logic

setup() {
  local -i retval=0

  pkg_apt_install_list "${APT_PACKAGES[@]}"
  ((retval |= $?))

  return "${retval}"
}

setup
exit "${?}"
