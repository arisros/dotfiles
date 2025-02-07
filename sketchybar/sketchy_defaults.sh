##### Bar Appearance #####
# color           <argb_hex>	0x44000000	Color of the bar
# border_color    <argb_hex>	0xffff0000	Color of the bars border
# position        top, bottom	top	Position of the bar on the screen
# height	        <integer>	25	Height of the bar
# margin	        <integer>	0	Margin around the bar
# y_offset	      <integer>	0	Vertical offset of the bar from its default position
# corner_radius	  <positive_integer>	0	Corner radius of the bar
# border_width	  <positive_integer>	0	Border width of the bars border
# blur_radius	    <positive_integer>	0	Blur radius applied to the background of the bar
# padding_left	  <positive_integer>	0	Padding between the left bar border and the leftmost item
# padding_right	  <positive_integer>	0	Padding between the right bar border and the rightmost item
# notch_width	    <positive_integer>	200	The width of the notch to be accounted for on the internal display
# notch_offset	  <positive_integer>	0	Additional y_offset exclusively applied to notched screens
# display	        main, all, <positive_integer list>	all	Display to show the bar on
# hidden	        <boolean>, current	off	If all / the current bar is hidden
# topmost	        <boolean>, window	off	If the bar should be drawn on top of everything, or on top of all windows
# sticky	        <boolean>	on	Makes the bar sticky during space changes
# font_smoothing	<boolean>	off	If fonts should be smoothened
# shadow	        <boolean>	off	If the bar should draw a shadow

bar=(
  color=$BAR
  border_color=$BAR
  border_width=0
  position=right
  height=$BAR_WIDTH # height is width when bar on left/right
  margin=0
  y_offset=-2
  corner_radius=0
  blur_radius=0
  padding_left=1
  padding_right=10
  notch_width=0
  notch_offset=0
  display=all
  hidden=off
  topmost=off
  sticky=off
  font_smoothing=off
  shadow=on
)
sketchybar --bar "${bar[@]}"

##### Changing Defaults #####
default=(
  background.height=$ITEM_HEIGHT
  background.color=$TRANSPARENT
  background.corner_radius=5
  icon.font="$FONT:$ICON_FONTSIZE"
  icon.color=$TEXT
  label.font="$FONT:$FONTSIZE"
  label.color=$TEXT
  padding_left=0
  padding_right=0

  icon.width=$BAR_WIDTH
  icon.align="center"
  icon.padding_left=0
  icon.padding_right=0

  label.width=$BAR_WIDTH
  label.align="center"
  label.y_offset=$LABEL_Y_OFFSET # hack since on next line
  label.padding_left=-$BAR_WIDTH # each item needs to be pulled left using negative number
  label.padding_right=$BAR_WIDTH # but needs to double in width because center aligned
)
sketchybar --default "${default[@]}"
