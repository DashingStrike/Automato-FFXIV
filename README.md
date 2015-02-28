# Automato-FFXIV
Automato scripts for Final Fantasy XIV

This repo contains a crafting autoation scripts for FFXIV which allows for optimal crafting of certain HQ goods.  It is smart enough to stop crafting when it sees that it has reached maximum quality and move on to the next one.  It can be told to use variable amounts of HQ ingredients in order to more seamlessly craft lots of items given your stock on hand, without human intervenion.

To actually gets this running, FFXIV will invariably have changed a lot of their ability icons since this was last used, so the files in images/ would need to be updated to match the current icons.  Even if the icons look the same, FFXIV often just slightly changes them (brightness, highlights, very subtle differences, but enough to mess up the script).

To choose how to craft, edit crafting.lua around [line 462](https://github.com/DashingStrike/Automato-FFXIV/blob/master/scripts/crafting.lua#L462-L506), specify which ingredients need clicks on incrementing "hq" and "lq" (if first ingredient in the recipe requires 2 and you want to use 1 hq item each time until you run out and then use 2 lq items, you'd want to specify clicking twice on lq and once on hq (which does nothing if you have non), so, I think `"lq", 1, "lq", 1, "hq", 1`.  To specify what steps are taken (it's smart enough to skip quality increasing steps if the quality gets maxed, but continue running completion steps), either use one of the `gensteps` functions, depending on how much completion it needs (they assume you have all skills unlocked), or uncomment and edit one of the example steps sequences below it.

Then, fire up FFXIV, enter the crafting screen, select what you want to craft, and start the script running following the on-screen prompts!

