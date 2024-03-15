/obj/item/weapon/grenade/flashbang
	name = "светошумовая граната"
	icon_state = "flashbang"
	item_state = "grenade"
	armsound = 'lambda/sanecman/sound/grenade/generic_checkout_2.ogg'
	var/banglet = 0

	prime()
		..()
		for(var/obj/structure/closet/L in hear(7, get_turf(src)))
			if(locate(/mob/living/human/, L))
				for(var/mob/living/human/M in L)
					bang(get_turf(src), M)


		for(var/mob/living/human/M in hear(7, get_turf(src)))
			bang(get_turf(src), M)

		new/obj/effect/sparks(src.loc)
		new/obj/effect/effect/smoke/illumination(loc, brightness=15)
		qdel(src)
		return

	proc/bang(var/turf/T , var/mob/living/human/M)					// Added a new proc called 'bang' that takes a location and a person to be banged.
		M << "<span class='danger'>БА-БАХ!</span>"					// Called during the loop that bangs people in lockers/containers and when banging
		playsound(src.loc, 'sound/effects/bang.ogg', 50, 1, 30)		// people in normal view.  Could theroetically be called during other explosions.
																	// -- Polymorph

//Checking for protections
		var/eye_safety = 0
		var/ear_safety = 0
		if(ishuman(M))
			eye_safety = M.eyecheck()
			if(ishuman(M))
				if(istype(M:l_ear, /obj/item/clothing/ears/earmuffs) || istype(M:r_ear, /obj/item/clothing/ears/earmuffs))
					ear_safety += 2
				if(istype(M:head, /obj/item/clothing/head/helmet))
					ear_safety += 1

//Flashing everyone
		if (eye_safety < FLASH_PROTECTION_MODERATE)
			if (M.HUDtech.Find("flash"))
				flick("e_flash", M.HUDtech["flash"])
			M.Stun(2)
			M.Weaken(10)

//Now applying sound
		if ((get_dist(M, T) <= 2 || loc == M.loc || loc == M))
			if (ear_safety > 0)
				M.Stun(2)
				M.Weaken(1)
			else
				M.Stun(10)
				M.Weaken(3)
				if ((prob(14) || (M == loc && prob(70))))
					M.ear_damage += rand(1, 10)
				else
					M.ear_damage += rand(0, 5)
					M.ear_deaf = max(M.ear_deaf,15)

		else if (get_dist(M, T) <= 5)
			if (!ear_safety)
				M.Stun(8)
				M.ear_damage += rand(0, 3)
				M.ear_deaf = max(M.ear_deaf,10)

		else if (!ear_safety)
			M.Stun(4)
			M.ear_damage += rand(0, TRUE)
			M.ear_deaf = max(M.ear_deaf,5)

//This really should be in mob not every check
		if (ishuman(M))
			var/mob/living/human/H = M
			var/obj/item/organ/eyes/E = H.internal_organs_by_name["eyes"]
			if (E && E.damage >= E.min_bruised_damage)
				M << "<span class='danger'>Глаза горят!</span>"
				if (!banglet)
					if (E.damage >= E.min_broken_damage)
						M << "<span class='danger'>Ничего не вижу!</span>"
		if (M.ear_damage >= 15)
			M << "<span class='danger'>Я ослеп!</span>"
			if (!banglet)
				if (prob(M.ear_damage - 10 + 5))
					M << "<span class='danger'>Ничего не слышу!</span>"
					M.sdisabilities |= DEAF
		else
			if (M.ear_damage >= 5)
				M << "<span class='danger'>В ушах звенит!</span>"
		M.update_icons()

/obj/item/weapon/grenade/flashbang/m84
	name = "M84 светошумовая граната"
	icon_state = "flashbang"

/obj/item/weapon/grenade/flashbang/galaxywars
	name = "светозвуковая граната"
	icon_state = "sflashbang"
	armsound = 'lambda/sanecman/sound/grenade/td_checkout.ogg'