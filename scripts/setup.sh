#!/usr/bin/env bash
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
  snapd
)

readonly -a SNAP_PACKAGES=(
  task
)

readonly -a PIP_PACKAGES=(
  ansible-creator
)

# Internal functions

########################
# Check for root privileges.
# Arguments:
#   None
# Returns:
#   None
#########################
has_root_privileges() {
  if [[ $EUID -ne 0 ]]; then
      # Check if root process is running
      if pgrep -u $UID root; then
          echo "This script must be run as root"
          exit 1
      fi
  fi
}

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
    apt install -qqq -y --no-install-recommends "${package}"
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Install snap package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
pkg_snap_install() {
  local package="${1:?package is missing}"

  local -i retval=0

  if ! command -v "${package}" &>/dev/null; then
    snap install "${package}" --classic
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Install pip package dependency.
# Arguments:
#   $1 - package
# Returns:
#   Boolean
#########################
pkg_pip_install() {
  local package="${1:?package is missing}"

  local -i retval=0

  if ! pip3 show "${package}" &>/dev/null; then
    pip3 install "${package}"
    ((retval = $?))
  fi

  return "${retval}"
}

########################
# Generic install package list dependencies.
# Arguments:
#   $1 - package installation function
#   $@ - list of packages
# Returns:
#   Boolean
#########################
pkg_install_list() {
  local install_func="${1:?install function is missing}"
  shift
  local -a packages=("$@")

  local -i retval=0
  local -i result=0

  for package in "${packages[@]}"; do
    "$install_func" "${package}"
    ((result = $?))
    ((retval |= "${result}"))
  done

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

  pkg_apt_update
  pkg_install_list pkg_apt_install "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

########################
# Install snap package list dependencies.
# Arguments:
#   $@ - list of packages
# Returns:
#   Boolean
#########################
pkg_snap_install_list() {
  local -a packages=("$@")
  local -i retval=0

  pkg_install_list pkg_snap_install "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

########################
# Install pip package list dependencies.
# Arguments:
#   $@ - list of packages
# Returns:
#   Boolean
#########################
pkg_pip_install_list() {
  local -a packages=("$@")
  local -i retval=0

  pkg_install_list pkg_pip_install "${packages[@]}"
  ((retval |= $?))

  return "${retval}"
}

# Control flow logic

setup() {
  local -i retval=0

  has_root_privileges

  pkg_apt_install_list "${APT_PACKAGES[@]}"
  ((retval |= $?))

  pkg_snap_install_list "${SNAP_PACKAGES[@]}"
  ((retval |= $?))

  pkg_pip_install_list "${PIP_PACKAGES[@]}"
  ((retval |= $?))

  return "${retval}"
}

setup
exit "${?}"
