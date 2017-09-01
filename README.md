# vim-superupdate

Superupdate integrates with your Vim plugin manager to automatically check for
and update your plugins so that you don't have to remember to.

## Configuration

### Warn
`'g:superupdate_warn'`

Type: boolean

Default: `0`

When this is a non-zero value superupdate will print a warning message when
plugins would be updated instead of actually updating them.

Example: `let g:superupdate_warn = 1`


### Interval
`'g:superupdate_interval'`

Type: integer

Default: `7` (every week)

The number of days between updates.

Example: `let g:superupdate_interval = 14` (every other week)


### Days
`'g:superupdate_days'`

Type: list (of integers)

Default: `[]` (All days, same as `[0, 1, 2, 3, 4, 5, 6]`)

A list of the days when updates should be allowed to take place. Days are to
be represented as integers with 0 being Monday and 6 being Sunday.

Example: `let g:superupdate_days = [4, 5, 6]` (Friday, Saturday or Sunday)


### Command
`'g:superupdate_command'`

Type: string

Default: None (attempts to autodetect, working for Vundle and vim-plug)

The command used to update plugins.

Example: `let g:superupdate_command = 'PlugUpdate'` (vim-plug)

### Skip First
`'g:superupdate_skip_first'`

Type: boolean

Default: `0`

When this is a non-zero value superupdate will skip trying to update plugins on
it's first run.

Example `let g:superupdate_skip_first = 1`

## Help
Also check out the help page: `:help superupdate`.
