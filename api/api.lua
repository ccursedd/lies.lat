local mevreanim = {
	services = {
		players = game:GetService("Players");
		workspace = game:GetService("Workspace");
		replicated = game:GetService("ReplicatedStorage");
		run_service = game:GetService("RunService");
		user_input_service = game:GetService("UserInputService");
		http_service = game:GetService("HttpService");
	};
	flags = {
		reanimated = false;
	};
	clones = {};
	connections = {
		hb = nil;
		died = nil;
		real_char_child_removed = nil;
		character_removing = nil;
		clone_died = nil;
		clone_char_child_removed = nil;
		animation_hb = nil;
		animation_presim = nil;
	};
	real_chars = {};
	callbacks = {
		on_play = nil,
		on_stop = nil,
	},
	animation = {
		cache = {};
		state = {
			is_playing = false;
			current_url = nil;
			speed = 1.0;
			keyframes = nil;
			total_duration = 0;
			elapsed_time = 0;
		};
		pending_c0s = {};
		original_motor_c0s = {};
		joints = {};
		animator = nil;
	};
};

local API = {};

local get_game_ragdoll_info = function(enable)
	local place_id = game.PlaceId;
	if place_id == 15546218972 or place_id == 6884319169 then
		local remote = mevreanim.services.replicated:WaitForChild("event_rag");
		return remote, {"Ball"}, false;
	elseif place_id == 5991163185 then
		local remote = mevreanim.services.replicated.Remotes.Physics.Ragdoll;
		return remote, {}, false;
	elseif place_id == 5683833663 then
		local local_event = mevreanim.services.replicated:WaitForChild("LocalRagdollEvent");
		return local_event, {enable}, true;
	end;
	return nil, nil, false;
end;

local set_model_transparency = function(model, transparency)
	if not model then return end;
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Transparency = transparency;
		end;
	end;
end;

local get_local_player = function()
	local player = mevreanim.services.players.LocalPlayer;
	if not player then
		return "bad argument to 'get_local_player' (LocalPlayer not found; must run in a LocalScript)";
	end;
	return player;
end;

local get_char = function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return ("bad argument #1 to 'get_char' (Player expected, got %s)"):format(typeof(player));
	end;
	local character = player.Character;
	if not character or not character.Parent then
		return ("Player %s has no active character."):format(player.Name);
	end;
	return character;
end;

local clone_char = function(model)
	if typeof(model) ~= "Instance" then
		return ("bad argument #1 to 'clone_char' (Instance expected, got %s)"):format(typeof(model));
	end;
	model.Archivable = true;
	local new_clone = model:Clone();
	model.Archivable = false;
	new_clone.Name = "Reanimation";
	new_clone.Parent = mevreanim.services.workspace;
	new_clone:WaitForChild("Animate").Disabled = true;
	new_clone.Humanoid.RequiresNeck = false;
	new_clone.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
	if new_clone:FindFirstChildWhichIsA("ForceField") then
		new_clone:FindFirstChildWhichIsA("ForceField"):Destroy();
	end;
	return new_clone;
end;

local fire_remote = function(remote, is_local, ...)
	if typeof(remote) ~= "Instance" then
		return ("bad argument to 'fire_remote' (Instance expected, got %s)"):format(typeof(remote));
	end;
	if is_local then
		if not remote:IsA("BindableEvent") then
			return ("bad argument to 'fire_remote' (BindableEvent expected for local event, got %s)"):format(remote.ClassName);
		end;
		remote:Fire(...);
	else
		if not (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
			return ("bad argument to 'fire_remote' (RemoteEvent or RemoteFunction expected, got %s)"):format(remote.ClassName);
		end;
		if remote:IsA("RemoteEvent") then
			remote:FireServer(...);
		else
			remote:InvokeServer(...);
		end;
	end;
end;

-- stop_animation
API.stop_animation = function()
	if not mevreanim.animation.state.is_playing then return end;

	local stopped_url = mevreanim.animation.state.current_url;

	if mevreanim.connections.animation_hb then
		mevreanim.connections.animation_hb:Disconnect();
		mevreanim.connections.animation_hb = nil;
	end

	if mevreanim.connections.animation_presim then
		mevreanim.connections.animation_presim:Disconnect();
		mevreanim.connections.animation_presim = nil;
	end

	-- restore original C0s
	local anim = mevreanim.animation;
	for motor, orig_c0 in pairs(anim.original_motor_c0s) do
		if motor and motor.Parent then
			motor.C0 = orig_c0;
		end;
	end;

	local player = get_local_player();
	if typeof(player) ~= "string" then
		local clone = API.get_clone(player);
		if clone then
			local s = clone:FindFirstChild("Animate");
			if s then s.Enabled = true end;
		end;
	end;

	table.clear(anim.pending_c0s);
	table.clear(anim.original_motor_c0s);
	table.clear(anim.joints);
	anim.animator = nil;
	anim.state = {
		is_playing = false;
		current_url = nil;
		speed = 1.0;
		keyframes = nil;
		total_duration = 0;
		elapsed_time = 0;
	};

	if mevreanim.callbacks.on_stop then
		pcall(mevreanim.callbacks.on_stop, stopped_url);
	end;
end;

-- play_animation
-- The keyframe Data CFrames are ABSOLUTE C0 values (not relative offsets),
-- so we write them directly to motor.C0 — but we do the actual write inside
-- PreSimulation so it runs after Roblox's animator resets things each frame.
API.play_animation = function(url, speed)
	if not mevreanim.flags.reanimated then
		return "Cannot play animation, not reanimated.";
	end;

	local player = get_local_player();
	if typeof(player) == "string" then return player end;

	local clone = API.get_clone(player);
	if not clone then
		return "Cannot play animation, clone character not found.";
	end;

	if mevreanim.animation.state.is_playing and mevreanim.animation.state.current_url == url then
		API.stop_animation();
		return;
	end;

	API.stop_animation();

	local clone_humanoid = clone:FindFirstChildOfClass("Humanoid");
	local clone_anim_controller = clone_humanoid or clone:FindFirstChildOfClass("AnimationController");
	if clone_anim_controller then
		for _, track in ipairs(clone_anim_controller:GetPlayingAnimationTracks()) do
			track:Stop();
		end;
	end;
	local clone_animate_script = clone:FindFirstChild("Animate");
	if clone_animate_script then
		clone_animate_script.Enabled = false;
	end;

	local anim = mevreanim.animation;
	anim.state.speed = tonumber(speed) or 1.0;

	-- fetch + cache
	local keyframe_data = anim.cache[url];
	if not keyframe_data then
		local ok, response = pcall(game.HttpGet, game, url);
		if not ok then return "Animation Error: Failed to fetch URL." end;

		local loaded_fn, err = loadstring(response);
		if not loaded_fn then return "Animation Error: Invalid script from URL. " .. tostring(err) end;

		local ok2, data = pcall(loaded_fn);
		if not ok2 then return "Animation Error: Script from URL failed to execute. " .. tostring(data) end;

		if typeof(data) ~= "table" then return "Animation Error: Script from URL did not return a table." end;
		keyframe_data = data;
		anim.cache[url] = keyframe_data;
	end;

	local keyframes = keyframe_data[next(keyframe_data)];
	if not keyframes or #keyframes == 0 then
		return "No keyframes array found for animation URL: " .. url;
	end;

	-- index Motor6Ds by Part1 name
	table.clear(anim.joints);
	table.clear(anim.original_motor_c0s);
	table.clear(anim.pending_c0s);

	for _, desc in ipairs(clone:GetDescendants()) do
		if desc:IsA("Motor6D") and desc.Part1 then
			anim.joints[desc.Part1.Name] = desc;
			anim.original_motor_c0s[desc] = desc.C0;
		end;
	end;

	local animator = clone_humanoid and clone_humanoid:FindFirstChildOfClass("Animator");
	anim.animator = animator;

	anim.state.keyframes = keyframes;
	anim.state.is_playing = true;
	anim.state.current_url = url;
	anim.state.total_duration = keyframes[#keyframes].Time;
	anim.state.elapsed_time = 0;

	if anim.state.total_duration <= 0 then
		API.stop_animation();
		return;
	end;

	if mevreanim.callbacks.on_play then
		pcall(mevreanim.callbacks.on_play, anim.state.current_url);
	end;

	-- Heartbeat: advance time + interpolate -> write target C0s into pending_c0s table
	mevreanim.connections.animation_hb = mevreanim.services.run_service.Heartbeat:Connect(function(dt)
		if not anim.state.is_playing then return end;

		anim.state.elapsed_time = (anim.state.elapsed_time + dt * anim.state.speed) % anim.state.total_duration;

		local cur, nxt;
		for i = 1, #anim.state.keyframes - 1 do
			if anim.state.elapsed_time >= anim.state.keyframes[i].Time
				and anim.state.elapsed_time < anim.state.keyframes[i + 1].Time then
				cur = anim.state.keyframes[i];
				nxt = anim.state.keyframes[i + 1];
				break;
			end;
		end;
		if not cur then
			cur = anim.state.keyframes[#anim.state.keyframes];
			nxt = anim.state.keyframes[1];
		end;

		local frame_dur = nxt.Time - cur.Time;
		if frame_dur <= 0 then frame_dur = anim.state.total_duration end;
		local alpha = math.clamp((anim.state.elapsed_time - cur.Time) / frame_dur, 0, 1);

		for partName, pose_cf in pairs(cur.Data) do
			local motor = anim.joints[partName];
			if motor then
				local nxt_cf = nxt.Data and nxt.Data[partName];
				if nxt_cf then
					anim.pending_c0s[motor] = pose_cf:Lerp(nxt_cf, alpha);
				else
					anim.pending_c0s[motor] = pose_cf;
				end;
			end;
		end;
	end);

	-- PreSimulation: apply the interpolated C0s after the animator runs
	mevreanim.connections.animation_presim = mevreanim.services.run_service.PreSimulation:Connect(function()
		if not anim.state.is_playing then return end;
		if anim.animator and anim.animator.EvaluationThrottled then return end;

		for motor, c0 in pairs(anim.pending_c0s) do
			if motor and motor.Parent then
				motor.C0 = c0;
			end;
		end;
	end);
end;

-- remaining API
API.set_animation_speed = function(speed)
	mevreanim.animation.state.speed = tonumber(speed) or 1.0;
end;

API.on_animation_play = function(callback)
	if type(callback) == "function" then mevreanim.callbacks.on_play = callback end;
end;

API.on_animation_stop = function(callback)
	if type(callback) == "function" then mevreanim.callbacks.on_stop = callback end;
end;

API.is_animation_playing = function()
	return mevreanim.animation.state.is_playing, mevreanim.animation.state.current_url;
end;

API.is_reanimated = function()
	return mevreanim.flags.reanimated;
end;

API.get_clone = function(player)
	player = player or get_local_player();
	if typeof(player) == "string" then return nil end;
	return mevreanim.clones[player];
end;

API.get_real_character = function(player)
	player = player or get_local_player();
	if typeof(player) == "string" then return nil end;
	return mevreanim.real_chars[player];
end;

API.reanimate = function(bool, remote, args)
	if bool ~= true and bool ~= false then
		return ("bad argument #1 to 'reanimate' (boolean expected, got %s)"):format(typeof(bool));
	end;
	local player = get_local_player();
	if typeof(player) == "string" then return player end;

	local is_local_event = false;
	if not remote then
		local game_remote, game_args, is_local = get_game_ragdoll_info(bool);
		if game_remote then
			remote = game_remote;
			args = game_args;
			is_local_event = is_local;
		end;
	end;

	if bool then
		if mevreanim.flags.reanimated then return "Already reanimated." end;
		local real_char = get_char(player);
		if typeof(real_char) == "string" then return real_char end;
		if not real_char:FindFirstChild("Humanoid") then
			return "Real character is missing a Humanoid.";
		end;
		local real_hrp = real_char:FindFirstChild("HumanoidRootPart");
		if not real_hrp then
			return "Real character is missing a HumanoidRootPart, cannot reanimate.";
		end;
		mevreanim.real_chars[player] = real_char;
		local cloned_char = clone_char(real_char);
		if typeof(cloned_char) == "string" then return cloned_char end;
		if not cloned_char:FindFirstChild("Humanoid") then
			return "Cloned character failed to create or is missing a Humanoid.";
		end;
		mevreanim.clones[player] = cloned_char;
		set_model_transparency(cloned_char, 1);
		local player_gui = player:FindFirstChildWhichIsA("PlayerGui");
		if player_gui then
			for _, gui in player_gui:GetChildren() do
				if gui:IsA("ScreenGui") and gui.ResetOnSpawn then gui.ResetOnSpawn = false end;
			end;
		end;
		player.Character = cloned_char;
		cloned_char:WaitForChild("Animate").Disabled = true;
		cloned_char:WaitForChild("Animate").Disabled = false;
		if player_gui then
			for _, gui in player_gui:GetChildren() do
				if gui:IsA("ScreenGui") and not gui.ResetOnSpawn then gui.ResetOnSpawn = true end;
			end;
		end;
		mevreanim.connections.hb = mevreanim.services.run_service.Heartbeat:Connect(function()
			if not real_char or not real_char.Parent or not cloned_char or not cloned_char.Parent then
				API.reanimate(false, remote, args);
				return;
			end;
			for _, p in real_char:GetChildren() do
				local clone_part = cloned_char:FindFirstChild(p.Name);
				if p:IsA("BasePart") and clone_part then
					p.CFrame = clone_part.CFrame;
					p.Velocity = Vector3.new();
				end;
			end;
		end);
		local real_humanoid = real_char.Humanoid;
		local cloned_humanoid = cloned_char.Humanoid;
		mevreanim.connections.died = real_humanoid.Died:Connect(function()
			API.reanimate(false, remote, args);
		end);
		mevreanim.connections.real_char_child_removed = real_char.ChildRemoved:Connect(function(child)
			if child == real_humanoid or child == real_hrp then
				API.reanimate(false, remote, args);
			end;
		end);
		mevreanim.connections.clone_char_child_removed = cloned_char.ChildRemoved:Connect(function(child)
			if child == cloned_humanoid then API.reanimate(false, remote, args) end;
		end);
		mevreanim.connections.clone_died = cloned_humanoid.Died:Connect(function()
			local cur_hum = real_char and real_char:FindFirstChild("Humanoid");
			if cur_hum and cur_hum.Health > 0 then
				cur_hum.Health = 0;
			else
				API.reanimate(false, remote, args);
			end;
		end);
		mevreanim.connections.character_removing = player.CharacterRemoving:Connect(function(char)
			if char == cloned_char or char == real_char then
				API.reanimate(false, remote, args);
			end;
		end);
		if remote then
			local err = fire_remote(remote, is_local_event, unpack(args or {}));
			if err then return err end;
		end;
		mevreanim.flags.reanimated = true;
	else
		if not mevreanim.flags.reanimated then return end;
		API.stop_animation();
		if remote then
			local err = fire_remote(remote, is_local_event, unpack(args or {}));
			if err then return err end;
		end;
		for key, connection in pairs(mevreanim.connections) do
			if connection then
				connection:Disconnect();
				mevreanim.connections[key] = nil;
			end;
		end;
		local cloned_char = mevreanim.clones[player];
		if cloned_char and cloned_char.Parent then
			cloned_char:Destroy();
			mevreanim.clones[player] = nil;
		end;
		local real_char = mevreanim.real_chars[player];
		if real_char and real_char.Parent then
			set_model_transparency(real_char, 0);
			local hrp = real_char:FindFirstChild("HumanoidRootPart");
			if hrp then hrp.Transparency = 1 end;
			local player_gui = player:FindFirstChildWhichIsA("PlayerGui");
			if player_gui then
				for _, gui in player_gui:GetChildren() do
					if gui:IsA("ScreenGui") and gui.ResetOnSpawn then gui.ResetOnSpawn = false end;
				end;
			end;
			player.Character = real_char;
			if player_gui then
				for _, gui in player_gui:GetChildren() do
					if gui:IsA("ScreenGui") and not gui.ResetOnSpawn then gui.ResetOnSpawn = true end;
				end;
			end;
		end;
		mevreanim.flags.reanimated = false;
	end;
end;

return API;
