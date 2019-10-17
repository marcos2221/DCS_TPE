 tpe = tpe or {}
 
 local tpe_dir = lfs.writedir() .. [[tpe\]]
 local tpeConfigFileName = tpe_dir .. [[config.txt]]
 local tpeFileName 
 
 JSON = (loadfile "JSON.lua")() -- one-time load of the routines



function tpe.getDistance(_point1, _point2)

    local xUnit = _point1.x
    local yUnit = _point1.z
    local xZone = _point2.x
    local yZone = _point2.z

    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end
function tpe.initialLoad()
 local tpeFile = io.open(tpeFileName, 'r')
  if tpeFile then
        local fileContent = tpeFile:read('*all')
        tpeFile:close()
        tpeFile = nil
        if fileContent ~= nil then
        
          tpe.main = JSON:decode(fileContent) -- decoded
          trigger.action.outText( "Loaded Json file"  , 5)
             tpe.spawnCrates(tpe.main.crates)
               trigger.action.outText( "Crates Loaded", 5)
             tpe.spawnGroups(tpe.main.Groups)
              trigger.action.outText( "Groups Loaded", 5)
             tpe.spawnTroops(tpe.main.Troops)
              trigger.action.outText( "Troops Loaded" , 5)    
             tpe.SpawnFobsJson(tpe.main.Fobs)
              trigger.action.outText( "FOB Loaded"  , 5)
             tpe.spawnCsar(tpe.main.Csar)
        else
          trigger.action.outText( "File Content Invalid or empty"  , 5)
          tpe.main = {}
          tpe.main.Groups = {} 
        end   
  else
  trigger.action.outText( "New File will Be created", 5)
  tpe.main = {}
  tpe.main.Groups = {}
  end 
end


function tpe.saveJson()
  trigger.action.outText( "DEBUG: Saving" , 2)
 timer.scheduleFunction( tpe.saveJson, nil, timer.getTime() + 60)
 local jsonTable = {}
  jsonTable.Groups = {}  

  jsonTable.crates = {}
  jsonTable.Troops = {}
  jsonTable.Fobs = {}
  jsonTable.Csar = {}
  jsonTable.Marks = {}
  jsonTable.Groups  = tpe.GetGroupsjson(jsonTable)

  tpe.main.Groups = jsonTable.Groups 
  
  --jsonTable.Statics  = tpe.GetStaticsjson(jsonTable)

  jsonTable.crates = tpe.GetCratesjson(jsonTable)
  jsonTable.Troops = tpe.GetTroopsJson(jsonTable)
  jsonTable.Fobs   = tpe.GetFobsJson()
  jsonTable.Csar   =  tpe.getCsarPilots()
  jsonTable.Marks   = tpe.getmapmarks()

 
  local raw_json_text    = JSON:encode(jsonTable)   
  local tpeFile = io.open(tpeFileName, 'w')
  tpeFile:write(raw_json_text)    
  tpeFile:close()
  trigger.action.outText( "DEBUG: Saved", 2)
end

function tpe.GetCratesjson(jsonTable)

local cratePos = 1
local _crates = {}
local _allCrates
local _weight
local _point
local coordinate3
local _country 
local _coalition
--Blue crates only for now

_allCrates = ctld.spawnedCratesBLUE

for key, value in pairs(ctld.spawnedCratesRED) do
  
  _allCrates[key] = value

end

local _crate 

for _crateName, _details in pairs(_allCrates) do
      
        --get crate
        _crate = ctld.getCrateObject(_crateName)
        
        --in air seems buggy with crates so if in air is true, get the height above ground and the speed magnitude
        if _crate ~= nil and _crate:getLife() > 0
                and (ctld.inAir(_crate) == false) then
            jsonTable.crates[cratePos] = {}
             local _weight =  tostring(_crate:getCargoWeight())
            local _point = _crate:getPoint()
                _point = _crate:getPoint()
            jsonTable.crates[cratePos].point = {["x"] = tostring(_point.x), ["y"] = tostring(_point.y), ["z"] = tostring(_point.z)}     
            
            coordinate3 =  tpe.get_coordinates(_point)
            jsonTable.crates[cratePos].coordinates = coordinate3
            jsonTable.crates[cratePos].weight = tostring( _weight )
            _country = tostring(_crate:getCountry())
             jsonTable.crates[cratePos].country = _country
             _coalition = tostring(_crate:getCoalition())
             jsonTable.crates[cratePos].coalition = _coalition
             cratePos = cratePos + 1
        end
    end
 return jsonTable.crates

end
function tpe.get_coordinates(_point)
 local lat, lon = coord.LOtoLL( _point )
 
 return tostring(lat) .. ", " .. tostring(lon)
 
end
function tpe.GetTroopsJson(jsonTable)

  local groupList = {}
  local i = 1
  
  local droppedTroops = {}
  for key, value in pairs( ctld.droppedTroopsBLUE ) do
    
    droppedTroops[value] = value
  end
  for key, value in pairs( ctld.droppedTroopsRED ) do
    
    droppedTroops[value] = value
  end
  for key, value in pairs( droppedTroops ) do
      local groupalive
      local groupTroops = Group.getByName(value)
      local group2 = Group.getByName(value)
      if groupTroops ~= nil then
          local _unit = group2:getUnit(1)
       
          if _unit ~= nil then
            groupalive  =  _unit:isActive()
          else
            groupalive = false    
          --  trigger.action.outText( "DEBUG: unactive unit " .. value  .."\n", 10)
          end
      else
        groupalive = false
--         trigger.action.outText( "DEBUG: unactive group " .. value  .."\n", 15)
      end
      if groupalive == true then
            groupList[i] = {}
            groupList[i].name = value
            groupList[i].vec3 =  group2:getUnit(1):getPoint() 
            if (  group2:getCoalition() == 2 ) then
              groupList[i].side = "blue"
            else
              groupList[i].side = "red"
            end 
            local units = groupTroops:getUnits()
                  local troops = {}
                  troops.aa = 0
                  troops.inf = 0
                  troops.mg = 0
                  troops.at = 0
                  troops.mortar = 0
                  troops.jtac = 0
                  
             for DCSUnitId, DCSUnit in pairs(  groupTroops:getUnits() ) do
                  local DCSUnitName = DCSUnit:getTypeName() -- DCSUnit:getName()
--                  trigger.action.outText( "DEBUG: Unit Name " .. DCSUnit:getTypeName()  .."\n", 15)
                  if string.match(DCSUnitName, "Stinger manpad") or string.match(DCSUnitName, "SA-18 Igla manpad") then
                    troops.aa = troops.aa + 1
                  end 
                  if string.match(DCSUnitName, "Soldier M4") or string.match(DCSUnitName, "Soldier AK") then
                    troops.inf = troops.inf + 1
                  end 
                  if string.match(DCSUnitName, "Soldier M249")  then
                    if string.match(value, "JTAC") then
                      troops.jtac = troops.jtac + 1
                    else
                      troops.mg = troops.mg + 1
                    end
                  end 
                  if string.match(DCSUnitName, "Paratrooper RPG")  then
                    troops.at = troops.at + 1
                  end 
                  if string.match(DCSUnitName, "2B11 mortar")  then
                    troops.mortar = troops.mortar + 1
                  end 
             end
              groupList[i].units = troops
              i = i +1
        end
  end


  return groupList;
end

function tpe.getCsarPilots()
  local i = 1
  local _csarList = {}
  for _groupName, _value in pairs(csar.woundedGroups) do
    
     local _csarGroup = Group.getByName(_groupName)
    _csarList[i] = {}
    
    _csarList[i].coalition = _value.side
    _csarList[i].country  = _csarGroup:getUnit(1):getCountry() 
    _csarList[i].pos      = _csarGroup:getUnit(1):getPoint()
    _csarList[i].coordinates = tpe.get_coordinates(_csarList[i].pos)  --COORDINATE:NewFromVec3(_csarList[i].pos):ToStringLLDMS() 
    _csarList[i].typename = _value.typename
    _csarList[i].unitname = _value.originalUnit
    _csarList[i].playername = _value.player
    _csarList[i].freq       = _value.frequency
     i = i +1
  
  end
  return _csarList
end

function tpe.spawnCsar(_csarTable)

  for key, _csar in pairs (_csarTable) do
    local _pos1 = _csar.pos
    
    _pos1.x = _pos1.x -50
    _pos1.z = _pos1.z -50
    csar.addCsar(_csar.coalition , _csar.country, _csar.pos, _csar.typename, _csar.unitname, _csar.playername, _csar.freq)

    csar.removeADFFrequency( _csar.freq )
  end
end

function tpe.spawnCrates(cratesTable)
 local _country
 local _point 
 local _weight
 local _side
 
 for key, crate in pairs(cratesTable) do
     _point = {["x"] = tonumber(crate.point.x), ["y"] = 0, ["z"] = tonumber(crate.point.z)}        
     _weight = crate.weight
     _side = tonumber(crate.coalition) 
      _country = tonumber(crate.country)
      ctld.spawnCrateFromFile(_country, _point, _weight,_side)
 end

end

function tpe.spawnGroups(jsoGroups)

 
  for key, _group in pairs(jsoGroups) do
    if _group.alive == true then
      
     local _path = {}
     local _id = mist.getNextGroupId()
     
     if string.match(string.upper(_group.country), "AGGRESSORS") then 
        _group.country = "AGGRESSORS"
     end
   
      local _newgroup = {
          ["visible"] = false,
          ["groupId"] = _id,
          ["hidden"] = _group.hidden,
          ["units"] = {},
          ["name"] = _group.name,
          ["task"] = {},
          ["country"] = _group.country,
          ["category"] = _group.category,
      }
      
      for key2, _unitData in pairs( _group.units ) do
          local _unitid = mist.getNextUnitId();
          local _newUnit = {
                    ["y"] = _unitData.y,
                    ["x"] = _unitData.x,
                    ["type"] = _unitData.type,
                    ["name"] = _unitData.name , --"Spawned " .. tostring(_unitid), -- Don't remember why i changed it for this before
                    ["unitId"] = _unitid,
                    ["heading"] = _unitData.heading,
                    ["playerCanDrive"] = _unitData.playerCanDrive,
                    --              ["alt"] = _altitude.p.y,
                    --              ["alt_type"] =  groupData.units[2].alt_type, --
                    --              ["speed"] = groupData.units[2].speed,
                    ["skill"] = _unitData.skill,
          }
          if _group.payloads ~= nil then
            if _group.payloads[key2] ~= nil then
                  _newUnit.payload = _group.payloads[key2]
            end
          end
          _newgroup.units[key2] = _newUnit  
   
      end 
         
      if _group.waypoints ~= nil then
      --Add waypoints
        local prevDistance = nil
        local prevKey
        local checkDistance = true 
        local point1 = {x = _newgroup.units[1].x, y = 0, z = _newgroup.units[1].y}
        
        for key3, waypoint in pairs(_group.waypoints) do
          local point2 = {x = waypoint.x, y = 0, z = waypoint.y}
          
          
          if checkDistance == true then
            local _distance = tpe.getDistance(point1, point2)
            if prevDistance == nil then
                prevDistance = _distance
                prevKey = key3
            else
              
              if _distance  < prevDistance then  
                  prevDistance = _distance
                  prevKey = key3
               else
                  if string.match(_group.name, "onroad") then
                    table.insert(_path, mist.ground.buildWP(point1, 'On Road', 10))
                    local point2a = {x = _group.waypoints[prevKey].x, y = 0, z = _group.waypoints[prevKey].y}
                    table.insert(_path, mist.ground.buildWP(point2a, 'On Road', 10))  
                    table.insert(_path, mist.ground.buildWP(point2, 'On Road', 10))    
                    
                  
                  else
                    table.insert(_path, mist.ground.buildWP(point1, 'Off Road', 10))
                    local point2a = {x = _group.waypoints[prevKey].x, y = 0, z = _group.waypoints[prevKey].y}
                    table.insert(_path, mist.ground.buildWP(point2a, 'Off Road', 10))  
                    table.insert(_path, mist.ground.buildWP(point2, 'Off Road', 10))    
                                             
                  end
                   checkDistance = false
               end
            end
          else
           if string.match(_group.name, "onroad") then
              table.insert(_path, mist.ground.buildWP(point2, 'On Road', 10))
           else
              table.insert(_path, mist.ground.buildWP(point2, 'Off Road', 10))
           end
          end
        end
        if _path[1] == nil and _group.waypoints[2] ~= nil then
        --
           if string.match(_group.name, "onroad") then
            table.insert(_path, mist.ground.buildWP(point1, 'On Road', 10))
            local point2a = {x = _group.waypoints[prevKey].x, y = 0, z = _group.waypoints[prevKey].y}
            table.insert(_path, mist.ground.buildWP(point2a, 'On Road', 10))  
          else
            table.insert(_path, mist.ground.buildWP(point1, 'Off Road', 10))
            local point2a = {x = _group.waypoints[prevKey].x, y = 0, z = _group.waypoints[prevKey].y}
            table.insert(_path, mist.ground.buildWP(point2a, 'Off Road', 10))  
                                     
          end
        --
        end
        
      end
     
      local _spawnedGroup = Group.getByName(mist.dynAdd(_newgroup).name)
      --Jtac logic
      
      if string.match(_newgroup.name, "Hummer") then
                 local _code = table.remove(ctld.jtacGeneratedLaserCodes, 1)
                 table.insert(ctld.jtacGeneratedLaserCodes, _code)
                 ctld.JTACAutoLase(_newgroup.name, _code) --(_jtacGroupName, _laserCode, _smoke, _lock, _colour)
      end
      
      if _path[1] ~= nil then
          local _mission = {
                id = 'Mission',
                params = {
                    route = {
                        points =_path
                    },
                },
            }
       
        timer.scheduleFunction(function(_arg)
              local _grp = _arg[1]
      
              if _grp ~= nil then
                  local _controller = _grp:getController();
                  _controller:setTask(_arg[2])
              end
          end
              , {_spawnedGroup, _mission}, timer.getTime() + 0.2)
      
      
       end
   
    else
      -- Check is the group is active -- 
      if tpe.checkGroupAlive(_group.name) then
      -- KILL IT!! it was saved as status dead in las run
        local _group = Group.getByName(_group.name)
        _group:destroy()
      end
    end  
  end



end

function tpe.spawnStatics(jsonStatics)

  --local _id = mist.getNextGroupId()
  for key, _static in pairs(jsonStatics) do
    if _static.alive == true then
      
     
     local _id = mist.getNextGroupId()
   
      local _newStatic = {
        ["country"] = _static.country,
        ["heading"] = _static.heading,
        --["groupId"] = _id,
        ["shape_name"] = _static.shape_name,
        ["type"] = _static.type,
    --    ["unitId"] = 3,
        ["rate"] = _static.rate,
        ["name"] = _static.name,
        ["category"] = _static.category,
        ["y"] = _static.y,
        ["x"] = _static.x,
        ["dead"] = _static.dead,
        ["mass"] = _static.mass,
        ["cancargo"] = _static.cancargo,
        ["livery_id"] = _static.livery_id, 
        
      }
      mist.dynAddStatic(_newStatic)

    else
      -- Check is the group is active -- 
      if tpe.checkstaticAlive(_static.name) then
      -- KILL IT!! it was saved as status dead in las run
        local _Static2destroy =  StaticObject.getByName(_static.name)
        _Static2destroy:destroy()
      end
    end  
  end



end

function tpe.checkGroupAlive(_groupname)

  local _group = Group.getByName(_groupname)
  
  if _group ~= nil then
    local _unit = _group:getUnit(1)
    if _unit ~= nil then
      return _unit:isActive()
    else
      return false    
    end
  else
    return false
  end

end

function tpe.checkstaticAlive(_staticname)

  local _StaticObject = StaticObject.getByName(_staticname)
  
  if _StaticObject ~= nil then
    if _StaticObject:isExist() then
        return true
    else
      return false    
    end
  else
    return false
  end

end

function tpe.spawnTroops(jsonTroops)
  for key, troops in pairs (jsonTroops) do
      local vec3 = troops.vec3
      ctld.spawnGroupAtPoint(troops.side, troops.units ,vec3, 1)

  end
end

function tpe.GetGroupsjson(jsonTable)
   
  local _allGroups = coalition.getGroups(2,  Group.Category.GROUND)
  local _allrGroups = coalition.getGroups(1,  Group.Category.GROUND)
  
  for key, value in pairs( _allrGroups ) do
    table.insert(_allGroups, value)
  end
  
  local itemPos = 1
  local vec2
  local coordinate2 
  
  for key , _group in pairs (_allGroups) do     
 --load json table for saving
    local _groupname = _group:getName() 
    if string.match(_groupname, "PM_") and not string.match(_groupname, "Player") then
      local groupData = mist.getGroupData(_groupname)
      local _unit1 = _group:getUnit(1)
      local _alive = false
      if _unit1 ~= nil then
        if _unit1:isActive() then
          _alive = true
        end
      end
        
      if _alive then
        local _group = {}
        _group.name = _groupname
        _group.alive = true
        _group.hidden = groupData.hidden
        _group.country = groupData.country
        _group.category = groupData.category
        _group.payloads = mist.getGroupPayload(_groupname) -- Mostly for planes but wondering if AA also uses this
        _group.waypoints = mist.getGroupPoints(_groupname )
--      _group.task  = groupData.task
        _group.units = {}
        local _unitPos = 1
        for key, unitData in pairs( groupData.units ) do
          local _unit = Unit.getByName(unitData.unitName)
          if _unit ~= nil then
            local _position =  _unit:getPosition()
            local _heading = mist.getHeading( _unit )
            _group.units[_unitPos] = {}
            _group.units[_unitPos].y = _position.p.z
            _group.units[_unitPos].x = _position.p.x
            _group.units[_unitPos].type = unitData.type
            _group.units[_unitPos].name = unitData.unitName 
            _group.units[_unitPos].heading = _heading
            _group.units[_unitPos].playerCanDrive = unitData.playerCanDrive
            _unitPos = _unitPos + 1
          end
        end
        jsonTable.Groups[itemPos] = _group
        itemPos = itemPos + 1
      end
    end
  end 
  
-- Check All Initial units
  for key, _group in pairs (tpe.main.Groups) do
    --check is not already in JSONtable.units
    if _group.alive == true then
      local _found = false
      for key2, _group2 in pairs (jsonTable.Groups) do
        if _group.name == _group2.name then
          _found = true
          break
        end
      end
      
      if _found == false then
        _group.alive = false
        _group.units = {}
         table.insert(jsonTable.Groups, _group)
      end  
    else
         table.insert(jsonTable.Groups, _group)
    end  
  end
  
  return jsonTable.Groups
end

function tpe.GetStaticsjson(jsonTable)
   
  local _allStatics = coalition.getStaticObjects(2)
  local _allrStatics = coalition.getStaticObjects(1)
  
  for key, value in pairs( _allrStatics ) do
    table.insert(_allStatics, value)
  end
  
  local itemPos = 1
  local vec2
  local coordinate2 
  
  for key , _Static in pairs (_allStatics) do     
 --load json table for saving
    local _Staticname = _Static:getName() 
    if string.match(_Staticname, "PM_") then
   --   local groupData = mist.getGroupData(_groupname)
--      local _unit1 = _group:getUnit(1)
      local _dead = false
      if _Static:getLife() < 1 then
        _dead = true
      end
              
      
        local _jsonStatic = {}
        _jsonStatic.name = _Static:getName() 
        _jsonStatic.country = _Static:getCountry()
        _jsonStatic.heading = mist.getHeading(_Static, true)
      --  _jsonStatic.shape_name = _Static.shape_name
        _jsonStatic.type    = _Static:getTypeName() 
        --_jsonStatic.rate    = _Static.rate 
        _jsonStatic.category = _Static:getCategory()
        _jsonStatic.y     = _Static:getPosition().p.z
        _jsonStatic.x    = _Static:getPosition().p.x
        _jsonStatic.dead = _dead
--[[        if _Static:getCargoWeight() ~= nil then
          _jsonStatic.mass = _Static:getCargoWeight()
          _jsonStatic.cancargo = true
        else
            _jsonStatic.cancargo = false
            _jsonStatic.mass = nil
        end
        ]]--
     --   _jsonStatic.livery_id =
        
      
        jsonTable.Statics[itemPos] = _jsonStatic
        itemPos = itemPos + 1
      
    end
  end 
  
  return jsonTable.Statics
end


function tpe.GetFobsJson()
   local _fobs = {}
   local i = 1
    for _, _fobName in ipairs(ctld.builtFOBS) do

        local _fob = StaticObject.getByName(_fobName)

        if _fob ~= nil and _fob:isExist() and _fob:getLife() > 0 then
            _fobs[i] = {}
           _fobs[i].name = _fobName
           _fobs[i].point = _fob:getPosition().p --vec3
           _fobs[i].country = _fob:getCountry()
           
           _fobs[i].coordinates = tpe.get_coordinates(_fobs[i].point )
           i = i + 1
        end
    end
  return _fobs
  
end

function tpe.SpawnFobsJson(jsonFobs)

for key, fob in pairs (jsonFobs) do
  local vec3 = {x=tonumber(fob.point.x), y= tonumber(fob.point.y), z= tonumber(fob.point.z) } 
  
     --
     ctld.spawnFOB(fob.country, "", vec3, fob.name)
     --ctld.spawnFOB(fob.country, "", {x=-160770.734375, y= 33.108024597168, z= 458072.96875 }, fob.name)
     --make it able to deploy crates
     
     local _fob = StaticObject.getByName(fob.name)
     ctld.fobnames[fob.name] = false
     table.insert(ctld.logisticUnits, _fob:getName())
     ctld.beaconCount = ctld.beaconCount + 1
     
     local _radioBeaconName = "FOB " .. fob.name .. " Beacon #" .. ctld.beaconCount
                                                      -- _point, _coalition, _country, _name, _batteryTime, _isFOB)
     local _radioBeaconDetails = ctld.createRadioBeacon(vec3, _fob:getCoalition(), fob.country, _radioBeaconName, nil, true)
     ctld.fobBeacons[fob.name] = { vhf = _radioBeaconDetails.vhf, uhf = _radioBeaconDetails.uhf, fm = _radioBeaconDetails.fm }
     if ctld.troopPickupAtFOB == true then
       table.insert(ctld.builtFOBS, _fob:getName())
       trigger.action.outTextForCoalition(_fob:getCoalition(), "Finished building FOB! Crates and Troops can now be picked up.", 10)
     else
       trigger.action.outTextForCoalition(_fob:getCoalition(), "Finished building FOB! Crates can now be picked up.", 10)
     end
  end
end

function tpe.getmapmarks()

    local f10marks = world.getMarkPanels( )
  
    for key, _mark in pairs (f10marks) do
      

--[[   idx = idxMark(IDMark),
   time = Time,
   initiator = Unit,
   coalition = -1 (or RED/BLUE),
   groupID = -1 (or ID),
   text = markText,
   pos = vec3 ]]--
   
   
    
    end

end 

-- CTLD Enhancements

function ctld.spawnCrateFromFile(_country, _point, _weight,_side)
  
  
  local _crateType = ctld.crateLookupTable[_weight]
    
  local _unitId = ctld.getNextUnitId()
  
  local _name = string.format("%s #%i", _crateType.desc, _unitId)
  
  --local _spawnedCrate = ctld.spawnCrateStatic(_country, _unitId, _point, _name, _weight,_side)
  
  
  local _spawnedCrate = ctld.spawnCrateStatic(_country, _unitId, _point, _name, _crateType.weight,_side)
  -- add to move table
  --ctld.crateMove[_name] = _name


end
-- -----------MAIN LOGIC-------------------------------

 local tpeconfigFile = io.open(tpeConfigFileName, 'r')

 if tpeconfigFile then
      local fileContent = tpeconfigFile:read('*all')
        tpeconfigFile:close()
        tpeconfigFile = nil
        tpe.config = JSON:decode(fileContent) -- decode example
        LOADED = true
 end

if LOADED then 
    
   trigger.action.outText( "Persistent Script Loaded "  .."\n", 15)
-- Initial Load

  timer.scheduleFunction( tpe.initialLoad, nil, timer.getTime() + 1)
    
  timer.scheduleFunction( tpe.saveJson, nil, timer.getTime() + 117)  
  tpeFileName = tpe_dir .. tpe.config.current_mission .. [[.txt]]
else
   trigger.action.outText("Persitent engine Config not found" .."\n" ,120)

end





  




