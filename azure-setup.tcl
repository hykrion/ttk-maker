# Copyright © 2021 rdbende <rdbende@gmail.com>

source [file join [file dirname [info script]] theme azure.tcl]

option add *tearOff 0

proc set_theme {mode} {
  ttk::theme::azure::setup $mode
  
  set lstColors [ttk::theme::azure::get_colors]
  foreach {opt val} $lstColors {
    set colors($opt) $val
  }
  
  ttk::style theme use "azure"

  ttk::style configure . \
    -background $colors(-bg) \
    -foreground $colors(-fg) \
    -troughcolor $colors(-bg) \
    -focuscolor $colors(-selectbg) \
    -selectbackground $colors(-selectbg) \
    -selectforeground $colors(-selectfg) \
    -insertcolor $colors(-fg) \
    -insertwidth 1 \
    -fieldbackground $colors(-selectbg) \
    -font {"Segoe Ui" 10} \
    -borderwidth 1 \
    -relief flat

  tk_setPalette background [ttk::style lookup . -background] \
    foreground [ttk::style lookup . -foreground] \
    highlightColor [ttk::style lookup . -focuscolor] \
    selectBackground [ttk::style lookup . -selectbackground] \
    selectForeground [ttk::style lookup . -selectforeground] \
    activeBackground [ttk::style lookup . -selectbackground] \
    activeForeground [ttk::style lookup . -selectforeground]

  ttk::style map . -foreground [list disabled $colors(-disabledfg)]

  option add *font [ttk::style lookup . -font]
  option add *Menu.selectcolor $colors(-fg)
}
