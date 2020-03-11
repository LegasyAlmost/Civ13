/datum/preferences

/datum/category_item/player_setup_item/general/basic
	name = "Basic"
	sort_order = 1
	var/list/valid_second_languages = list(ENGLISH, FRENCH, SPANISH, PORTUGUESE)

/datum/category_item/player_setup_item/general/basic/sanitize_character()
	var/list/valid_player_genders = list(MALE, FEMALE)
	var/datum/species/S = all_species[pref.species ? pref.species : "Human"]
	pref.age			= sanitize_integer(pref.age, S.min_age, S.max_age, initial(pref.age))
	pref.gender 		= sanitize_inlist(pref.gender, valid_player_genders, pick(valid_player_genders))
	pref.real_name		= sanitize_name(pref.real_name, pref.species)

	if (!pref.real_name)
		pref.real_name	= random_name(pref.gender, pref.species)

	/*										*/

/datum/category_item/player_setup_item/general/basic/content(var/mob/user)
	pref.update_preview_icons()
	. = "<b>UI Style: </b><a href='?src=\ref[src];select_style=1'><b>[pref.UI_style]</b></A><br><br>"
	var/currcursor = "Default"
	if (pref.cursor == 'icons/effects/red_cursors.dmi')
		currcursor = "Red Crosshair"

	else if (pref.cursor == 'icons/effects/white_cursors.dmi')
		currcursor = "White Crosshair"

	else if (pref.cursor == 'icons/effects/green_cursors.dmi')
		currcursor = "Green Crosshair"
	else
		currcursor = "Default"
	. += "<b>Cursor Style: </b><a href='?src=\ref[src];select_cursor=1'><b>[currcursor]</b></A><br><br>"
	for (var/v in TRUE to pref.preview_icons.len)
		if (isicon(pref.preview_icons_front[v]))
			user << browse_rsc(pref.preview_icons_front[v], "previewicon_[v]_front.png")
		if (isicon(pref.preview_icons_back[v]))
			user << browse_rsc(pref.preview_icons_back[v], "previewicon_[v]_back.png")
		if (isicon(pref.preview_icons_east[v]))
			user << browse_rsc(pref.preview_icons_east[v], "previewicon_[v]_east.png")
		if (isicon(pref.preview_icons_west[v]))
			user << browse_rsc(pref.preview_icons_west[v], "previewicon_[v]_west.png")
	. += "<b>Preview</b><br>"

	for (var/v in TRUE to pref.preview_icons.len)
		. += "<img src=previewicon_[v]_front.png height=64 width=64>"
		. += "<img src=previewicon_[v]_back.png height=64 width=64>"
		. += "<img src=previewicon_[v]_east.png height=64 width=64>"
		. += "<img src=previewicon_[v]_west.png height=64 width=64>"
		. += "<br><br>"
	// name
	. += "<b>Name:</b> "
	. += "<a href='?src=\ref[src];rename=1'><b>[pref.real_name]</b></a><br><br>"
	. += "(<a href='?src=\ref[src];random_name=1'>Randomize Name</a>)<br><br>"
	. += "<b>Always Randomize Name:</b> <a href='?src=\ref[src];always_random_name=1'>[pref.be_random_name ? "Yes" : "No"]</a><br><br>"
	. += "<b>Traits: ([check_trait_points(pref.traits)])</b><br>"
	. += "<i>(The sum of trait values has to be <b>0</b>)</i><br>"
	. += "<a href='?src=\ref[src];add_traits=1'>Add</a> <a href='?src=\ref[src];remove_traits=1'>Remove</a><br><br>"
	if (pref.traits.len)
		for (var/i=1, i<=pref.traits.len, i++)
			if (pref.traits[i] != "Cancel")
				if (i == pref.traits.len)
					. += "[pref.traits[i]] ([trait_list[pref.traits[i][1]]])"
				else
					. += "[pref.traits[i]] ([trait_list[pref.traits[i][1]]]), "
/datum/category_item/player_setup_item/general/basic/OnTopic(var/href,var/list/href_list, var/mob/user)

	//real names
	if (href_list["rename"])
		var/raw_name = input(user, "Choose your character's name:", "Character Name")  as text|null
		if (!isnull(raw_name) && CanUseTopic(user))
			var/new_name = sanitize_name(raw_name, pref.species)
			if (new_name)
				pref.real_name = new_name
				return TOPIC_REFRESH
			else
				user << "<span class='warning'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</span>"
				return TOPIC_NOACTION

	else if (href_list["random_name"])
		pref.real_name = random_name(pref.gender, pref.species)
		return TOPIC_REFRESH

	else if (href_list["always_random_name"])
		pref.be_random_name = !pref.be_random_name
		return TOPIC_REFRESH

	else if (href_list["select_style"])
		var/UI_style_new = input(user, "Choose UI style:", "UI Style", pref.UI_style) as null|anything in all_ui_styles
		if (!UI_style_new || !CanUseTopic(user)) return TOPIC_NOACTION
		pref.UI_style = UI_style_new
		pref.save_preferences()
		return TOPIC_REFRESH

	else if (href_list["select_cursor"])
		var/cursor_new = WWinput(usr, "Choose Cursor Style:", "Mouse Cursor", "Default", list("Default","Red Crosshair","Green Crosshair","White Crosshair"))
		if (cursor_new == "Default")
			pref.cursor = null
		else if (cursor_new == "Red Crosshair")
			pref.cursor = 'icons/effects/red_cursors.dmi'
		else if (cursor_new == "White Crosshair")
			pref.cursor = 'icons/effects/white_cursors.dmi'
		else if (cursor_new == "Green Crosshair")
			pref.cursor = 'icons/effects/green_cursors.dmi'
		else
			pref.cursor = null
		pref.save_preferences()
		return TOPIC_REFRESH

	else if (href_list["add_traits"])
		var/list/possible = list("Cancel")
		for(var/i=1, i<= trait_list.len, i++)
			possible += trait_list[i]
		for(var/tt in possible)
			if (tt != "Cancel")
				if (tt in pref.traits)
					possible -= tt
				else
					for(var/tt2 in trait_list[tt][2])
						if (tt2 in pref.traits)
							possible -= tt
		for(var/tt in possible)
			if (tt != "Cancel")
				possible -= tt
				tt = "[tt] ([trait_list[tt][1]])"
				possible += tt
		var/add = WWinput(usr, "Add Trait:", "Traits", "Cancel", possible)
		if (!findtext(add,"Cancel"))
			var/list/padd = splittext(add," (")
			world << "[padd]"
			pref.traits += padd[1]
		pref.save_preferences()
		return TOPIC_REFRESH

	else if (href_list["remove_traits"])
		var/list/possible = pref.traits
		possible += "Cancel"
		for(var/tt in possible)
			if (tt != "Cancel")
				possible -= tt
				tt = "[tt] ([trait_list[tt][1]])"
				possible += tt
		var/remove = WWinput(usr, "Remove Trait:", "Traits", "Cancel", possible)
		if (!findtext(remove,"Cancel"))
			var/list/premove = splittext(remove," (")
			pref.traits -= premove[1]
		pref.save_preferences()
		return TOPIC_REFRESH
	return ..()
/proc/check_trait_points(var/list/traitlist = list())
	if (isemptylist(traitlist))
		return 0
	var/count = 0
	for (var/i in traitlist)
		if (trait_list[i] && trait_list[i][1]!=0)
			count += trait_list[i][1]
	return count