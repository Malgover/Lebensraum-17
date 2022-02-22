/obj/structure/TV
	name = "television"
	desc = "A television for watching broadcasted programmes. Its switched off."
	icon = 'icons/obj/modern_structures.dmi'
	icon_state = "TV"
	anchored = TRUE
	var/destroyed = FALSE
	var/active = FALSE
	density = TRUE
	var/health = 100
	var/maxhealth = 100

	var/protection_chance = 85 //odds of something hitting the TV

/obj/structure/TV/active //no television channels... yet.
	icon_state = "TV_wn"
	desc = "A television for watching broadcasted programmes. Its switched on."
	active = TRUE

/obj/structure/TV/active/examine(var/mob/living/L)
	L << "There is nothing on television at the moment except static. Typical."
	return

/* Clocks*/

/obj/structure/TV/grandfather
	name = "grandfather clock"
	desc = "A tall wooden grandfather clock. The clock hands & pendulum move frequently as time slips by."
	icon = 'icons/obj/modern_structures.dmi'
	icon_state = "grandfather_clock_a"
	anchored = TRUE
	destroyed = FALSE
	active = TRUE
	density = TRUE
	health = 100
	maxhealth = 100
	protection_chance = 85

/obj/structure/TV/grandfather/inactive
	icon_state = "grandfather_clock"
	desc = "A tall wooden grandfather clock. The clock hands & pendulum have frozen in place, inert."
	active = FALSE

/obj/structure/TV/grandfather/inactive/examine(var/mob/living/L) //it would be fun to have nukes set clocks inactive or halt at a time.
	L << "This clock's stopped running, you can't tell what time it is currently."
	return

/obj/structure/TV/television //in prep for actually interesting and watchable tv's
	name = "television"
	icon = 'icons/obj/modern_structures.dmi'
	icon_state = "TV"
	anchored = TRUE
	destroyed = FALSE
	active = FALSE
	density = TRUE
	health = 100
	maxhealth = 100

	protection_chance = 85

/obj/structure/TV/television/active
	icon_state = "TV_wn"
	desc = "A television for watching broadcasted programmes. Its switched on."
	active = TRUE

/obj/structure/TV/television/active/examine(var/mob/living/L)
	L << "There is nothing on television at the moment except static. Typical."
	return

/* TV Technical*/

/obj/structure/TV/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (istype(mover, /obj/item/projectile))
		return prob(100-protection_chance)
	else
		return FALSE

/obj/structure/TV/bullet_act(var/obj/item/projectile/proj)
	health -= proj.damage/3
	visible_message("<span class='warning'>\The [src] is hit by the [proj.name]!</span>")
	try_destroy()

/obj/structure/TV/fire_act(temperature)
	if (prob(35 * (temperature/500)))
		visible_message("<span class = 'warning'>[src] is damaged by the fire and breaks apart!.</span>")
		qdel(src)

/obj/structure/TV/attackby(obj/item/W as obj, mob/user as mob)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	switch(W.damtype)
		if ("fire")
			health -= W.force * TRUE
		if ("brute")
			health -= W.force * 0.20
	playsound(get_turf(src), 'sound/weapons/smash.ogg', 100)
	user.do_attack_animation(src)
	try_destroy()
	..()

/obj/structure/TV/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (istype(mover, /obj/item/projectile))
		return prob(100-protection_chance)
	else
		return FALSE

/obj/structure/TV/bullet_act(var/obj/item/projectile/proj)
	health -= proj.damage/3
	visible_message("<span class='warning'>\The [src] is hit by the [proj.name]!</span>")
	try_destroy()

/obj/structure/TV/proc/try_destroy()
	if (health <= 0)
		visible_message("<span class='danger'>[src] is broken into pieces!</span>")
		qdel(src)
		return



