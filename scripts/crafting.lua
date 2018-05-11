--
-- Repeatedly click a single location, avoid shift-click, stop if pixel changes
--

dofile("common.inc");

askText = singleLine([[
  Choose window
]]);

local progress = "";

function sws(delay, msg)
  sleepWithStatus(delay, progress .. "\n" .. msg, 0xFFFFFFff);
end

function findImage(img)
  local tol = 500;
  return srFindImage(img .. ".png", tol);
end

function clickPos(pos)
  if (not pos) then
    return false;
  else
    local offset = { 5, 2 };
    srClickMouse(pos[0]+offset[1], pos[1]+offset[2], false, 50, 100, 50);
    lsSleep(90);
    return true;
  end
end

function findAndClick(img)
  return clickPos(findImage(img));
end

function moveMouse()
  local pos = srGetWindowSize();
  srSetMousePos(pos[0] / 2 + math.random(-50, 50), pos[1] / 2 + math.random(-50, 50));
end

function findStep(img)
  local try_prefixes = false;
  if img == "basic_touch" or img == "basic_synth" or img == "standard_touch" or img == "standard_synth" or img == "advanced_touch" then
    try_prefixes = true;
  end
  local pos = false;
  if try_prefixes then
    if not pos then
      pos = findImage("alc_" .. img);
    end
    if not pos then
      pos = findImage("arm_" .. img);
    end
    if not pos then
      pos = findImage("bsm_" .. img);
    end
    if not pos then
      pos = findImage("cul_" .. img);
    end
    if not pos then
      pos = findImage("crp_" .. img);
    end
    if not pos then
      pos = findImage("gsm_" .. img);
    end
    if not pos then
      pos = findImage("ltw_" .. img);
    end
    if not pos then
      pos = findImage("wvr_" .. img);
    end
  else
    pos = findImage(img);
  end
  return pos;
end

function findAndClickStep(img)
  return clickPos(findStep(img));
end

function clickAndWait(img)
  local waits = 0;
  while 1 do
    srReadScreen();
    local pos = findStep(img);
    if pos then
      if findImage("hq_100_percent") and not (img == "careful_synth") and not (img == "careful_synth_2") and not (img == "standard_synth") and not (img == "mend_2") and not (img == "mend") then
        -- If found hq_100_percent, skip all things except careful_synth and finish!
        sws(100, "100 percent progress, skipping " .. img);
      else
        clickPos(pos);
        moveMouse();
        sws(1000, "Clicked " .. img);
      end
      return;
    end
    moveMouse();
    sws(100, "Waiting for " .. img);
    waits = waits + 1;
    if waits == 100 then
      lsPlaySound("InterventionRequired.wav");
    end
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

-- standard options
num_loops = 1;
-- auto options
difficulty = 45;
durability = 40;
quality_start = 0;
quality_max = 1332;
recipe_level = 26;
character_level = 27;
craftsmanship = 168;
control = 164;
cp = 301;


function promptOptions(auto)
  local scale = 1.0;

  local z = 0;
  local is_done = nil;
  local value = nil;
  -- Edit box and text display
  while not is_done do
    -- Make sure we don't lock up with no easy way to escape!
    checkBreak();

    lsPrint(10, 10, z, scale, scale, 0xFFFFFFff, "Choose passes");

    -- lsEditBox needs a key to uniquely name this edit box
    --   let's just use the prompt!
    -- lsEditBox returns two different things (a state and a value)
    local y = 40;

    lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "Passes:");
    is_done, num_loops = lsEditBox("passes", 110, y, z, 50, 30, scale, scale,
                                   0x000000ff, num_loops);
    if not tonumber(num_loops) then
      is_done = nil;
      lsPrint(10, y+18, z+10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
      num_loops = 1;
    end
    y = y + 32;

    lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "CP:");
    local is_done2;
    is_done2, cp = lsEditBox("cp", 110, y, z, 50, 30, scale, scale,
                                   0x000000ff, cp);
    if not tonumber(cp) then
      is_done2 = nil;
      lsPrint(10, y+18, z+10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
      cp = 1;
    end
    if not is_done2 then
      is_done = nil
    end
    y = y + 32;

    if lsButtonText(170, y-32, z, 100, 0xFFFFFFff, "OK") then
      is_done = 1;
    end

    if is_done and (not num_loops) then
      error 'Canceled';
    end

    if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFFFFFFff,
                    "End script") then
      error "Clicked End Script button";
    end

    lsDoFrame();
    lsSleep(tick_delay);
  end
end

function findAndClickHQ(num, is_hq)
  local pos = findImage("hq");
  if (not pos) then
    return false;
  else
    local offset = { 5, 27 + num*46 };
    if not is_hq then
      offset[1] = offset[1] - 50;
    end
    srClickMouse(pos[0]+offset[1], pos[1]+offset[2], false, 50, 100, 50);
    lsSleep(90);
    return true;
  end
end

function doHQ(num, is_hq)
  while 1 do
    srReadScreen();
    if findAndClickHQ(num, is_hq) then
      moveMouse();
      sws(150, "Clicked HQ button");
      return;
    end
    moveMouse();
    sws(100, "Waiting for HQ button");
  end
end

function showState(y, state)
  local z = 0;
  local scale = 1.0;

  lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "Durability:");
  is_done, state.durability = lsEditBox("durability", 110, y, z, 50, 30, scale, scale,
                                 0x000000ff, state.durability);
  lsPrint(165, y, z, 1, 1, 0xFFFFFFff, " / " .. durability);
  if not tonumber(state.durability) then
    lsPrint(10, y+18, z+10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
    state.durability = durability;
  end
  y = y + 32;

  lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "Quality:");
  is_done, state.quality = lsEditBox("quality", 110, y, z, 50, 30, scale, scale,
                                 0x000000ff, "" .. state.quality);
  lsPrint(165, y, z, 1, 1, 0xFFFFFFff, " / " .. quality_max);
  if not tonumber(state.quality) then
    lsPrint(10, y+18, z+10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
    state.quality = quality_start;
  end
  y = y + 32;

  lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "Control:");
  is_done, state.control = lsEditBox("control", 110, y, z, 50, 30, scale, scale,
                                 0x000000ff, state.control);
  lsPrint(165, y, z, 1, 1, 0xFFFFFFff, " / " .. control);
  if not tonumber(state.control) then
    lsPrint(10, y+18, z+10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
    state.control = control;
  end
  y = y + 32;

  lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "CP:");
  is_done, state.cp = lsEditBox("cp", 110, y, z, 50, 30, scale, scale,
                                 0x000000ff, state.cp);
  lsPrint(165, y, z, 1, 1, 0xFFFFFFff, " / " .. cp);
  if not tonumber(state.cp) then
    lsPrint(10, y+18, z+10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER");
    state.cp = cp;
  end
  y = y + 32;

  return y;
end

local debug = "";

function mulFromCondition(condition)
  if condition == "normal" then
    return 1.0;
  elseif condition == "poor" then
    return 0.5;
  elseif condition == "good" then
    return 1.5;
  elseif condition == "excellent" then
    return 4.0;
  end
end

function cloneState(state)
  return {
    durability = state.durability,
    quality = state.quality,
    control = state.control,
    cp = state.cp,
    condition = state.condition
  };
end

function stepQuality(state, efficiency)
  local mul = efficiency * mulFromCondition(state.condition);
  local quality = (0.37 * state.control + 32.6)
    * (1 - 0.05 * math.min(math.max(recipe_level - character_level, 0), 5));
  local newstate = cloneState(state);

  newstate.quality = math.min(newstate.quality + quality, quality_max);
  debug = "dQuality = " .. quality;
  return newstate;
end

function auto()
  local scale = 1.0;
  local z = 0;
  --promptOptions(true);

  --askForWindow(askText);

  local state = {
    durability = durability,
    quality = quality_start,
    control = control,
    cp = cp,
    condition = "normal"
  };

  while true do
    -- Make sure we don't lock up with no easy way to escape!
    checkBreak();

    lsPrint(10, 10, z, scale, scale, 0xFFFFFFff, "Simulator");

    local y = 40;
    if debug then
      lsPrint(10, y, z, scale, scale, 0x7F7F7Fff, debug);
      y = y + 30;
    end

    y = showState(y, state);

    if lsButtonImg(5, y, z, 1, 0xFFFFFFff, "wvr_basic_touch.png") then
      state = stepQuality(state, 1.0);
    end

    if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFFFFFFff,
                    "End script") then
      error "Clicked End Script button";
    end

    lsDoFrame();
    lsSleep(tick_delay);
  end;

end

function gensteps40(cp, num_careful_synth)
  local steps = {
    "inner_quiet",
    "steady_hand_2",
    "manipulation",
  };
  cp = cp - 88 - 18 - 25;
  local left = 7 - num_careful_synth;
  for i=left,1,-1 do
    if (cp / i > 32) then
      steps[#steps+1] = "standard_touch";
      cp = cp - 32;
    else
      steps[#steps+1] = "basic_touch";
      cp = cp - 18
    end
  end
  for i=1,num_careful_synth do
    steps[#steps+1] = "careful_synth_2";
  end

  -- for i=1,#steps do
  --   print(steps[i])
  -- end

  return steps;
end


function gensteps80(cp, num_careful_synth)
  local steps = {
    "inner_quiet",
    "steady_hand_2",
  };
  cp = cp - 18 - 25 - 25 - 160;
  local left = 6 + 8 - num_careful_synth;
  for j=1,2 do
    for i=1,6 do
      if (left > 0 and ((i <= 5) or (j==2))) or (num_careful_synth == 1) then
        if (cp / left > 18) then
          steps[#steps+1] = "basic_touch";
          cp = cp - 18;
        else
          steps[#steps+1] = "hasty_touch";
        end
        left = left - 1;
      else
        steps[#steps+1] = "careful_synth_2";
        num_careful_synth = num_careful_synth - 1;
      end
    end
    if j == 1 then
      steps[#steps+1] = "mend_2";
      steps[#steps+1] = "steady_hand_2";
    end
  end
  for i=1,num_careful_synth do
    steps[#steps+1] = "careful_synth_2";
  end
  return steps;
end

function gensteps70(cp, num_careful_synth)
  local steps = {
    "inner_quiet",
    "steady_hand_2",
  };
  cp = cp - 18 - 25 - 25 - 160;
  local left = 6 + 7 - num_careful_synth;
  for j=1,2 do
    for i=1,6 do
      if (left > 0 and ((i <= 5) or (j==2))) or (num_careful_synth == 1) then
        if (cp / left > 18) then
          steps[#steps+1] = "basic_touch";
          cp = cp - 18;
        else
          steps[#steps+1] = "hasty_touch";
        end
        left = left - 1;
      else
        steps[#steps+1] = "careful_synth_2";
        num_careful_synth = num_careful_synth - 1;
      end
    end
    if j == 1 then
      steps[#steps+1] = "mend_2";
      steps[#steps+1] = "steady_hand_2";
    end
  end
  for i=1,num_careful_synth do
    steps[#steps+1] = "careful_synth_2";
  end
  return steps;
end

function manual()
  local steps = gensteps80(291, 3);
  for i=1,#steps do
    print(steps[i])
  end

  promptOptions(false);

  askForWindow(askText);

  local hq = {
    -- "hq", 2,
    -- "lq", 2,
  };

  local steps = gensteps40(cp, 1);
  --local steps = gensteps70(cp, 1);
  --local steps = gensteps80(cp, 3);

  -- gold nuggets, 3xcareful
  -- local steps = {
  --   "inner_quiet",
  --   "steady_hand",
  --   "innovation",
  --   "manipulation",
  --   "standard_touch",
  --   "standard_touch",
  --   "advanced_touch",
  --   "advanced_touch",
  --   "careful_synth_2",
  --   "careful_synth_2",
  --   "careful_synth_2",
  -- };

  -- 70/80 dur items
  -- local steps = {
  --   "inner_quiet",
  --   "steady_hand_2",
  --   "hasty_touch",
  --   "hasty_touch",
  --   "hasty_touch",
  --   "hasty_touch",
  --   "hasty_touch",
  --   "careful_synth_2",
  --   "mend_2",
  --   "steady_hand_2",
  --   "hasty_touch",
  --   "hasty_touch",
  --   "basic_touch",
  --   "basic_touch",
  --   "basic_touch",
  --   "careful_synth_2",
  --   "careful_synth_2",
  --   "careful_synth_2",
  -- };
  for loop_count=1, num_loops do
    for hq_count=1, #hq, 2 do
      if hq[hq_count] == "hq" then
        doHQ(hq[hq_count+1], true);
      else
        doHQ(hq[hq_count+1], false);
      end
    end
    clickAndWait("synthesize");
    for step_count=1, #steps do
      progress = "Loop " .. loop_count .. " of " .. num_loops
        .. "\nStep " .. step_count .. " of " .. (#steps + 1);
      clickAndWait(steps[step_count]);
    end
    progress = "Loop " .. loop_count .. " of " .. num_loops
      .. "\nFinishing...";

    finishSynth();
  end
  lsPlaySound("Complete.wav");
end

function doit()
  manual();
  --auto();
end
