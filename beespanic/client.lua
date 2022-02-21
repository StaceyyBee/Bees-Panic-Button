local dpad = {l = 47, r= 51, u= 27, d= 19, a= 21, b= 45, y= 23, x= 22, lt = 10, rt = 11, lb = 37, rb = 44, lu = 32, ld = 33, ll = 34, lr = 35, l3 = 36, rl = 5, rr = 6, ru = 3, rd = 4, r3 = 7, start = 199, sel = 0}	--Updated 29/4/20

--	By StaceyBee
--	Version : 1.0.0
--	Created : 21/02/2022
--	info: Simple panic button for testing/bugs.

local panic = {
	use = true,															--<	Use script
	cmd = "panic",														--<	/command to activate 
	b = {																--<	Controller buttons that activate panic button
		use = true, hold = {dpad.lb, dpad.rb}, press = {dpad.a}			--<	Script will see if you are holding "hold" buttons and then see if you are pressing "press" buttons.
	}
}
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if panic.use == true and panic.b.use == true then
			local me = GetPlayerPed(-1)
			local held = {}
			local pressed = {}
			for pp, ho in pairs(panic.b.hold) do
				if IsControlPressed(0, ho) then
					if #held == 0 then
						table.insert(held, ho)
					else
						local found = false
						for ppp, pre in pairs(held) do
							if pre == ho then
								found = true
							end
						end
						if found == false then
							table.insert(held, ho)
						end
					end
				end
				if IsControlReleased(0, ho) then
					if #held > 0 then
						local found = false
						for pppp, pree in pairs(held) do
							if pree == ho then
								found = true
							end
						end
						if found == true then
							table.remove(pressed, pppp)
						end
					end
				end
			end
			if #held == #panic.b.hold then
				for pp1, hoo in pairs(panic.b.press) do
					if IsControlJustPressed(0, hoo) then
						if #pressed == 0 then
							table.insert(pressed, hoo)
						else
							local found = false
							for ppp, pre in pairs(pressed) do
								if pre == hoo then
									found = true
								end
							end
							if found == false then
								table.insert(pressed, hoo)
							end
						end
					end
					if IsControlJustReleased(0, hoo) then
						if #pressed > 0 then
							local found = false
							for pppp2, preee in pairs(pressed) do
								if preee == hoo then
									found = true
								end
							end
							if found == true then
								table.remove(pressed, pp1)
							end
						end
					end
				end
				if #pressed == #panic.b.press then
					TriggerEvent("beepanic")
				end
			end
		end
	end
end)

RegisterCommand(panic.cmd, function()
	TriggerEvent("Panic")
end)

RegisterNetEvent("beepanic")
AddEventHandler("beepanic", function()
	local me = GetPlayerPed(-1)
	local mee = PlayerId()
	local whr = GetEntityCoords(me)
	local var = GetPedPropIndex(me, 9)
	local id = GetEntityModel(me)
	SetPlayerModel(mee, id)
	FreezeEntityPosition(me, false)
	SetEntityAlpha(me, 255, 0)
	SetPedComponentVariation(me, 9, var,0,0)		--tasks
	SetPlayerForcedAim(mee, false)
	DetachEntity(me, 1, 1)
	if IsPedInAnyVehicle(me, false) then
		local veh = GetVehiclePedIsIn(me, false)
		local h = GetEntityHeading(veh)
		SetVehicleFixed(veh)
		FreezeEntityPosition(veh, false)
		SetEntityRotation(veh, 0.0, 0.0, h)
		SetEntityAlpha(veh, 255, 0)
		SetVehicleDoorsLocked(veh, 1)
	end
	if IsPedDeadOrDying(me, 1) then
		local h = GetEntityHeading(me)
		NetworkResurrectLocalPlayer(whr.x, whr.y, whr.z, h, true, true, false)
	end
	if IsEntityAttachedToAnyObject(me) then DetachEntity(me, 1, 1) end
	RenderScriptCams(false, true, 1000, 1, 0)
	DestroyAllCams(1)
	Citizen.InvokeNative(0xD8295AF639FD9CB8, me) 	--SkycamIn
	DoScreenFadeIn(0)
	StopAnimPlayback(me, 0, 0)
	SetGamePaused(0)
	SetPauseMenuActive(1)
	notify("Activated ~r~Panic button.")
end)

function notify(msg)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	DrawNotification(true, false)
end