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
  TRAP_POINTER=0
  for trap_cmd in "${TRAP_CMDS[@]}"; do
    [[ -n $trap_cmd ]] || break
    : $((TRAP_POINTER++))
  done
  TRAP_CMDS[TRAP_POINTER]="$signal $cmd"
  # shellcheck disable=SC2064
  [[ $(trap -p "$signal") = "trap -- '_trap_run $signal' $signal" ]] || trap "_trap_run $signal" "$signal"
}

trap_remove() {
  local pointer=$1
  TRAP_CMDS[pointer]=''
}
