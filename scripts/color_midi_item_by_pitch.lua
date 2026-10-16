-- color_midi_item_by_pitch.lua
--
-- @about
--   # color_midi_item_by_pitch.lua
--
--   This script colors MIDI items based on their pitch bend value.
--   The color changes from default, to orange/red for positive pitch bends, and to light blue/blue for negative pitch bends.
--
--   This is useful for preventing accidentally using MIDI items that have been pitch-bent, and spending time trying to figure out why they sound different.
-- @description color_midi_item_by_pitch.lua
-- @link
--   GitHub Repository https://github.com/sevenc-nanashi/reaper-scripts
-- @version 0.1.0
-- @author Nanashi. <sevenc7c.com>

local function get_color(pitch)
  if math.abs(pitch) < 0.001 then
    return 0
  end

  local amount = math.min(math.abs(pitch) / 12, 1)

  local r, g, b

  if pitch > 0 then
    r = 235
    g = math.floor(175 - amount * 100)
    b = 75
  else
    r = math.floor(85 - amount * 25)
    g = math.floor(185 - amount * 85)
    b = 225
  end

  return reaper.ColorToNative(r, g, b) | 0x1000000
end

local last_state = -1

local function update()
  local count = reaper.CountMediaItems(0)
  local changed = false

  for i = 0, count - 1 do
    local item = reaper.GetMediaItem(0, i)
    local take = reaper.GetActiveTake(item)

    if take and reaper.TakeIsMIDI(take) then
      local pitch = reaper.GetMediaItemTakeInfo_Value(
        take, "D_PITCH"
      )

      local color = get_color(pitch)
      local current = reaper.GetMediaItemInfo_Value(
        item, "I_CUSTOMCOLOR"
      )

      if current ~= color then
        reaper.SetMediaItemInfo_Value(
          item, "I_CUSTOMCOLOR", color
        )
        changed = true
      end
    end
  end

  if changed then
    reaper.UpdateArrange()
  end
end

local function main()
  local state = reaper.GetProjectStateChangeCount(0)

  if state ~= last_state then
    update()
    last_state = reaper.GetProjectStateChangeCount(0)
  end

  reaper.defer(main)
end

main()
