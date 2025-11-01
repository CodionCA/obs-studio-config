local obs = obslua

local source_name = "ReplaySave"

local function playsound()
    local source = obs.obs_get_source_by_name(source_name)
    if source then
        obs.obs_source_media_restart(source)
        obs.obs_source_release(source)
        print("Playing sound: " .. source_name)
    else
        print("Source not found: " .. source_name)
    end
end

local function pause_media_source()
    local source = obs.obs_get_source_by_name(source_name)
    if source then
        obs.obs_source_media_stop(source)
        obs.obs_source_release(source)
        print("Pausing media source: " .. source_name)
    else
        print("Source not found to pause: " .. source_name)
    end
end

local function on_event(event)
    if event == obs.OBS_FRONTEND_EVENT_REPLAY_BUFFER_SAVED then
        playsound()
    end
end

function script_load(settings)
    obs.obs_frontend_add_event_callback(on_event)
    pause_media_source()
    print("Script loaded: ReplayBufferSound will play on replay buffer save and is paused on load")
end

function script_description()
    return "Play a sound when the replay buffer is saved. Ensure a media source named 'ReplayBufferSound' is configured with the desired audio file."
end
