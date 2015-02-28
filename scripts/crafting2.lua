--
-- Repeatedly click a single location, avoid shift-click, stop if pixel changes
--

dofile("common.inc");

askText = singleLine([[
  Choose window
]]);

local progress = "";

function sws(delay, msg)
  sleepWithStatus(delay, progress .. "\n" .. msg, 0xFFFFFFff, true);
end

function findImage(img)
  local tol = 100;
  return srFindImage(img .. ".png", tol);
end

function findAndClick(img)
  local pos = findImage(img);
  if (not pos) then
    return false;
  else
    local offset = { 5, 2 };
    srClickMouse(pos[0]+offset[1], pos[1]+offset[2], false, 50, 100, 50);
    lsSleep(90);
    return true;
  end
end

function moveMouse()
  local pos = srGetWindowSize();
  srSetMousePos(pos[0] / 2 + math.random(-50, 50), pos[1] / 2 + math.random(-50, 50));
end

function findAndClickStep(img)
  local try_prefixes = false;
  if img == "basic_touch" or img == "basic_synth" or img == "standard_touch" then
    try_prefixes = true;
  end
  local click_res = false;
  if try_prefixes then
    if not click_res then
      click_res = findAndClick("alc_" .. img);
    end
    if not click_res then
      click_res = findAndClick("arm_" .. img);
    end
    if not click_res then
      click_res = findAndClick("bsm_" .. img);
    end
    if not click_res then
      click_res = findAndClick("crp_" .. img);
    end
    if not click_res then
      click_res = findAndClick("gsm_" .. img);
    end
    if not click_res then
      click_res = findAndClick("ltw_" .. img);
    end
    if not click_res then
      click_res = findAndClick("wvr_" .. img);
    end
  else
    click_res = findAndClick(img);
  end
  return click_res;
end

function clickAndWait(img)
  while 1 do
    srReadScreen();
    if findAndClickStep(img) then
      moveMouse();
      sws(1000, "Clicked " .. img);
      return;
    end
    moveMouse();
    sws(100, "Waiting for " .. img);
  end
end

function finishSynth()
  while 1 do
    srReadScreen();

    local pos = findImage("synthesize");
    if (not pos) then
      if findAndClickStep("basic_synth") then
        moveMouse();
        sws(100, "Clicked basic_synth");
      else
        sws(100, "Waiting for basic_synth or synthesize");
      end
    else
      sws(200, "Done synthesizing");
      return;
    end

    moveMouse();
  end
end

local num_loops = 1;
local hq = {
  0,
  0,
  0,
  0,
};
local steps = {
  "steady_hand",
  "manipulation",
  "basic_touch",
  "basic_touch",
  "basic_touch",
  "basic_touch",
  "steady_hand",
  "basic_touch",
  --"basic_touch",
};


function promptOptions()
  local scale = 1.0;

  local z = 0;
  local is_done = false;
  local value = nil;

  local screen_scale = 25/16.0;
  z = 1;
  tip = "";

  while not is_done do
    lsSetCamera(0, 0, lsScreenX*screen_scale, lsScreenY*screen_scale);
    local maxX = lsScreenX*screen_scale;
    local maxY = lsScreenY*screen_scale;


    -- Make sure we don't lock up with no easy way to escape!
    checkBreak();

    lsPrint(10, 10, z, scale, scale, 0xFFFFFFff, "Crafting Setup");

    -- lsEditBox needs a key to uniquely name this edit box
    --   let's just use the prompt!
    -- lsEditBox returns two different things (a state and a value)
    local y = 40;

    local val_ok;
    is_done = true;

    lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "Passes:");
    val_ok, num_loops = lsEditBox("passes", 110, y, z, 50, 30, scale, scale,
                                   0x000000ff, num_loops);
    if not val_ok then
      is_done = false;
    elseif not tonumber(num_loops) then
      is_done = false;
      lsPrint(10, y+18, z+10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
      num_loops = 1;
    end
    y = y + 32;

    lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "HQ:");
    for hq_count=1, #hq do
      local color = 0xFFFFFFff;
      if hq[hq_count] > 0 then
        color = 0xFF0000ff;
      end
      if lsButtonText(30 + hq_count * 20, y, z, 18, color, hq[hq_count]) then
        hq[hq_count] = (hq[hq_count] + 1) % 3;
      end
    end
    y = y + 32;

    for step_count=1, #steps do
      lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "Step " .. step_count .. ":");
      if lsButtonText(90, y, z, 200, 0xFFFFFFff, steps[step_count]) then
        -- ,...
      end
      y = y + 32;
    end

    if lsButtonText(5, y, z, 100, 0xFFFFFFff, "OK") then
      is_done = 1;
    end

    if is_done and (not num_loops) then
      error 'Canceled';
    end

    if lsButtonText(maxX - 110, maxY - 30, z, 100, 0xFFFFFFff,
                    "End script") then
      error "Clicked End Script button";
    end

    lsDoFrame();
    lsSleep(tick_delay);
  end
  lsSetCamera(0, 0, lsScreenX, lsScreenY);
end

function findAndClickHQ(num)
  local pos = findImage("hq");
  if (not pos) then
    return false;
  else
    local offset = { 5, 27 + num*46 };
    srClickMouse(pos[0]+offset[1], pos[1]+offset[2], false, 50, 100, 50);
    lsSleep(90);
    return true;
  end
end

function doHQ(num)
  while 1 do
    srReadScreen();
    if findAndClickHQ(num) then
      moveMouse();
      sws(150, "Clicked HQ button");
      return;
    end
    moveMouse();
    sws(100, "Waiting for HQ button");
  end
end

function doit()
  promptOptions();

  askForWindow(askText);

  -- need standard_touch for: see other doc

  for loop_count=1, num_loops do
    for hq_count=1, #hq do
      if hq[hq_count] > 0 then
        for i=1, hq[hq_count] do
          doHQ(hq_count - 1);
        end
      end
    end
    clickAndWait("synthesize");
    for step_count=1, #steps do
      progress = "Loop " .. loop_count .. " of " .. num_loops
        .. "\nStep " .. step_count .. " of " .. (#steps + 1);
      clickAndWait(steps[step_count]);


      -- TODO: merge: If found hq_100_percent, skip all things except careful_touch and finish!
    end
    progress = "Loop " .. loop_count .. " of " .. num_loops
      .. "\nFinishing...";

    finishSynth();
  end
end
