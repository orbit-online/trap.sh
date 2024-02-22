#!/usr/bin/env bash

TRAP_CMDS=()

_trap_run() {
  local signal=$1 trap_cmd
  for trap_cmd in "${TRAP_CMDS[@]}"; do
    [[ $trap_cmd = $signal* ]] || continue
    eval "${trap_cmd#"$signal "}" || true
  done
}

trap_append() {
  local cmd=$1 signal=$2 trap_cmd
  # shellcheck disable=SC2034
  TRAP_POINTER=${#TRAP_CMDS[@]}
  TRAP_CMDS+=("$signal $cmd")
  # shellcheck disable=SC2064
  trap "_trap_run $signal" "$signal"
}

trap_remove() {
  # shellcheck disable=SC2034
  local pointer=$1
  unset "TRAP_CMDS[pointer]"
}
