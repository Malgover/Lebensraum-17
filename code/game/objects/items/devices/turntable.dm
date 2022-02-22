/*
/mob/var/datum/hear_music/hear_music
#define NONE_MUSIC 0
#define UPLOADING 1
#define PLAYING 2

/datum/hear_music
	var/mob/target = null
	//var/sound/sound
	var/status = NONE_MUSIC
	var/stop = 0

	proc/play(sound/S)
		status = NONE_MUSIC
		if(!target)
			return
		if(!S)
			return
		status = UPLOADING
		target << browse_rsc(S)
		//sound = S
		if(target.hear_music != src)
			qdel(src)
		if(!stop)
			target << S
			status = PLAYING
		else
			qdel(src)

	proc/stop()
		if(!target)
			return
		if(status == PLAYING)
			var/sound/S = sound(null)
			S.channel = 10
			S.wait = 1
			target << S
			qdel(src)
		else if(status == UPLOADING)
			stop = 1
		target.hear_music = null

*/
/mob/var/sound/music
///client/var/jukeboxplaying = 0

/datum/data/turntable_soundtrack
	var/f_name
	var/path
	var/length

/datum/data/turntable_soundtrack/New(f_name, name, path, length)
	src.f_name = f_name
	src.name = name
	src.path = path
	src.length = length

/obj/machinery/party/turntable
	name = "Gramophone"
	desc = "A device capable of playing music."
	icon = 'icons/obj/lasers2.dmi'
	icon_state = "gramophone2"
	//var/timer_id = 0
	var/transition = 0
	var/play_song_cost = 0
	var/skip_song_cost = 0
	var/start_time = 0
	var/collected_money = 0
	var/obj/item/weapon/disk/music/disk
	var/playing = 1
	var/datum/data/turntable_soundtrack/track = null
	var/datum/data/turntable_soundtrack/next_track = null
	var/volume = 40
	var/list/mob/melomans = list()
	var/list/turntable_soundtracks = list(

		new /datum/data/turntable_soundtrack ("Margot Bingham",	"Dream a Little Dream of Me",					'sound/turntable/dream.ogg',	1933),
		new /datum/data/turntable_soundtrack ("Jack Hylton",	"When Summer is Gone",					'sound/turntable/summer.ogg',	1933),
		new /datum/data/turntable_soundtrack ("Al Bowlly",	"Heartaches",					'sound/turntable/heartaches.ogg',	1933),
	)
	anchored = 1
	density = 1

/obj/machinery/party/turntable/New()
	..()
	spawn(5)
		turntable_soundtracks = sortSoundtrack(turntable_soundtracks)
/*
	turntable_soundtracks = list()
	for(var/i in subtypesof(/datum/turntable_soundtrack/)
		var/datum/turntable_soundtrack/D = new i()
		if(D.path)
			turntable_soundtracks += D
*/

/obj/machinery/party/turntable/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/disk/music) && !disk)
		user.drop_item()
		O.loc = src
		disk = O
		attack_hand(user)


/obj/machinery/party/turntable/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/party/turntable/attack_hand(mob/living/user as mob)
	if (..())
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	interact(H)

	var/dat
	dat +="<div class='statusDisplay'>"
	dat += "Now playing: <b>[track.f_name] - [track.name]</b>"
	//dat += "Balance: [balance] �.<br>"
	dat += "<br>"
		if(playing)
			dat += "<br><A href='?src\ref[src];turn_off=\ref[src]'>Turn Off</A>"
		else
			dat += "<br><A href='?src\ref[src];turn_on=\ref[src]'>Turn On</A>"
	dat += "<br><A href='?src=\ref[src];skip=\ref[src]'>Skip</A> - <b>[skip_song_cost] RU</b>"
	dat += "<br>Choose next song - <b>[play_song_cost] RU</b>"
	dat += "<br>Volume: <b>[volume]%</b>"
	dat += "</div>"
	dat += "<div class='lenta_scroll'>"
	dat += "<br><BR><table border='0' width='400'>"
	for(var/datum/data/turntable_soundtrack/TS in turntable_soundtracks)
		dat += "<tr><td>[TS.f_name]</td><td>[TS.name]</td><td><A href='?src=\ref[src];order=\ref[TS]'>PLAY</A></td></tr>"
	dat += "</table>"
	dat += "</div>"

/obj/machinery/party/turntable/power_change()
	return
	//turn_off()

/obj/machinery/party/turntable/Topic(href, href_list)
	if(..())
		return

	var/mob/living/carbon/human/H = usr

	if(href_list["change_volume"])
		set_volume(input("Choose new volume.", "Turntable", src.volume) as num)
		return

	if(href_list["order"])
		var/datum/data/turntable_soundtrack/TS = locate(href_list["order"])

		if(!playing)
			say("Jukebox is turned off.")
			return

		if(next_track)
			say("Next song is already picked: [next_track.f_name] - [next_track.name]")
			return

		if(alert("Do you want to play [TS.name] next for [play_song_cost] RU?", "Turntable", "Yes", "No") == "No")
			return

		if(transition)
			return

		if (!TS)
			updateUsrDialog()
			return

		//deltimer(timer_id)
		//skip_song(TS)
		next_track = TS
		say("Playing next: [next_track.f_name] - [next_track.name]")

	if(href_list["skip"])

		if(!playing)
			say("Jukebox is turned off.")
			return

		//if(next_track)
		//	say("You can't skip picked song.")
		//	return

		if(alert("Skip [track.name] for [skip_song_cost]?", "Turntable", "Yes", "No") == "No")
			return

		//deltimer(timer_id)
		skip_song(next_track)

	if(href_list["set_volume"])
		set_volume(text2num(href_list["set_volume"]))
		return

	if(href_list["turn_off"])
		turn_off()
		return

	if(href_list["turn_on"])
		turn_on()
		return
/*
	if(href_list["eject"])
		if(disk)
			disk.loc = src.loc
			if(disk.data && track == disk.data)
				turn_off()
				track = null
			disk = null
		return
*/
/obj/machinery/party/turntable/process()
	if(playing)
		update_sound()

/obj/machinery/party/turntable/proc/skip_song(var/datum/data/turntable_soundtrack/TS = pick(turntable_soundtracks - track))
	next_track = null
	var/area/A = get_area(src)
	transition = 1
	for(var/client/C in melomans)
		if(!C || !(C.mob))
			continue

		if(!playing || !(get_area(C.mob) in A.related))
			continue

		C.mob.music.status = SOUND_STREAM
		C.mob.music.file = null
		C.mob << C.mob.music
		sleep(0)
		C.mob.music.status = SOUND_STREAM
		C.mob.music.file = 'sound/effects/radio_noise.ogg'
		C.mob.music.volume = volume
		C.mob << C.mob.music
	sleep(40)
	transition = 0
	//timer_id = addtimer(src, "skip_song", TS.length - 10)
	track = TS
	say("Now playing: [track.f_name] - [track.name]")
	start_time = world.timeofday
	//update_sound()

/obj/machinery/party/turntable/proc/turn_on(var/datum/data/turntable_soundtrack/selected)
	if(playing)
		return

	playing = 1

	if(selected)
		skip_song(selected)
	else
		skip_song()

	//MusicSwitch()
	var/area/A = get_area(src)
	for(var/area/RA in A.related)
		for(var/obj/machinery/party/lasermachine/L in RA)
			L.turnon(L.dir)

/obj/machinery/party/turntable/proc/turn_off()
	if(!playing)
		return

	//deltimer(timer_id)
	//timer_id = 0

	for(var/client/C in melomans)
		//C.jukeboxplaying = 0
		if(C.mob)
			C.mob << sound(null, channel = TURNTABLE_CHANNEL, wait = 0)
		melomans.Remove(C)

	playing = 0

	var/area/A = get_area(src)
	for(var/area/RA in A.related)
		for(var/obj/machinery/party/gramophone/L in RA)
			L.turnoff()

/obj/machinery/party/turntable/proc/set_volume(var/new_volume)
	volume = max(0, min(100, new_volume))
	//if(playing)
	//	update_sound()

/obj/machinery/party/turntable/proc/update_sound()
	if(transition)
		return

	var/area/A = get_area(src)

	if(!track || (start_time + track.length < world.timeofday + SSobj.wait))
		skip_song()

	for(var/client/C in clients)

		if(!C || !C.mob)
			continue

		if(!(get_area(C.mob) in A.related))
			continue

		//if(!C.mob.client.jukeboxplaying)
		if(!(C.mob.client in melomans))
			//create_sound(C.mob)
			//C.mob.music.volume = volume
			//C.mob << C.mob.music
			//C.jukeboxplaying = 1
			melomans.Add(C)

	for (var/client/C in melomans)
		//var/inRange = (get_area(C.mob) in A.related)

		if(!C)
			melomans -= C
			continue

		if(!(C.mob))
			C << sound(null, channel = TURNTABLE_CHANNEL, wait = 0)
			melomans.Remove(C)
			continue

		if(!playing || !(get_area(C.mob) in A.related))
			if(C.mob.music)
				C.mob.music.status = SOUND_STREAM | SOUND_UPDATE
				C.mob.music.volume = 0
				C.mob << C.mob.music
				C.mob.music.status = SOUND_STREAM
			else
				C.mob << sound(null, channel = TURNTABLE_CHANNEL, wait = 0)
			//C.jukeboxplaying = 0
			melomans.Remove(C)
			continue

		if(!C.mob.music)
			create_sound(C.mob)
			continue

		if(!C.mob.music.transition && C.mob.music.file != track.path)
			C.mob.music.file = track.path
			//C.mob.music.status = SOUND_STREAM
		else
			C.mob.music.status = SOUND_STREAM | SOUND_UPDATE

		C.mob.music.volume = volume
		C.mob << C.mob.music
		C.mob.music.status = SOUND_STREAM

/obj/machinery/party/turntable/proc/create_sound(mob/M)
	if(!M.music || M.music.file != track.path)
		var/sound/S = sound(track.path)
		S.repeat = 0
		S.channel = TURNTABLE_CHANNEL
		S.falloff = 2
		S.wait = 0
		S.volume = 0
		S.status = SOUND_STREAM //SOUND_STREAM
		S.environment = get_area(src).environment
		M.music = S
		M << S
	else
		M.music.status = SOUND_STREAM | SOUND_UPDATE
		M.music.volume = volume
		M << M.music
		M.music.status = SOUND_STREAM


