#!/usr/bin/env bash

trap_init() {
  [[ -n $BASHPID ]] || { printf "trap.sh: \$BASHPID is not set" >&2; return 1; }
  if [[ $TRAP_CMDS_OWNER != "$BASHPID" || ${#TRAP_CMDS[@]} -eq 0 ]]; then
    TRAP_CMDS_OWNER=$BASHPID
    TRAP_CMDS=()
  fi
}

trap_run() {
  local signal=$1 trap_cmd
  for trap_cmd in "${TRAP_CMDS[@]}"; do
    [[ $trap_cmd = $signal* ]] || continue
    eval "${trap_cmd#"$signal "}" || true
  done
}

trap_append() {
  trap_init
  local cmd=$1 signal=$2 trap_cmd
  # shellcheck disable=SC2034
  TRAP_POINTER=${#TRAP_CMDS[@]}
  TRAP_CMDS+=("$signal $cmd")
  # shellcheck disable=SC2064
  trap "trap_run $signal" "$signal"
}

trap_remove() {
  trap_init
  # shellcheck disable=SC2034
  local pointer=$1
  unset "TRAP_CMDS[pointer]"
}
