#!/usr/bin/env bash

###
### Bash setup
###

# http://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html

set -o errexit # AKA -e - exit immediately on errors (http://mywiki.wooledge.org/BashFAQ/105)
set -o errtrace # AKA -E - any trap on ERR is inherited by subshell
set -o noclobber # AKA -C - disallow '>' to overwrite file (see http://mywiki.wooledge.org/NoClobber)
set -o pipefail # fail when pipelines contain an error (see http://www.gnu.org/software/bash/manual/html_node/Pipelines.html)

bash_log_prefix="${JOB_NAME:-TRACKER}"
_log_prefix="[${bash_log_prefix}] ${BASH_SOURCE}:"

function handle_bash_xtrace() {
  bash_xtrace=${BASH_XTRACE:-false}
  if [[ ${bash_xtrace} == 'true' ]]; then
    export PS4="+(\${BASH_SOURCE}:\${LINENO}): \${FUNCNAME[0]:+\${FUNCNAME[0]}(): }"
    set -o xtrace
  fi
}

handle_bash_xtrace

bash_verbose=${BASH_VERBOSE:-false}
if [[ ${bash_verbose} == 'true' ]]; then
  set -o verbose
fi

fd=0
if [[ -t "${fd}" || -p /dev/stdin ]]; then
  # only do this on interactive shells
  set -o nounset # AKA -u - guard against unused variables (see http://mywiki.wooledge.org/BashFAQ/035)
fi

function onexit() {
  local exit_status=${1:-$?}
  if [[ ${exit_status} != 0 ]]; then
    _error_line="error trapped."
  else
    _error_line=''
  fi
  if [[ $(type -t onexit_hook) = 'function' ]]; then
    onexit_hook
  fi
  echo "${_log_prefix} ${_error_line} Exiting $0 with exit status ${exit_status}"
  exit "${exit_status}"
}

function disable_error_checking() {
  trap - ERR
  set +o errexit
}

function enable_error_checking() {
  trap onexit ERR
  set -o errexit
}

trap onexit HUP INT QUIT TERM ERR


