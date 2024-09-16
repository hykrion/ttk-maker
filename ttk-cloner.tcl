package require Tk

array set me {
  mode "dark"
  basePath "./theme/"
  modePath ""
  baseTheme azure
  imgFormat "*.gif"
  traImgFormat "*.x"
  azureColor "#007fff"
  forestColor "#217346"
  newThemeSelectbg "#217346"
  modeColorMapFile ""
}

array set ui {
  themeName ""
}

array set themeColors {}
array set colorMap {}

# -----------------------------------------------
proc change_color_map {w k v} {
  global colorMap

  set color [tk_chooseColor -initialcolor $v -title "Escoge color"]
  set colorMap($k) $color
  $w configure -background $color
}

# -----------------------------------------------
proc check_theme_name {} {
  global me
  global ui

  if {$ui(themeName) ne ""} {
    set path [get_theme_path]
    set imgFormat [get_image_format]
    set me(modeColorMapFile) [get_mode_color_map_file_name]

    copy_original_images [get_mode_path] $path $imgFormat

    if {[file exists $me(modeColorMapFile)]} {
      load_color_map_file
      create_new_theme
    }
  }
}

# -----------------------------------------------
proc copy_original_images {org dst imgFormat} {
  set org [file nativename $org]
  set images [file nativename [glob -directory $org $imgFormat]]
  file mkdir $dst

  foreach image $images {
    set imageName [file tail $image]
    set imageDst [file nativename [file join $dst $imageName]]
    file copy -force $image $imageDst
  }
}

# -----------------------------------------------
proc create_new_theme {} {
  global me
  global colorMap

  set path [get_theme_path]
  set images [file nativename [glob -directory $path $me(imgFormat)]]

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
  overwrite_transparent_images [get_mode_path] $path $me(traImgFormat)
  setup_main_theme_color
}

# -----------------------------------------------
proc get_base_theme {} {
  global me

  set result [file nativename [file join $me(base) $me(baseTheme) $me(mode)]]

  return $result
}

# -----------------------------------------------
proc get_image_format {} {
  global me

  if {$me(baseTheme) eq "azure"} {
    set me(imgFormat) "*.gif"
  } elseif {$me(baseTheme) eq "forest"} {
    set me(imgFormat) "*.png"
  }
}

# -----------------------------------------------
proc get_mode_color_map_file_name {} {
  global me

  return [file nativename [string cat $me(baseTheme) "-" $me(mode) "-colors.txt"]]
}

# -----------------------------------------------
proc get_mode_path {} {
  global me

  return [file nativename [file join $me(basePath) [string cat $me(baseTheme) "-" $me(mode)]]]
}

# -----------------------------------------------
proc get_original_theme_colors {path pattern} {
  global themeColors
  global ui

  set images [file nativename [glob -directory $path $pattern]]

  foreach img $images {
    image create photo anImage -file $img
    set imgH [image height anImage]
    set imgW [image width anImage]

    for {set i 0} {$i < $imgW} {incr i} {
      for {set j 0} {$j < $imgH} {incr j} {
        set color [anImage get $i $j]
        # Colores del tema
        set themeColors($color) $color
        # Rellenar los spinbox del canva tab1
        set hexColor [rgb_to_hex $color]
        set ui(spinbox-$hexColor) None
      }
    }
    image delete anImage
  }
}

# -----------------------------------------------
proc get_theme_path {} {
  global me
  global ui

  return [file nativename [file join $me(basePath) $ui(themeName) $me(mode)]]
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
proc load_color_map_file {} {
  global me
  global ui
  global colorMap

  # orgCol(hex);Main/None;dstCol(rgb)
  set fd [open $me(modeColorMapFile) r]
  set data [read $fd]
  set lines [split $data \n]
  close $fd
  
  foreach line $lines {
    lassign [split $line ";"] k main v

    if {$k ne "" && $main ne "" && $v ne ""} {
      set ui(spinbox-$k) $main
      
      if {$main eq "Main"} {
        lassign $v dstR dstG dstB
        set kRGB [hex_to_rgb $me(newThemeSelectbg)]
        lassign $kRGB kr kg kb
        set vr [expr {$kr + $dstR}]
        set vg [expr {$kg + $dstG}]
        set vb [expr {$kb + $dstB}]
        set rgb [list $vr $vg $vb]
        set v [rgb_to_hex $rgb]
      } else {
        set v $k
      }
      
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
      puts "Intentando guardar valor nulo en colorMap: $k;$v;$dstHex"
    }
  }

  close $fd
}

# -----------------------------------------------
proc overwrite_transparent_images {org dst imgFormat} {
  global me

  set org [file nativename $org]
  set images [file nativename [glob -directory $org $imgFormat]]

  foreach image $images {
    set imageName [file tail $image]
    lassign [split $imageName .] name ext
    lassign [split $me(imgFormat) .] regex ext
    set imageName [string cat $name . $ext]
    set imageDst [file nativename [file join $dst $imageName]]
    file copy -force $image $imageDst
  }
}

# -----------------------------------------------
proc rgb_component_in_range {c} {
  set result $c

  if {$result < 0} {
    set result 0
    puts "Error en componente 'rgb'. Valor < 0."
  } elseif {$result > 255} {
    set result 255
    puts "Error en componente 'rgb'. Valor > 255."
  }

  return $result
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
    puts "rgb incorrecto: $r$g$b"
  }

  return $result
}

# -----------------------------------------------
proc select_new_base_color {} {
  global me

  set color [tk_chooseColor -initialcolor $me(newThemeSelectbg) -title "Escoge color"]
  .nbk.tab1.btnColor configure -background $color
  set me(newThemeSelectbg) $color
}

# -----------------------------------------------
proc setup_main_theme_color {} {
  global me

  set baseFile [string cat $me(baseTheme) "-base.tcl"]
  set fd [open [file nativename [file join $me(basePath) $baseFile]] r]
  set data [read $fd]
  set lines [split $data \n]
  close $fd
  set fd [open [file nativename [file join $me(basePath) $me(baseTheme).tcl]] w]
  # TODO  Poder cambiar otros parámetros
  set mapping [list DARK_SELECTBG $me(newThemeSelectbg) LIGHT_SELECTBG $me(newThemeSelectbg)]

  foreach line $lines {
    set line [string map $mapping $line]
    puts $fd $line
  }
  close $fd
}

# -----------------------------------------------
# -----------------------------------------------
proc ui_create_rectangle {cnv x0 y0 color} {
  incr y0 -15
  set w 50
  set h 35
  set x1 [expr {$x0 + $w}]
  set y1 [expr {$y0 + $h}]
  $cnv create rectangle $x0 $y0 $x1 $y1 -fill $color
}

# -----------------------------------------------
proc ui_init {} {
  set nbk [ttk::notebook .nbk]
  set frmTab1 [ttk::frame $nbk.tab1]

  ui_init_tab1 $frmTab1

  $nbk add $frmTab1 -text "New thme"

  grid $nbk
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
  set w1 [ttk::radiobutton $frm.radbtnDarkMode -text dark -value dark -variable me(mode)]
  set w2 [ttk::radiobutton $frm.radbtnLightMode -text light -value light -variable me(mode)]
  grid $w1 $w2
  set w1 [ttk::radiobutton $frm.radbtnBaseAzure -text Azure -value azure -variable me(baseTheme)]
  set w2 [ttk::radiobutton $frm.radbtnBaseForest -text Forest -value forest -variable me(baseTheme)]
  grid $w1 $w2
  set w [ttk::button $frm.btn -text "Save" -command check_theme_name]
  grid $w
}

# -----------------------------------------------
proc update_new_theme {} {
  global me

  set path [get_theme_path]
  set baseTheme [get_base_theme]
  copy_original_images $baseTheme $path $me(imgFormat)
  create_new_theme
}

# +++++++++++++++++++++++++++++++++++++++++++++++
# +++++++++++++++++++++++++++++++++++++++++++++++
proc main {} {
  ui_init
}

main