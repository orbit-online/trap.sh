# trap.sh

Library for managing bash signal traps.

## Contents

- [Installation](#installation)
- [Usage](#usage)

## Installation

With [μpkg](https://github.com/orbit-online/upkg)

```
upkg install -g orbit-online/trap.sh@<VERSION>
```

## Usage

### `trap_append CMD SIGNAL`

Appends `CMD` to the `SIGNAL` trap. `$TRAP_POINTER` will contain a pointer
that can be used with `trap_remove` to remove the command again.

### `trap_remove POINTER`

Removes the command identified by `POINTER` from the list of traps to run.
