g_fileId = "_TPE"
tpe = tpe or {} -- Tupper Persistent Engine V3

 
 local tpeCallbacks = {}
 local tpe_dir = lfs.writedir() .. [[tpe\]]
 lfs.mkdir(tpe_dir)  -- create directories, should not over-write current.
  
  
-- Set The call back function   
function tpeCallbacks.onMissionLoadBegin()
  net.log('TPE: Callbacks init') 
  tpe.current_mission = DCS.getMissionName()
  tpe.current_map = DCS.getCurrentMission().mission.theatre
  tpe.mission_start_time = DCS.getRealTime()  --needed to prevent CTD caused by C Lua API on net.pause and net.resume
  tpe.mission_started = true

  local tpeFileName = tpe_dir .. [[config.txt]]
  if string.match(tpe.current_mission,  g_fileId ) then
--[[    local tpeFile = io.open(tpeFileName, 'r')
    if tpeFile then
      local fileContent = tpeFile:read('*all')
        tpeFile:close()
        tpeFile = nil
    
    --    tpe.main =  net.json2lua( fileContent )
      --  tpe.main =   fileContent 
         net.log('TPE: Callbac loaded main') 
      --  tpe.loadingUnits = true
   -- else
   --   tpe.main = {}  
      
 --     tpe.tpeScheduleFunction() 
    else]]
      tpeFile = io.open(tpeFileName, 'w')
      local json1 =  net.lua2json( tpe )
      tpeFile:write(json1)    
      tpeFile:close()
  --  end
--    tpe.CreateloadFunction()

    
  end

end  -- Function 
 
 function tpeCallbacks.onSimulationFrame()
 
 
 -- net.log('TPE: On sim Frame')
 end



 
 function checkMissionScripting()
 local fileContent = {}
 local curMSf, err = io.open('./Scripts/MissionScripting.lua', 'r')
 
  if curMSf then
 
      local curMS = curMSf:read('*all')
      curMSf:close()
    local curMSfunc, err = loadstring(curMS)
 
      if curMSfunc then
          if string.match(curMS, "%-%-sanitizeModule%('lfs'%)") then
            net.log( "TPE: Scripting File up to date ")  
          else
            curMS = curMS:gsub("sanitizeModule%('lfs'%)", "%-%-sanitizeModule%('lfs'%)")
            curMS = curMS:gsub("sanitizeModule%('io'%)", "%-%-sanitizeModule%('io'%)")
            net.log('./Scripts/MissionScripting.lua is not up to date.  Installing new ./Scripts/MissionScripting.lua.')
            local newMSf, err = io.open('./Scripts/MissionScripting.lua', 'w')
            if newMSf then
              newMSf:write(curMS)
              newMSf:close()
            end
          end   
      end
  end 
end

 
 net.log('TPE: Before Mission Scripting Update')
 checkMissionScripting()
 
DCS.setUserCallbacks(tpeCallbacks)
net.log('Tupper Persistency Engine Loaded')
net.log('TPE: Callbacks loaded')
 
 
 
 