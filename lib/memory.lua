
local garbage_collector_total_cycle_count = 0       -- how many times have we run garbage collection manually?
local garbage_collector_total_cycle_time = 0        -- how much total time have we spent running garbage collection
local garbage_collector_average_cycle_time = 0      -- what's the average time it takes to run gc manually?

function run_garbage_collector_cycle()
    local time, result = fprofile(collectgarbage, "collect")

    -- re-calc average gc timing
    garbage_collector_total_cycle_count = garbage_collector_total_cycle_count + 1
    garbage_collector_total_cycle_time = garbage_collector_total_cycle_time + time
    garbage_collector_average_cycle_time = garbage_collector_total_cycle_time / garbage_collector_total_cycle_count
end

--
-- |frame_start_time| should be a number which is a timestamp of when the current frame started.
--
-- |min_fps| should be a number which is the target minimum fps for the game/application (defaults to 60)
--
-- |get_current_time_f| should be a function which when called with no arguments returns you the current time.
-- it should be the same function you used to retrieve the value for |frame_start_time|
function check_if_can_collect_garbage_for_free(frame_start_time, min_fps, get_current_time_f)
    -- often this will be polled at the end of a frame to see if we're running fast or slow,
    -- and if we have some time to kill before the start of the next frame, we could maybe run gc.
    if (get_current_time_f() - frame_start_time) < (1 / (min_fps or 60) + garbage_collector_average_cycle_time) then
        run_garbage_collector_cycle()
    end
end

