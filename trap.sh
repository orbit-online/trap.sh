#!/usr/bin/env bash

trap_init() {
  [[ -n $BASHPID ]] || { printf "trap.sh: \$BASHPID is not set" >&2; return 1; }
  if [[ $TRAP_CMDS_OWNER != "$BASHPID" ]]; then
    TRAP_CMDS_OWNER=$BASHPID
    TRAP_PREPEND_CMDS=()
    TRAP_APPEND_CMDS=()
  fi
}

trap_run() {
  local signal=$1 trap_cmd indices
  # shellcheck disable=SC2206
  indices=( ${!TRAP_PREPEND_CMDS[@]} )
  for ((i=${#indices[@]} - 1; i >= 0; i--)) ; do
    trap_cmd=${TRAP_PREPEND_CMDS[indices[i]]}
    [[ $trap_cmd = $signal* ]] || continue
    eval "${trap_cmd#"$signal "}" || true
  done
  for trap_cmd in "${TRAP_APPEND_CMDS[@]}"; do
    [[ $trap_cmd = $signal* ]] || continue
    eval "${trap_cmd#"$signal "}" || true
  done
}

trap_prepend() {
  trap_init
  local cmd=$1 signal=$2 trap_cmd
  # shellcheck disable=SC2034
  TRAP_POINTER=p${#TRAP_PREPEND_CMDS[@]}
  TRAP_PREPEND_CMDS+=("$signal $cmd")
  # shellcheck disable=SC2064
  trap "trap_run $signal" "$signal"
}

trap_append() {
  trap_init
  local cmd=$1 signal=$2 trap_cmd
  # shellcheck disable=SC2034
  TRAP_POINTER=a${#TRAP_APPEND_CMDS[@]}
  TRAP_APPEND_CMDS+=("$signal $cmd")
  # shellcheck disable=SC2064
  trap "trap_run $signal" "$signal"
}

trap_remove() {
  trap_init
  # shellcheck disable=SC2034
  local pointer=$1
  if [[ $pointer = a* ]]; then
    pointer=${pointer#a}
    unset "TRAP_APPEND_CMDS[pointer]"
  else
    pointer=${pointer#p}
    unset "TRAP_PREPEND_CMDS[pointer]"
  fi
}
