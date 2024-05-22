#!/usr/bin/env bats

bats_load_library bats-support
bats_load_library bats-assert

setup_file() {
  bats_require_minimum_version 1.5.0
}

@test 'trap is run on signal' {
  assert_equal "$(bash -ec "source $BATS_TEST_DIRNAME/trap.sh
  trap_append \"echo 'USR2 signal received'\" USR2
  kill -s USR2 \$BASHPID
  ")" 'USR2 signal received'
}

@test 'trap removal works' {
  assert_equal "$(bash -ec "source $BATS_TEST_DIRNAME/trap.sh
  trap_append \"echo 'cmd to remove'\" USR2
  p=\$TRAP_POINTER
  trap_append \"echo 'USR2 signal received'\" USR2
  trap_remove \$p
  kill -s USR2 \$BASHPID
  ")" 'USR2 signal received'
}

@test 'only commands for specific signal are run' {
  assert_equal "$(bash -ec "source $BATS_TEST_DIRNAME/trap.sh
  trap_append \"echo 'USR1 signal received'\" USR1
  trap_append \"echo 'USR2 signal received'\" USR2
  kill -s USR2 \$BASHPID
  ")" 'USR2 signal received'
}

@test 'commands run in order' {
  assert_equal "$(bash -ec "source $BATS_TEST_DIRNAME/trap.sh
  trap_append \"echo 'cmd to remove'\" USR2
  p=\$TRAP_POINTER
  trap_append \"echo 'USR2 signal received'\" USR2
  trap_remove \$p
  trap_append \"echo 'last command'\" USR2
  kill -s USR2 \$BASHPID
  ")" 'USR2 signal received
last command'
}

@test 'subshells are isolated' {
  assert_equal "$(bash -ec "source $BATS_TEST_DIRNAME/trap.sh
  trap_append \"echo 'should not run'\" USR2
  (
    trap_append \"echo 'USR2 signal received'\" USR2
    kill -s USR2 \$BASHPID
  )
  ")" 'USR2 signal received'
}

@test 'trap_prepend works' {
  assert_equal "$(bash -ec "source $BATS_TEST_DIRNAME/trap.sh
  trap_append \"echo 'should run third'\" USR2
  trap_prepend \"echo 'should run second'\" USR2
  trap_append \"echo 'should run last'\" USR2
  trap_prepend \"echo 'should run first'\" USR2
  kill -s USR2 \$BASHPID
  ")" $'should run first\nshould run second\nshould run third\nshould run last'
}
