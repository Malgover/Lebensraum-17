/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 */

/*******
* film *
*******/
/obj/item/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = 1.0


/********
* photo *
********/
var/global/photo_count = FALSE

/obj/item/weapon/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = 2.0
	var/id
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back.
	var/icon/tiny
	var/photo_size = 3

/obj/item/weapon/photo/New()
	id = photo_count++

/obj/item/weapon/photo/attack_self(mob/user as mob)
	user.examinate(src)

/obj/item/weapon/photo/attackby(obj/item/weapon/P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/pen))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null)  as text, 128)
		if (loc == user && user.stat == FALSE)
			scribble = txt
	..()

/obj/item/weapon/photo/examine(mob/user)
	if (in_range(user, src))
		show(user)
		user << desc
	else
		user << "<span class='notice'>It is too far away.</span>"

/obj/item/weapon/photo/proc/show(mob/user as mob)
	user << browse_rsc(img, "tmp_photo_[id].png")
	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo_[id].png' width='[64*photo_size]' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=book;size=[64*photo_size]x[scribble ? 400 : 64*photo_size]")
	onclose(user, "[name]")
	return

/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = null
	set src in usr

	var/n_name = sanitizeSafe(input(usr, "What would you like to label the photo?", "Photo Labelling", null)  as text, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if (( (loc == usr || (loc.loc && loc.loc == usr)) && usr.stat == FALSE))
		name = "[(n_name ? text("[n_name]") : "photo")]"
	add_fingerprint(usr)
	return


/**************
* photo album *
**************/
/obj/item/weapon/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_hold = list(/obj/item/weapon/photo)

/obj/item/weapon/storage/photo_album/MouseDrop(obj/over_object as obj)

	if ((istype(usr, /mob/living/carbon/human)))
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		playsound(loc, "rustle", 50, TRUE, -5)
		if ((!( M.restrained() ) && !( M.stat ) && M.back == src))
			switch(over_object.name)
				if ("r_hand")
					M.u_equip(src)
					M.put_in_r_hand(src)
				if ("l_hand")
					M.u_equip(src)
					M.put_in_l_hand(src)
			add_fingerprint(usr)
			return
		if (over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if (usr.s_active)
				usr.s_active.close(usr)
			show_to(usr)
			return
	return

/*********
* camera *
*********/
/obj/item/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "electropack"
	w_class = 2.0
	flags = CONDUCT
	slot_flags = SLOT_BELT
	matter = list(DEFAULT_WALL_MATERIAL = 2000)
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = TRUE
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/size = 3

/obj/item/camera/early
	name = "camera"
	desc = "An early wooden camera. Takes sepia photos."
	icon = 'icons/obj/device1.dmi'
	icon_state = "camera_early"
	pictures_max = 1

/obj/item/camera/earlymodern
	name = "camera"
	desc = "An early 20th century camera. Takes black and white photos."
	icon = 'icons/obj/device1.dmi'
	icon_state = "camera_ww2"
	pictures_max = 5

/obj/item/camera/coldwar
	name = "camera"
	desc = "A late 20th century camera. Takes vintage color photos."
	icon = 'icons/obj/device1.dmi'
	icon_state = "camera_coldwar"
	pictures_max = 8

/obj/item/camera/verb/change_size()
	set name = "Set Photo Focus"
	set category = null
	var/nsize = WWinput(usr, "Pick the size of the resulting photo.", "Photo Size", 1, WWinput_list_or_null(list(1,3,5,7)))
	if (nsize)
		size = nsize
		usr << "<span class='notice'>Camera will now take [size]x[size] photos.</span>"

/obj/item/camera/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/camera/attack_self(mob/user as mob)
	on = !on
	if (on)
		icon_state = icon_on
	else
		icon_state = icon_off
	user << "You switch the camera [on ? "on" : "off"]."
	return

/obj/item/camera/attackby(obj/item/I as obj, mob/user as mob)
	if (istype(I, /obj/item/camera_film))
		if (pictures_left)
			user << "<span class='notice'>[src] still has some film in it!</span>"
			return
		user << "<span class='notice'>You insert [I] into [src].</span>"
		user.drop_item()
		qdel(I)
		pictures_left = pictures_max
		return
	..()


/obj/item/camera/proc/get_mobs(turf/the_turf as turf)
	var/mob_detail
	for (var/mob/living/carbon/A in the_turf)
		if (A.invisibility) continue
		var/holding = null
		if (A.l_hand || A.r_hand)
			if (A.l_hand) holding = "They are holding \a [A.l_hand]"
			if (A.r_hand)
				if (holding)
					holding += " and \a [A.r_hand]"
				else
					holding = "They are holding \a [A.r_hand]"

		if (!mob_detail)
			mob_detail = "You can see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_detail

/obj/item/camera/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (!on || !pictures_left || ismob(target.loc)) return
	captureimage(target, user, flag)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, TRUE, -3)

	pictures_left--
	desc = "A polaroid camera. It has [pictures_left] photos left."
	user << "<span class='notice'>[pictures_left] photos left.</span>"
	icon_state = icon_off
	on = FALSE
	spawn(64)
		icon_state = icon_on
		on = TRUE

//Proc for capturing check
/mob/living/proc/can_capture_turf(turf/T)
	var/mob/dummy = new(T)	//Go go visibility check dummy
	var/viewer = src
	if (client)		//To make shooting through security cameras possible
		viewer = client.eye
	var/can_see = (dummy in viewers(world.view, viewer))

	qdel(dummy)
	return can_see

/obj/item/camera/proc/captureimage(atom/target, mob/living/user, flag)
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y + (size-1)/2
	var/z_c	= target.z
	var/mobs = ""
	for (var/i = TRUE; i <= size; i++)
		for (var/j = TRUE; j <= size; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			if (user.can_capture_turf(T))
				mobs += get_mobs(T)
			x_c++
		y_c--
		x_c = x_c - size

	var/obj/item/weapon/photo/p = createpicture(target, user, mobs, flag)
	printpicture(user, p)

/obj/item/camera/proc/createpicture(atom/target, mob/user, mobs, flag)
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y - (size-1)/2
	var/z_c	= target.z
	var/icon/photoimage = generate_image(x_c, y_c, z_c, size, CAPTURE_MODE_REGULAR, user, FALSE)

	var/icon/small_img = icon(photoimage)
	var/icon/tiny_img = icon(photoimage)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	var/icon/pc = icon('icons/obj/bureaucracy.dmi', "photo")
	small_img.Scale(8, 8)
	tiny_img.Scale(4, 4)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	pc.Blend(tiny_img,ICON_OVERLAY, 12, 19)

	var/obj/item/weapon/photo/p = new()
	p.name = "photo"
	p.icon = ic
	p.tiny = pc
	p.img = photoimage
	p.desc = mobs
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	p.photo_size = size

	return p

/obj/item/camera/proc/printpicture(mob/user, obj/item/weapon/photo/p)
	p.loc = user.loc
	if (!user.get_inactive_hand())
		user.put_in_inactive_hand(p)

/obj/item/weapon/photo/proc/copy(var/copy_id = FALSE)
	var/obj/item/weapon/photo/p = new/obj/item/weapon/photo()

	p.name = name
	p.icon = icon(icon, icon_state)
	p.tiny = icon(tiny)
	p.img = icon(img)
	p.desc = desc
	p.pixel_x = pixel_x
	p.pixel_y = pixel_y
	p.photo_size = photo_size
	p.scribble = scribble

	if (copy_id)
		p.id = id

	return p
