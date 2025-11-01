local obs = obslua

local hotkey_id = obs.OBS_INVALID_HOTKEY_ID
local source_name = "Pop"

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

local function onPress(pressed)
    if pressed then
        playsound()
    end
end

local function on_scene_changed(scene)
    pause_media_source()
end

function script_load(settings)
    -- Register keybind
    hotkey_id = obs.obs_hotkey_register_frontend("popPlayOnKeybind", "Play Pop on keybind", onPress)

    -- Load saved keybind
    local hotkey_save_array = obs.obs_data_get_array(settings, "audioBind.trigger")
    obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)

    -- Pause the media source on script load
    pause_media_source()
    print("Script loaded: Pop sound will play on hotkey press and is paused on load")
    
    -- Register scene change callback
    obs.obs_frontend_add_event_callback(on_scene_changed)
end

function script_save(settings)
    -- Save keybind
    local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
    obs.obs_data_set_array(settings, "audioBind.trigger", hotkey_save_array)
    obs.obs_data_array_release(hotkey_save_array)
end

function script_description()
    return "Play a sound using a hotkey. Ensure a media source named 'Pop' is configured with the desired audio file."
end
