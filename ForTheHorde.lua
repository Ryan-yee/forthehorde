local _G = getfenv(0);    -- Holds all the values WoW passes to us, like all the stat names
local abs = abs;          
local modName, L = ...;   -- mod name and mod-specific variables (like localization)

ForTheHorde = {};

-- Saved Variables
local gvif_opts,current_opts;

-- Triggers

local triggers = {
  { trigger = GetSpellInfo(90355),  var_name = 'ancient_hysteria',      opt_name = "AncientHysteria",    gv = 'FTH_AH',  default = 1 },
  { trigger = GetSpellInfo(2825),   var_name = 'bloodlust',             opt_name = "Bloodlust",          gv = 'FTH_BL',  default = 1 },
  { trigger = GetSpellInfo(178207), var_name = 'drums_of_fury',         opt_name = "DrumsOfFury",        gv = 'FTH_DOF', default = 1 },
  { trigger = GetSpellInfo(230935), var_name = 'drums_of_the_mountain', opt_name = "DrumsOfTheMountain", gv = 'FTH_DOM', default = 1 },
  { trigger = GetSpellInfo(32182),  var_name = 'heroism',               opt_name = "Heroism",            gv = 'FTH_H',   default = 1 },
  { trigger = GetSpellInfo(80353),  var_name = 'time_warp',             opt_name = "TimeWarp",           gv = 'FTH_TW',  default = 1 },
};

-- Main Options Window
ForTheHorde.gvif = CreateFrame("Frame",modName,InterfaceFrameOptionsPanelContainer);
ForTheHorde.gvif.name = "For The Horde";
ForTheHorde.gvif:SetWidth( 500 );
ForTheHorde.gvif:SetHeight( 500 );

local chkbox_title = ForTheHorde.gvif:CreateFontString( nil, "Overlay", "GameFontNormalSmall" );
chkbox_title:SetHeight(20);
chkbox_title:SetJustifyH( "LEFT" );
chkbox_title:SetText( L["PLAY_SOUND_OPTS"] );
chkbox_title:SetPoint( "TOPLEFT", 10, -10 );

function createOptions( label, name, varName, x, y ) 
  local checkbox = CreateFrame( "CheckButton", name .. "_CheckBox_GlobalName", ForTheHorde.gvif, "InterfaceOptionsCheckButtonTemplate" );

  if ForTheHorde[varName] == 1 then
    checkbox:SetChecked(true);
  end
  getglobal(checkbox:GetName() .. 'Text'):SetText( label );
  checkbox:SetPoint( "TOPLEFT", x, y);
  checkbox:SetScript( "OnClick", 
    function() 
      if ForTheHorde[varName] == nil or ForTheHorde[varName] == 0 then
        ForTheHorde[varName] = 1;
      else
        ForTheHorde[varName] = 0;
      end
    end
  ); 
  return checkbox;
end

-- Register events that we listen for
ForTheHorde.gvif:RegisterEvent("ADDON_LOADED");
ForTheHorde.gvif:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
ForTheHorde.gvif:RegisterEvent("PLAYER_LOGOUT");

function ForTheHorde.gvif:OnEvent( event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 ) 
  if ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
    if ( arg2 ~= nil and arg2 == "SPELL_AURA_APPLIED" and arg13 ~= nil ) then
      for _,trigger_table in ipairs(triggers) do
        if ( arg13 == trigger_table["trigger"] and ForTheHorde['sound_on_' .. trigger_table["var_name"]] == 1 ) then
          PlaySoundFile( "Interface\\AddOns\\ForTheHorde\\bloodlust.mp3" );
        end
      end
    end
  elseif event == "ADDON_LOADED" then
    if arg1 == modName then
      for _,trigger_table in ipairs(triggers) do
        if _G[trigger_table["gv"]] ~= nil then
          ForTheHorde['sound_on_' .. trigger_table["var_name"]] = _G[trigger_table["gv"]];
        else
          ForTheHorde['sound_on_' .. trigger_table["var_name"]] = trigger_table["default"];
        end
      end
      InterfaceOptions_AddCategory(ForTheHorde.gvif);
      local y = -40;
      for _,trigger_table in ipairs(triggers) do
        createOptions( trigger_table["trigger"], trigger_table["opt_name"], "sound_on_" .. trigger_table["var_name"], 10, y );
        y = y - 30;
      end
    end
  elseif event == "PLAYER_LOGOUT" then
    for _,trigger_table in ipairs(triggers) do
      _G[trigger_table["gv"]] = ForTheHorde['sound_on_' .. trigger_table["var_name"]];
    end
  end
end
ForTheHorde.gvif:SetScript("OnEvent",ForTheHorde.gvif.OnEvent);
