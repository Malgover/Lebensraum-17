/obj/structure/lattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/structures.dmi'
	icon_state = "latticefull"
	density = FALSE
	anchored = 1.0
	w_class = 3
	layer = 2.3 //under pipes
	//	flags = CONDUCT

/obj/structure/lattice/initialize()
	..()
///// Z-Level Stuff
	if (!(istype(loc, /turf/space) || istype(loc, /turf/open) || istype(loc, /turf/floor/hull))) // || istype(loc, /turf/floor/open)
///// Z-Level Stuff
		qdel(src)
	for (var/obj/structure/lattice/LAT in loc)
		if (LAT != src)
			qdel(LAT)
	icon = 'icons/obj/smoothlattice.dmi'
	icon_state = "latticeblank"
	updateOverlays()
	for (var/dir in cardinal)
		var/obj/structure/lattice/L
		if (locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays()

/obj/structure/lattice/Destroy()
	for (var/dir in cardinal)
		var/obj/structure/lattice/L
		if (locate(/obj/structure/lattice, get_step(src, dir)))
			L = locate(/obj/structure/lattice, get_step(src, dir))
			L.updateOverlays(loc)
	..()

/obj/structure/lattice/ex_act(severity)
	switch(severity)
		if (1.0)
			qdel(src)
			return
		if (2.0)
			qdel(src)
			return
		if (3.0)
			return
		else
	return

/obj/structure/lattice/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/tile/floor))
		var/turf/T = get_turf(src)
		T.attackby(C, user) //BubbleWrap - hand this off to the underlying turf instead
		return
	if (istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = C
		if (WT.remove_fuel(0, user))
			user << "<span class='notice'>Slicing lattice joints ...</span>"
		PoolOrNew(/obj/item/stack/rods, loc)
		qdel(src)
	if (istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if (R.amount <= 2)
			return
		else
			R.use(2)
			user << "<span class='notice'>You start connecting [R.name] to [name] ...</span>"
			if (do_after(user,50))
				alpha = FALSE
				new /obj/structure/catwalk(loc)
				qdel(src)
			return
	return

/obj/structure/lattice/proc/updateOverlays()
	//if (!(istype(loc, /turf/space)))
	//	qdel(src)
	spawn(1)
		overlays = list()

		var/dir_sum = FALSE

		var/turf/T
		for (var/direction in cardinal)
			T = get_step(src, direction)
			if (locate(/obj/structure/lattice, T) || locate(/obj/structure/catwalk, T))
				dir_sum += direction
			else if (!istype(T, /turf/space) && !istype(T, /turf/open))
				dir_sum += direction

		icon_state = "lattice[dir_sum]"
		return
