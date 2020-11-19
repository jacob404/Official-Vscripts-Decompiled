///////////////////////////////////////////////////////////////////////////////
// brutal hack to layout the stupid thing!
// you can include this in scriptedmode.nut, set layoutGen to true, and it will console print a .res data set
// i.e. turn this to true, run, cut-and-paste the printed output in 'hudholdouttimer.res' (@todo:rename that file)
// leaving it here so that if we want to re-layout the HUD it is easy
///////////////////////////////////////////////////////////////////////////////
doStupidLayoutGen <- false

// core print per element helper
function printLayout ( elemPos, elemLayout )
{
	local eName = "Elem" + elemPos.name + elemLayout.ext
	local start_tab = "\t"   // or just "" if you rather nothing

	local x = elemPos.pos[0]
	local y = elemPos.pos[1]
	local w = elemPos.sz[0]
	local h = elemPos.sz[1]
	if ("off" in elemLayout)
	{
		x += elemLayout.off[0]
		y += elemLayout.off[1]
		w -= 2*elemLayout.off[0]
		h -= 2*elemLayout.off[1]
	}
	if ("special_data_off" in elemPos && elemLayout.ext == "Data")
	{
		x += elemPos.special_data_off[0]
		y += elemPos.special_data_off[1]
	}

	printl( start_tab + "\"" + eName + "\"\n" + start_tab + "{" )
	printl( start_tab + "\t\"fieldName\"\t\"" + eName + "\"" )
	printl( start_tab + "\t\"xpos\"\t\t\"" + x + "\"" )
	printl( start_tab + "\t\"ypos\"\t\t\"" + y + "\"" )
	printl( start_tab + "\t\"wide\"\t\t\"" + w + "\"" )	
	printl( start_tab + "\t\"tall\"\t\t\"" + h + "\"" )	
	if ("align" in elemPos)
		printl( start_tab + "\t\"textAlignment\"\t\"" + elemPos.align + "\"" )

	foreach (idx, val in elemLayout)
		if (idx != "ext" && idx != "off")  // these are meta-controls
		{
		    if (idx.len() >= 6)            // do we need 1 tab or two?
				printl( start_tab + "\t\"" + idx + "\"\t\"" + val + "\"")
		    else
				printl( start_tab + "\t\"" + idx + "\"\t\t\"" + val + "\"")
	    }

	printl( start_tab + "}\n")
}

// HEY SOMEONE - Why is this block just sitting out here? 
  // cause it is much easier to generate this data from script - and it is a hack, as the comment above explains...
  // and thus, for now, it sits here so that if we want to regenerate our UI, you can just set the variable up above to true
  // and then run a scriptedmode, and voila, you get a huge printout that you can copy paste into a .res file and have a new UI layout
  // when we get near ship, we will remove this to some other file i suppose in case we want to deal with it later?

if (doStupidLayoutGen)
{
	local _c = 320
	local ElemList =
	[
		{ name = "00", pos = [ _c - 200, 12 ], sz = [ 120, 25 ], align = "west" },     // left_top
		{ name = "01", pos = [ _c - 200, 40 ], sz = [ 120, 25 ], align = "west" },     // left_bot
		{ name = "02", pos = [  _c - 60, 12 ], sz = [ 120, 25 ], align = "center" },   // mid_top
		{ name = "03", pos = [  _c - 60, 40 ], sz = [ 120, 25 ], align = "center" },   // mid_bot
		{ name = "04", pos = [  _c + 80, 12 ], sz = [ 120, 25 ], align = "east" },     // right_top
		{ name = "05", pos = [  _c + 80, 40 ], sz = [ 120, 25 ], align = "east" },     // right_bot
		{ name = "06", pos = [ _c - 200, 70 ], sz = [ 400, 20 ], align = "center" },   // ticker
		{ name = "07", pos = [ _c - 290, 12 ], sz = [  75, 25 ], align = "west" },     // far_left
		{ name = "08", pos = [ _c + 215, 12 ], sz = [  75, 25 ], align = "east" },     // far_right
		{ name = "09", pos = [  _c - 60, 12 ], sz = [ 120, 53 ], align = "north", special_data_off = [ 0, 0 ] },   // mid_box
		{ name = "10", pos = [ _c - 220, 140], sz = [ 440, 40 ], align = "center" }    // score header
		{ name = "11", pos = [ _c - 220, 210], sz = [ 440, 20 ], align = "center" }    // score1
		{ name = "12", pos = [ _c - 220, 240], sz = [ 440, 20 ], align = "center" }    // score2
		{ name = "13", pos = [ _c - 220, 270], sz = [ 440, 20 ], align = "center" }    // score3
		{ name = "14", pos = [ _c - 220, 300], sz = [ 440, 20 ], align = "center" }    // score4

		// { name = "10", pos = [ _c - 200, 400], sz = [ 400, 20 ], align = "center" },  // unused for now
		// { name = "11", pos = [ _c - 200, 100], sz = [ 400, 200], align = "center" },  // unused for now
		// { name = "12", pos = [       40, 100], sz = [  40, 300], align = "center" },  // unused for now
	]
	
	local DataLayout = { ext = "Data", ControlName = "Label", zpos = "1", visible = "0", off = [5, 2] }
	local ImLayout = { ext = "Im", ControlName = "ScalableImagePanel", visible = "0", enabled = "1", scaleImage = "1"
		image = "../vgui/hud/ScalablePanel_bgBlack50_outlineGrey", drawcolor = "255 255 255 255" }
	local FlLayout = { ext = "Fl", ControlName = "ImagePanel", visible = "0", enabled = "1", scaleImage = "1",
		fillcolor = "0 0 0 200", zpos ="-2" }

	foreach ( idx, val in ElemList )
	{
		printLayout( val, DataLayout )
		printLayout( val, ImLayout )
		printLayout( val, FlLayout )
	}
}
