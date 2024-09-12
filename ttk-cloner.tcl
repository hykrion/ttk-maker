package require Tk

array set me {
  mode ""
  modes {light dark}
  basePath "./theme/"
  imgPattern "*.gif"
  modeColorMapFile ""
  newThemeSelectbg "#217346"
  azureColor "#007fff"
}

array set ui {
  themeName ""
}

array set colorMap {}

# -----------------------------------------------
proc select_new_base_color {} {
  global me
  
  set color [tk_chooseColor -initialcolor $me(newThemeSelectbg) -title "Choose color"]
  .nbk.tab1.btnColor configure -background $color
  set me(newThemeSelectbg) $color
}

# -----------------------------------------------
proc rgb_component_in_range {c} {
  set result $c
  
  if {$result < 0} {
    set result 0
    puts "Error in component 'rgb'. Value < 0."
  } elseif {$result > 255} {
    set result 255
    puts "Error in component 'rgb'. Value > 255."
  }
  
  return $result
}

# -----------------------------------------------
proc hex_to_rgb {hex} {
  scan $hex "#%2x%2x%2x" r g b

  set r [rgb_component_in_range $r]
  set g [rgb_component_in_range $g]
  set b [rgb_component_in_range $b]
  
  return [list $r $g $b]
}

# -----------------------------------------------
proc rgb_to_hex {rgb} {
  set result "#ffffff"
  
  lassign $rgb r g b
  
  set r [rgb_component_in_range $r]
  set g [rgb_component_in_range $g]
  set b [rgb_component_in_range $b]
  
  if {$r ne "" && $g ne "" && $b ne ""} {
    set xr [format "%02x" $r]
    set xg [format "%02x" $g]
    set xb [format "%02x" $b]
    
    set result "#$xr$xg$xb"
  } else {
    puts "incorrect rgb: $r$g$b"
  }
  
  return $result
}

# -----------------------------------------------
proc get_mode_path {} {
  global me
  
  return [file nativename [string cat $me(basePath) $me(mode) "-base"]]
}

# -----------------------------------------------
proc get_theme_path {} {
  global me
  global ui
  
  return [file nativename [file join $me(basePath) $ui(themeName) $me(mode)]]
}

# -----------------------------------------------
proc get_mode_color_map_file_name {} {
  global me
  
  return [file nativename [string cat $me(mode) "-colors.txt"]]
}

# -----------------------------------------------
proc copy_original_images {org dst pattern} {
  set org [file nativename $org]
  set images [file nativename [glob -directory $org $pattern]]
  file mkdir $dst
  
  foreach image $images {
    set imageName [file tail $image]
    set imageDst [file nativename [file join $dst $imageName]]
    file copy -force $image $imageDst
  }
}

# -----------------------------------------------
proc load_color_map_file {} {
  global me
  global ui
  global colorMap
  
  # orgCol;Main/None;dstCol
  set fd [open $me(modeColorMapFile) r]
  set data [read $fd]
  set lines [split $data \n]
  close $fd
  
  foreach line $lines {
    lassign [split $line ";"] k main v
    
    if {$k ne "" && $main ne "" && $v ne ""} {
      set ui(spinbox-$k) $main
      set colorMap($k) $v
    }
  }
}

# -----------------------------------------------
proc map_colors {} {
  global me
  global ui
  global colorMap
  
  set orgSelectbgRGB [hex_to_rgb $me(azureColor)]
  lassign $orgSelectbgRGB r0 g0 b0
  set dstSelectbgRGB [hex_to_rgb $me(newThemeSelectbg)]
  lassign $dstSelectbgRGB r00 g00 b00
  
  set fd [open $me(modeColorMapFile) w]
  
  foreach {k v} [array get ui spinbox-*] {
    set i [string first - $k]
    incr i
    set k [string range $k $i end]
    set rgb1 [hex_to_rgb $k]
    
    # Distancia entre el color base de Azure y este color del tema
    lassign $rgb1 r1 g1 b1
    set dstR [expr {$r1 - $r0}]
    set dstG [expr {$g1 - $g0}]
    set dstB [expr {$b1 - $b0}]

    set r [expr {$r00 + $dstR}]
    set g [expr {$g00 + $dstG}]
    set b [expr {$b00 + $dstB}]
    
    # Solo modificamos los identificados con Main
    set dstHex $k
    
    if {$v eq "Main"} {
      set dstHex [rgb_to_hex [list $r $g $b]]
    }
    
    if {$k ne "" && $dstHex ne ""} {
      set colorMap($k) $dstHex
      puts $fd "$k;$v;$dstHex"
    } else {
      puts "Trying to save null value in colorMap: $k;$v;$dstHex"
    }
  }
  
  close $fd
}

# -----------------------------------------------
proc setup_main_theme_color {} {
  global me
  
  set fd [open [file nativename [file join $me(basePath) azure-base.tcl]] r]
  set data [read $fd]
  set lines [split $data \n]
  close $fd
  set fd [open [file nativename [file join $me(basePath) azure.tcl]] w]
  # TODO  Poder cambiar otros parámetros
  set mapping [list DARK_SELECTBG $me(newThemeSelectbg) LIGHT_SELECTBG $me(newThemeSelectbg)]
  
  foreach line $lines {
    set line [string map $mapping $line]
    puts $fd $line
  }
  close $fd
}

# -----------------------------------------------
proc check_theme_name {} {
  global me
  global ui
  
  if {$ui(themeName) ne ""} {
    foreach mode $me(modes) {
      set me(mode) $mode
      set path [get_theme_path]
      set me(modeColorMapFile) [get_mode_color_map_file_name]

      copy_original_images [get_mode_path] $path $me(imgPattern)
      load_color_map_file
      map_colors
      create_new_theme
    }
  }
}

# -----------------------------------------------
proc create_new_theme {} {
  global me
  global colorMap
  
  # Guardar imágenes modificadas
  set path [get_theme_path]
  set images [file nativename [glob -directory $path $me(imgPattern)]]
  
  foreach img $images {
    image create photo anImage -file $img
    set h [image height anImage]
    set w [image width anImage]
    
    for {set i 0} {$i < $w} {incr i} {
      for {set j 0} {$j < $h} {incr j} {
        set color [anImage get $i $j]
        set hexColor [rgb_to_hex $color]
        # TODO  Comprobar que existen
        anImage put $colorMap($hexColor) -to $i $j
      }
    }
    anImage write $img
    image delete anImage
  }
  
  setup_main_theme_color
}

# -----------------------------------------------
proc ui_init_tab1 {frm} {
  global me
  
  set w1 [ttk::label $frm.lbl -text "Theme name: "]
  set w2 [ttk::entry $frm.ent -textvariable ui(themeName)]
  grid $w1 $w2
  set w1 [ttk::label $frm.lblColor -text "Base color: "]
  set w2 [button $frm.btnColor -background $me(newThemeSelectbg) -text "  Color  " -command select_new_base_color]
  grid $w1 $w2 -sticky ew
  set w [ttk::button $frm.btn -text "Create" -command check_theme_name]
  grid $w
}

# -----------------------------------------------
proc ui_init {} {
  set nbk [ttk::notebook .nbk]
  set frmTab1 [ttk::frame $nbk.tab1]
  
  ui_init_tab1 $frmTab1
  
  $nbk add $frmTab1 -text "Name"
  
  grid $nbk
}

# +++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  ui_init
}

main