/proc/getHumanBreakoutTime(var/mob/living/human/H, var/time = 100)
	if (!istype(H))
		return time
	return time /= (H.getStatCoeff("strength")*H.getStatCoeff("strength"))

/mob/living/human/process_resist()

	//drop && roll
	if (on_fire && !buckled)
		fire_stacks -= 1.2
		Weaken(3)
		spin(32,2)
		visible_message(
			"<span class='danger'>[src] rolls on the floor, trying to put themselves out!</span>",
			"<span class='notice'>You stop, drop, and roll!</span>"
			)
		sleep(30)
		if (fire_stacks <= 0)
			visible_message(
				"<span class='danger'>[src] has successfully extinguished themselves!</span>",
				"<span class='notice'>You extinguish yourself.</span>"
				)
			ExtinguishMob()
		return TRUE

	if (..())
		return TRUE

	if (handcuffed)
		spawn() escape_handcuffs()
	else if (legcuffed)
		spawn() escape_legcuffs()

/mob/living/human/proc/escape_handcuffs()
	//if (!(last_special <= world.time)) return

	//This line represent a significant buff to grabs...
	// We don't have to check the click cooldown because /mob/living/verb/resist() has done it for us, we can simply set the delay
	setClickCooldown(100)

	if (can_break_cuffs()) //Don't want to do a lot of logic gating here.
		break_handcuffs()
		return

	var/obj/item/weapon/handcuffs/HC = handcuffed

	//A default in case you are somehow handcuffed with something that isn't an obj/item/weapon/handcuffs type
	var/breakouttime = getHumanBreakoutTime(src, 1 MINUTES)
	var/displaytime = 2 //Minutes to display in the "this will take X minutes."
	//If you are handcuffed with actual handcuffs... Well what do I know, maybe someone will want to handcuff you with toilet paper in the future...
	if (istype(HC))
		breakouttime = HC.breakouttime
		displaytime = breakouttime / 600 //Minutes

//	var/mob/living/human/H = src

	visible_message(
		"<span class='danger'>\The [src] attempts to remove \the [HC]!</span>",
		"<span class='warning'>You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)</span>"
		)

	if (do_after(src, breakouttime, incapacitation_flags = INCAPACITATION_DEFAULT & ~INCAPACITATION_RESTRAINED))
		if (!handcuffed || buckled)
			return
		visible_message(
			"<span class='danger'>\The [src] manages to remove \the [handcuffed]!</span>",
			"<span class='notice'>You successfully remove \the [handcuffed].</span>"
			)
		drop_from_inventory(handcuffed)

/mob/living/human/proc/escape_legcuffs()
	if (!canClick())
		return

	setClickCooldown(100)

	if (can_break_cuffs()) //Don't want to do a lot of logic gating here.
		break_legcuffs()
		return

	var/obj/item/weapon/legcuffs/HC = legcuffed

	//A default in case you are somehow legcuffed with something that isn't an obj/item/weapon/legcuffs type
	var/breakouttime = getHumanBreakoutTime(src, 1 MINUTES)
	var/displaytime = 2 //Minutes to display in the "this will take X minutes."
	//If you are legcuffed with actual legcuffs... Well what do I know, maybe someone will want to legcuff you with toilet paper in the future...
	if (istype(HC))
		breakouttime = HC.breakouttime
		displaytime = breakouttime / 600 //Minutes

	visible_message(
		"<span class='danger'>[usr] attempts to remove \the [HC]!</span>",
		"<span class='warning'>You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)</span>"
		)

	if (do_after(src, breakouttime, incapacitation_flags = INCAPACITATION_DEFAULT & ~INCAPACITATION_RESTRAINED))
		if (!legcuffed || buckled)
			return
		visible_message(
			"<span class='danger'>[src] manages to remove \the [legcuffed]!</span>",
			"<span class='notice'>You successfully remove \the [legcuffed].</span>"
			)

		drop_from_inventory(legcuffed)
		legcuffed = null
		update_inv_legcuffed()

/mob/living/human/proc/can_break_cuffs()
	if (ishuman(src))
		var/mob/living/human/H = src
		return H.getStatCoeff("strength") >= 2.3

/mob/living/human/proc/break_handcuffs()
	visible_message(
		"<span class='danger'>[src] is trying to break \the [handcuffed]!</span>",
		"<span class='warning'>You attempt to break your [handcuffed.name]. (This will take around 5 seconds and you need to stand still)</span>"
		)

	if (do_after(src, 5 SECONDS, incapacitation_flags = INCAPACITATION_DEFAULT & ~INCAPACITATION_RESTRAINED))
		if (!handcuffed || buckled)
			return

		visible_message(
			"<span class='danger'>[src] manages to break \the [handcuffed]!</span>",
			"<span class='warning'>You successfully break your [handcuffed.name].</span>"
			)

		say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))

		qdel(handcuffed)
		handcuffed = null
		if (buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()
		update_inv_handcuffed()

/mob/living/human/proc/break_legcuffs()
	src << "<span class='warning'>You attempt to break your legcuffs. (This will take around 5 seconds and you need to stand still)</span>"
	visible_message("<span class='danger'>[src] is trying to break the legcuffs!</span>")

	if (do_after(src, 5 SECONDS, incapacitation_flags = INCAPACITATION_DEFAULT & ~INCAPACITATION_RESTRAINED))
		if (!legcuffed || buckled)
			return

		visible_message(
			"<span class='danger'>[src] manages to break the legcuffs!</span>",
			"<span class='warning'>You successfully break your legcuffs.</span>"
			)

		say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))

		qdel(legcuffed)
		legcuffed = null
		update_inv_legcuffed()

/mob/living/human/escape_buckle()
	if (!buckled) return

	if (!restrained())
		..()
	else
		visible_message(
			"<span class='danger'>[usr] attempts to unbuckle themself!</span>",
			"<span class='warning'>You attempt to unbuckle yourself. (This will take around a minute and you need to stand still)</span>"
			)


		if (do_after(usr, getHumanBreakoutTime(src, 1 MINUTES), incapacitation_flags = INCAPACITATION_DEFAULT & ~(INCAPACITATION_RESTRAINED | INCAPACITATION_BUCKLED_FULLY)))
			if (!buckled)
				return
			visible_message("<span class='danger'>\The [usr] manages to unbuckle themself!</span>",
							"<span class='notice'>You successfully unbuckle yourself.</span>")
			buckled.user_unbuckle_mob(src)
