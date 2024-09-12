package require Tk

source azure-setup.tcl

array set ui {
  mode dark
  unchecked 0
  checked 1
  radio yes
  entry Entry
  spinbox Spinbox
  combobox Combobox
  comboboxRO "Readonly combobox"
  menuRadio yes
  toogle 0
  switch 0
}

# -----------------------------------------------
proc change_mode {} {
  global ui
  
  set_theme $ui(mode)
}

# -----------------------------------------------
proc ui_init_checkbuttons {} {
  global ui
  
  set frm [ttk::labelframe .frmMain.frmLeft.lblFrmCheckbuttons -text Checkbuttons]
  grid $frm -ipadx 10 -ipady 10
  set w [ttk::checkbutton $frm.chkbtnUnchecked -text Unchecked -variable ui(unchecked) -onvalue 1 -offvalue 0]
  grid $w -sticky nsew -padx 40 -pady 10
  set w [ttk::checkbutton $frm.chkbtnChecked -text Checked -variable ui(checked) -onvalue 1 -offvalue 0]
  grid $w -sticky nsew -padx 40 -pady 10
  set w [ttk::checkbutton $frm.chkbtnThirdState -text "Third state" -variable ui(thirdState) -onvalue 1 -offvalue 0]
  grid $w -sticky nsew -padx 40 -pady 10
  set w [ttk::checkbutton $frm.chkbtnDisabled -text Disabled -variable ui(disabled) -onvalue 1 -offvalue 0 -state disabled]
  grid $w -sticky nsew -padx 40 -pady 10
}

# -----------------------------------------------
proc ui_init_separator {} {
  set w [ttk::separator .frmMain.frmLeft.sep]
  grid $w -sticky ew -pady 40
}

# -----------------------------------------------
proc ui_init_radiobuttons {} {
  global ui
  
  set frm [ttk::labelframe .frmMain.frmLeft.lblFrmRadiobuttons -text Radiobuttons]
  grid $frm -sticky nsew -ipadx 10 -ipady 10
  set w [ttk::radiobutton $frm.radBtnUnselected -text Unselected -variable ui(radio) -value no]
  grid $w -sticky nsew -padx 40 -pady 10
  set w [ttk::radiobutton $frm.radBtnSelected -text Selected -variable ui(radio) -value yes]
  grid $w -sticky nsew -padx 40 -pady 10
  set w [ttk::radiobutton $frm.radBtnDisabled -text Disabled -state disabled]
  grid $w -sticky nsew -padx 40 -pady 10
}

# -----------------------------------------------
proc ui_init_grid {} {
  set w1 [ttk::frame .frmMain]
  set w2 [ttk::frame $w1.frmLeft]
  set w3 [ttk::frame $w1.frmCenter]
  set w4 [ttk::frame $w1.frmRight]
  
  grid $w2 $w3 $w4 -padx 20 -pady 20
  grid $w1
}

# -----------------------------------------------
proc ui_init_left {} {
  ui_init_checkbuttons
  ui_init_separator
  ui_init_radiobuttons
}

# -----------------------------------------------
proc ui_init_center {} {
  global ui
  
  set w [ttk::entry .frmMain.frmCenter.ent -textvariable ui(entry)]
  grid $w -sticky nsew -padx 5 -pady 10
  set w [ttk::spinbox .frmMain.frmCenter.spnbox -values {One Two Spinbox} -textvariable ui(spinbox)]
  grid $w -sticky nsew -padx 5 -pady 10
  set w [ttk::combobox .frmMain.frmCenter.combobox -values {One Two Combobox} -textvariable ui(combobox)]
  grid $w -sticky nsew -padx 5 -pady 10
  set w [ttk::combobox .frmMain.frmCenter.comboboxRO -values {One Two "Readonly combobox"} -textvariable ui(comboboxRO) -state readonly]
  grid $w -sticky nsew -padx 5 -pady 10
  
  set m [menu .menubar]
  . configure -menu $m
  menu $m.options -tearoff 0
  $m add cascade -menu $m.options -label "Menu"
  $m.options add command -label "Menu item 1"
  $m.options add command -label "Menu item 2"
  $m.options add separator
  $m.options add command -label "Menu item 3"
  $m.options add command -label "Menu item 4"
  $m.options add separator
  $m.options add radiobutton -label "Radio 1" -variable ui(menuRadio) -value yes
  $m.options add radiobutton -label "Radio 2" -variable ui(menuRadio) -value no
  $m.options add separator
  $m.options add checkbutton -label "Checkbutton 1" -variable ui(checked) -onvalue 1 -offvalue 0  
  set mbtn [ttk::menubutton .frmMain.frmCenter.menbtn -text Menubutton -menu $m -direction below]
  grid $mbtn -sticky nsew

  # Not useful because it's not ttk. The Tkinter optionMenu is a ttk::menubutton
  # NOTE  Cannot use w and grid $w
  # tk_optionMenu .frmMain.frmCenter.optMen ui(optionMenu) Foo Bar Boo
  # grid .frmMain.frmCenter.optMen
  
  set w [ttk::button .frmMain.frmCenter.btn -text Button]
  grid $w -sticky nsew -padx 5 -pady 10
  set w [ttk::button .frmMain.frmCenter.btnAccent -text "Accent button" -style Accent.TButton]
  grid $w -sticky nsew -padx 5 -pady 10
  set w [ttk::checkbutton .frmMain.frmCenter.btnToggle -text "Toggle button" -variable ui(toogle) -onvalue 1 -offvalue 0 -style Toggle.TButton]
  grid $w -sticky nsew -padx 5 -pady 10
  set w [ttk::checkbutton .frmMain.frmCenter.btnSwitch -text Switch -variable ui(switch) -onvalue 1 -offvalue 0 -style Switch.TCheckbutton]
  grid $w -sticky nsew -padx 5 -pady 10
  # TODO
  # set w [ttk::checkbutton .frmMain.frmCenter.btnMode -text "dark/light" -variable ui(mode) -onvalue dark -offvalue light -style Switch.TCheckbutton -command change_mode]
  # grid $w -sticky nsew -padx 5 -pady 10
}

# -----------------------------------------------
proc ui_init_right {} {
  ttk::style configure Sash -sashthickness 20
  # Panedwindow
  set pndwnd [ttk::panedwindow .frmMain.frmRight.pndWnd -orient vertical]
  set frmlblTop [ttk::labelframe $pndwnd.frmlblTop -text Top]
  set frmlblBottom [ttk::labelframe $pndwnd.frmlblBottom -text Bottom]
  $pndwnd add $frmlblTop
  $pndwnd add $frmlblBottom
  grid $pndwnd -sticky nsew -padx 5 -pady 25

  # Treview
  set w [ttk::treeview $frmlblTop.tree -columns "c1 c2"]
  $w heading #0 -text Item
  $w heading c1 -text "Value 1" -anchor w
  $w heading c2 -text "Value 2" -anchor w
  for {set i 0} {$i < 3} {incr i} {
    $w insert {} end -text "item - $i" -values {one two}
  }
  $w insert {} end -id parent1 -text "Parent - 1" -open true
  for {set i 0} {$i < 3} {incr i} {
    $w insert parent1 end -text "child - $i" -values {one two}
  }
  $w insert {} end -id parent2 -text "Parent - 2"
  for {set i 0} {$i < 10} {incr i} {
    $w insert parent2 end -text "child - $i" -values {one two}
  }
  # Scrollbar
  set scrbar [ttk::scrollbar $frmlblTop.scrbar -orient vertical -command "$w yview"]
  #puts $scrbar
  $w configure -yscrollcommand "$scrbar set"
  grid $w $scrbar -sticky ns
  
  # grid [tk::listbox .l -yscrollcommand ".s set" -height 5] -column 0 -row 0 -sticky nwes
  # grid [ttk::scrollbar .s -command ".l yview" -orient vertical] -column 1 -row 0 -sticky ns
  # grid [ttk::label .stat -text "Status message here" -anchor w] -column 0 -columnspan 2 -row 1 -sticky we
  # grid columnconfigure . 0 -weight 1; grid rowconfigure . 0 -weight 1
  # for {set i 0} {$i<100} {incr i} {
     # .l insert end "Line $i of 100"
  # }
  
  # Notebook
  set n [ttk::notebook $frmlblBottom.notebook]
  set t1 [ttk::frame $n.frmTab1]
  set t2 [ttk::frame $n.frmTab2]
  set t3 [ttk::frame $n.frmTab3]
  $n add $t1 -text "Tab 1"
  $n add $t2 -text "Tab 2"
  $n add $t3 -text "Tab 3"
  set w1 [ttk::scale $t1.scale -from 0.0 -to 10.0 -value 2]
  set w2 [ttk::progressbar $t1.progressbar -value 70]
  grid $w1 $w2 -padx {20 10} -pady {20 0}
  set w [ttk::label $t1.lbl -text "Azure theme for ttk" -justify center -font {arial 16 bold}]
  grid $w -padx {20 10} -pady {20 0}
  
  grid $n
}

# +++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  if {$::argc == 1} {
    lassign $::argv mode
    set_theme $mode
    
    ui_init_grid
    ui_init_left
    ui_init_center
    ui_init_right
  } else {
    tk_messageBox -message "Usage: example.tcl light/dark"
  }
}

main