local softLicenses = [[
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

  (Это свободная программа: вы можете перераспространять ее и/или изменять
   ее на условиях Стандартной общественной лицензии GNU в том виде, в каком
   она была опубликована Фондом свободного программного обеспечения; либо
   версии 3 лицензии, либо (по вашему выбору) любой более поздней версии.

   Эта программа распространяется в надежде, что она будет полезной,
   но БЕЗО ВСЯКИХ ГАРАНТИЙ; даже без неявной гарантии ТОВАРНОГО ВИДА
   или ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННЫХ ЦЕЛЕЙ. Подробнее см. в Стандартной
   общественной лицензии GNU.

   Вы должны были получить копию Стандартной общественной лицензии GNU
   вместе с этой программой. Если это не так, см.
   <https://www.gnu.org/licenses/>.)
]]

local h = require('samp.events')
local bit = require('numberlua')

local objectsTable = { }

local lastPlayerState = -1

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	
	sampAddChatMessage('Vehicle Attached Objects Stealer loaded by f0Re3t', 0xFFFFDAB9)
	sampAddChatMessage('VAOS: commands - /vaos [vehicle id]', 0xFFFFDAB9)
	
	sampRegisterChatCommand('vaos', vaos)
	
	while true do
		wait(0)
		
		local pState = sampGetGamestate()
		if pState == 5 and lastPlayerState ~= 5 and lastPlayerState ~= -1 then
			for i = 1, #objectsTable do
				if objectsTable[i] ~= nil then
					objectsTable[i] = nil
				end
			end
			lastPlayerState = pState
		end
	end
end

function vaos(id)
	if tonumber(id) == nil then return sampAddChatMessage('Invalid vehicle id', 0xFF9ACD32) end
	
	local res, vHandle = sampGetCarHandleBySampVehicleId(id)
	if not res then return sampAddChatMessage('Vehicle not in stream', 0xFF9ACD32) end
	
	local sIp, sPort = sampGetCurrentServerAddress()
	local sName = sIp .. '_' .. sPort
	
	sName = sName:gsub('[|%%%[%]! :\\/*|"<>•!' .. string.char(0x08) .. string.char(0x3F) .. ']', '_')
	
	if not doesDirectoryExist('VAOS') then createDirectory('VAOS') end
	if not doesDirectoryExist(string.format('VAOS\\%s', sName)) then createDirectory(string.format('VAOS\\%s', sName)) end
	
	local fID = io.open(string.format('VAOS\\%s\\%s', sName, tostring(id)), 'w+')
	
	local vPosX, vPosY, vPosZ = getCarCoordinates(vHandle)
	local vAngle = getCarHeading(vHandle)
	local vColorPrim, vColorSec = getCarColours(vHandle)
	
	fID:write(string.format('new vehicleid = CreateVehicle(%i, %f, %f, %f, %f, %i, %i, -1);', getCarModel(vHandle), vPosX, vPosY, vPosZ, vAngle, vColorPrim, vColorSec) .. '\n\n')
	
	for i = 1, #objectsTable do
		if objectsTable[i] ~= nil then
			if objectsTable[i]['id'] == tonumber(id) then
				local setDrawDist = 'STREAMER_OBJECT_DD'
				local setDrawDistNum = '0.0'
				
				if objectsTable[i]['data']['drawDistance'] > 0 then
					setDrawDist = tostring(objectsTable[i]['data']['drawDistance'])
					setDrawDistNum = tostring(objectsTable[i]['data']['drawDistance'])
					
					if setDrawDist == nil and setDrawDistNum == nil then
						setDrawDist = 'STREAMER_OBJECT_DD'
						setDrawDistNum = '0.0'
					else
						setDrawDist = tostring(math.floor(objectsTable[i]['data']['drawDistance'])) .. '.0'
						setDrawDistNum = tostring(math.floor(objectsTable[i]['data']['drawDistance'])) .. '.0'
					end
				end
				
				local objVar = 'vaos_' .. tostring(i)
				
				if objectsTable[i]['data']['materialNum'] == 0 and objectsTable[i]['data']['materialTxtNum'] == 0 then
					if objectsTable[i]['data']['streamerDynamic'] then
						fID:write(string.format('%sCreateDynamicObject(%d, %f, %f, %f, %f, %f, %f, %d, %d, -1, STREAMER_OBJECT_SD, %s); // %d', 'new ' .. objVar .. ' = ', objectsTable[i]['data']['modelId'],
							objectsTable[i]['data']['position']['x'], objectsTable[i]['data']['position']['y'], objectsTable[i]['data']['position']['z'],
								objectsTable[i]['data']['rotation']['x'], objectsTable[i]['data']['rotation']['y'], objectsTable[i]['data']['rotation']['z'],
									0, 0, setDrawDist, objectsTable[i]['data']['materialNum'] + objectsTable[i]['data']['materialTxtNum']) .. '\n')
						if objectsTable[i]['data']['cameraCol'] == 1 then fID:write(string.format('SetDynamicObjectNoCameraCol(%s);', objVar) .. '\n') end
						fID:write(string.format('AttachDynamicObjectToVehicle(%s, vehicleid, %f, %f, %f, %f, %f, %f);', objVar, objectsTable[i]['OffsetX'], objectsTable[i]['OffsetY'], objectsTable[i]['OffsetZ'],
							objectsTable[i]['RotX'], objectsTable[i]['RotY'], objectsTable[i]['RotZ']) .. '\n\n')
					else
						fID:write(string.format('%sCreateObject(%d, %f, %f, %f, %f, %f, %f, %s); // %d', 'new ' .. objVar .. ' = ', objectsTable[i]['data']['modelId'], objectsTable[i]['data']['position']['x'],
							objectsTable[i]['data']['position']['y'], objectsTable[i]['data']['position']['z'], objectsTable[i]['data']['rotation']['x'],
								objectsTable[i]['data']['rotation']['y'], objectsTable[i]['data']['rotation']['z'], setDrawDistNum, objectsTable[i]['data']['materialNum'] +
									objectsTable[i]['data']['materialTxtNum']) .. '\n')
						if objectsTable[i]['data']['cameraCol'] == 1 then fID:write(string.format('SetObjectNoCameraCol(%s);', objVar) .. '\n') end
						fID:write(string.format('AttachObjectToVehicle(%s, vehicleid, %f, %f, %f, %f, %f, %f);', objVar, objectsTable[i]['OffsetX'], objectsTable[i]['OffsetY'], objectsTable[i]['OffsetZ'],
							objectsTable[i]['RotX'], objectsTable[i]['RotY'], objectsTable[i]['RotZ']) .. '\n\n')
					end
				else
					if objectsTable[i]['data']['streamerDynamic'] then
						fID:write(string.format('%sCreateDynamicObject(%d, %f, %f, %f, %f, %f, %f, %d, %d, -1, STREAMER_OBJECT_SD, %s); // %d', 'new ' .. objVar .. ' = ', objectsTable[i]['data']['modelId'],
							objectsTable[i]['data']['position']['x'], objectsTable[i]['data']['position']['y'], objectsTable[i]['data']['position']['z'],
								objectsTable[i]['data']['rotation']['x'], objectsTable[i]['data']['rotation']['y'], objectsTable[i]['data']['rotation']['z'],
									0, 0, setDrawDist, objectsTable[i]['data']['materialNum'] + objectsTable[i]['data']['materialTxtNum']) .. '\n')
						if objectsTable[i]['data']['cameraCol'] == 1 then fID:write(string.format('SetDynamicObjectNoCameraCol(%s);', objVar) .. '\n') end
						
						for j = 1, #objectsTable[i]['data'] do
							if objectsTable[i]['data'][j] ~= nil then
								if objectsTable[i]['data'][j]['materialType'] == true then
									fID:write(string.format('SetDynamicObjectMaterial(%s, %d, %d, "%s", "%s", %s);', objVar, objectsTable[i]['data'][j]['materialId'],
										objectsTable[i]['data'][j]['modelId'], objectsTable[i]['data'][j]['libraryName'], objectsTable[i]['data'][j]['textureName'],
											objectsTable[i]['data'][j]['color']) .. '\n')
								else
									fID:write(string.format('SetDynamicObjectMaterialText(%s, %d, "%s", %d, "%s", %d, %d, %s, %s, %d);', objVar, objectsTable[i]['data'][j]['materialId'],
										objectsTable[i]['data'][j]['text'], objectsTable[i]['data'][j]['materialSize'], objectsTable[i]['data'][j]['fontName'],
											objectsTable[i]['data'][j]['fontSize'], objectsTable[i]['data'][j]['bold'], objectsTable[i]['data'][j]['fontColor'],
												objectsTable[i]['data'][j]['backGroundColor'], objectsTable[i]['data'][j]['align']) .. '\n')
								end
							end
						end
						
						fID:write(string.format('AttachDynamicObjectToVehicle(%s, vehicleid, %f, %f, %f, %f, %f, %f);', objVar, objectsTable[i]['OffsetX'], objectsTable[i]['OffsetY'], objectsTable[i]['OffsetZ'],
							objectsTable[i]['RotX'], objectsTable[i]['RotY'], objectsTable[i]['RotZ']) .. '\n\n')
					else
						fID:write(string.format('%sCreateObject(%d, %f, %f, %f, %f, %f, %f, %s); // %d', 'new ' .. objVar .. ' = ', objectsTable[i]['data']['modelId'], objectsTable[i]['data']['position']['x'],
							objectsTable[i]['data']['position']['y'], objectsTable[i]['data']['position']['z'], objectsTable[i]['data']['rotation']['x'],
								objectsTable[i]['data']['rotation']['y'], objectsTable[i]['data']['rotation']['z'], setDrawDistNum, objectsTable[i]['data']['materialNum'] +
									objectsTable[i]['data']['materialTxtNum']) .. '\n')
						if objectsTable[i]['data']['cameraCol'] == 1 then fID:write(string.format('SetObjectNoCameraCol(%s);', objVar) .. '\n') end
						
						for j = 1, #objectsTable[i]['data'] do
							if objectsTable[i]['data'][j] ~= nil then
								if objectsTable[i]['data'][j]['materialType'] == true then
									fID:write(string.format('SetObjectMaterial(%s, %d, %d, "%s", "%s", %s);', objVar, objectsTable[i]['data'][j]['materialId'],
										objectsTable[i]['data'][j]['modelId'], objectsTable[i]['data'][j]['libraryName'], objectsTable[i]['data'][j]['textureName'],
											objectsTable[i]['data'][j]['color']) .. '\n')
								else
									fID:write(string.format('SetObjectMaterialText(%s, "%s", %d, %d, "%s", %d, %d, %s, %s, %d);', objVar, objectsTable[i]['data'][j]['text'],
										objectsTable[i]['data'][j]['materialId'], objectsTable[i]['data'][j]['materialSize'], objectsTable[i]['data'][j]['fontName'],
											objectsTable[i]['data'][j]['fontSize'], objectsTable[i]['data'][j]['bold'], objectsTable[i]['data'][j]['fontColor'],
												objectsTable[i]['data'][j]['backGroundColor'], objectsTable[i]['data'][j]['align']) .. '\n')
								end
							end
						end
						
						fID:write(string.format('AttachObjectToVehicle(%s, vehicleid, %f, %f, %f, %f, %f, %f);', objVar, objectsTable[i]['OffsetX'], objectsTable[i]['OffsetY'], objectsTable[i]['OffsetZ'],
							objectsTable[i]['RotX'], objectsTable[i]['RotY'], objectsTable[i]['RotZ']) .. '\n\n')
					end
				end
			end
		end
	end
	
	sampAddChatMessage('GOOD! ATTACHED OBJECTS COPPIED!', 0xFFFFDAB9)
	
	io.close(fID)
end

function h.onCreateObject(objectId, data)
	local tempObj = { }
	
	tempObj['objectId'] = objectId
	tempObj['modelId'] = data.modelId
	tempObj['position'] = data.position
	tempObj['rotation'] = data.rotation
	tempObj['drawDistance'] = data.drawDistance
	tempObj['cameraCol'] = data.cameraCol
	tempObj['materialHave'] = false
	tempObj['materialNum'] = 0
	tempObj['materialTxtNum'] = 0
	
	if sampGetGamestate() == 2 then tempObj['streamerDynamic'] = false else tempObj['streamerDynamic'] = true end
	
	if data.texturesCount > 0 then
		if #data.materials ~= 0 then
			for i = 1, #data.materials do
				local tempMatObj = { }
				
				tempMatObj['objectId'] = data.objectId
				tempMatObj['materialId'] = data.materials[i]['materialId']
				tempMatObj['modelId'] = data.materials[i]['modelId']
				tempMatObj['libraryName'] = data.materials[i]['libraryName']
				tempMatObj['textureName'] = data.materials[i]['textureName']
				tempMatObj['materialType'] = true
				
				if data.materials[i]['color'] == 0 then tempMatObj['color'] = '0' else
					tempMatObj['color'] = string.format('0x%X', bit.band(0xFFFFFFFF, data.materials[i]['color']))
				end
				
				tempObj['materialHave'] = true
				tempObj['materialNum'] = tempObj['materialNum'] + 1
				
				table.insert(tempObj, tempMatObj)
			end
		end
		if #data.materialText ~= 0 then
			for i = 1, #data.materialText do
				local tempMatObj = {}
				
				tempMatObj['objectId'] = data.objectId
				tempMatObj['materialId'] = data.materialText[i]['materialId']
				tempMatObj['materialSize'] = data.materialText[i]['materialSize']
				tempMatObj['fontName'] = data.materialText[i]['fontName']
				tempMatObj['fontSize'] = data.materialText[i]['fontSize']
				tempMatObj['bold'] = data.materialText[i]['bold']
				tempMatObj['materialType'] = false
				
				if data.materialText[i]['fontColor'] == 0 then tempMatObj['fontColor'] = '0' else
					tempMatObj['fontColor'] = string.format('0x%X', bit.band(0xFFFFFFFF, data.materialText[i]['fontColor']))
				end
				
				if data.materialText[i]['backGroundColor'] == 0 then tempMatObj['backGroundColor'] = '0' else
					tempMatObj['backGroundColor'] = string.format('0x%X', bit.band(0xFFFFFFFF, data.materialText[i]['backGroundColor']))
				end
				
				tempMatObj['align'] = data.materialText[i]['align']
				data.materialText[i]['text'] = string.gsub(data.materialText[i]['text'], '\n', '\\n')
				tempMatObj['text'] = data.materialText[i]['text']
				
				tempObj['materialHave'] = true
				tempObj['materialTxtNum'] = tempObj['materialTxtNum'] + 1
				
				table.insert(tempObj, tempMatObj)
			end
		end
	end
	
	function h.onMoveObject(objectId, fromPos, destPos, speed, rotation)
		if tempObj['objectId'] == objectId then
			if tempObj['position']['x'] ~= destPos.x then tempObj['position']['x'] = destPos.x end
			if tempObj['position']['y'] ~= destPos.y then tempObj['position']['y'] = destPos.y end
			if tempObj['position']['z'] ~= destPos.z then tempObj['position']['z'] = destPos.z end
			
			if tempObj['rotation']['x'] ~= rotation.x and rotation.x ~= -1000.0 then tempObj['rotation']['x'] = rotation.x end
			if tempObj['rotation']['y'] ~= rotation.y and rotation.y ~= -1000.0 then tempObj['rotation']['y'] = rotation.y end
			if tempObj['rotation']['z'] ~= rotation.z and rotation.z ~= -1000.0 then tempObj['rotation']['z'] = rotation.z end
		end
	end
	
	function h.onSetObjectMaterial(objectId, data)
		if tempObj['objectId'] == objectId then
			local tempMatObj = {}
			
			tempMatObj['objectId'] = objectId
			tempMatObj['materialId'] = data.materialId
			tempMatObj['modelId'] = data.modelId
			tempMatObj['libraryName'] = data.libraryName
			tempMatObj['textureName'] = data.textureName
			tempMatObj['materialType'] = true
			
			if data.color == 0 then tempMatObj['color'] = '0' else tempMatObj['color'] = string.format('0x%X', bit.band(0xFFFFFFFF, data.color)) end
			
			tempObj['materialHave'] = true
			tempObj['materialNum'] = tempObj['materialNum'] + 1
			
			table.insert(tempObj, tempMatObj)
		end
	end
	
	function h.onSetObjectMaterialText(objectId, data)
		if tempObj['objectId'] == objectId then
			local tempMatObj = {}
			
			tempMatObj['objectId'] = objectId
			tempMatObj['materialId'] = data.materialId
			tempMatObj['materialSize'] = data.materialSize
			tempMatObj['fontName'] = data.fontName
			tempMatObj['fontSize'] = data.fontSize
			tempMatObj['bold'] = data.bold
			tempMatObj['materialType'] = false
			
			if data.fontColor == 0 then tempMatObj['fontColor'] = '0' else tempMatObj['fontColor'] = string.format('0x%X', bit.band(0xFFFFFFFF, data.fontColor)) end
			if data.backGroundColor == 0 then tempMatObj['backGroundColor'] = '0' else tempMatObj['backGroundColor'] = string.format('0x%X', bit.band(0xFFFFFFFF,
				data.backGroundColor)) end
				
			tempMatObj['align'] = data.align
			data.text = string.gsub(data.text, '\n', '\\n')
			tempMatObj['text'] = data.text
			
			tempObj['materialHave'] = true
			tempObj['materialTxtNum'] = tempObj['materialTxtNum'] + 1
			
			table.insert(tempObj, tempMatObj)
		end
	end
	
	function h.onSetObjectPosition(objectId, position)
		if tempObj['objectId'] == objectId then
			if tempObj['position']['x'] ~= position.x then tempObj['position']['x'] = position.x end
			if tempObj['position']['y'] ~= position.y then tempObj['position']['y'] = position.y end
			if tempObj['position']['z'] ~= position.z then tempObj['position']['z'] = position.z end
		end
	end
	
	function h.onSetObjectRotation(objectId, rotation)
		if tempObj['objectId'] == objectId then
			if tempObj['rotation']['x'] ~= rotation.x then tempObj['rotation']['x'] = rotation.x end
			if tempObj['rotation']['y'] ~= rotation.y then tempObj['rotation']['y'] = rotation.y end
			if tempObj['rotation']['z'] ~= rotation.z then tempObj['rotation']['z'] = rotation.z end
		end
	end
	
	if data.attachToPlayerId ~= nil then
		if data.attachToPlayerId ~= 65535 then
			if not sampIsPlayerConnected(data.attachToPlayerId) then return false end
		
			if tempObj['position']['x'] ~= data.attachOffsets.x and data.attachOffsets.x < -10.0 or data.attachOffsets.x > 10.0 and data.attachOffsets.x ~= nil then
				tempObj['position']['x'] = data.attachOffsets.x else return false end
			if tempObj['position']['y'] ~= data.attachOffsets.y and data.attachOffsets.y < -10.0 or data.attachOffsets.y > 10.0 and data.attachOffsets.y ~= nil then
				tempObj['position']['y'] = data.attachOffsets.y else return false end
			if tempObj['position']['z'] ~= data.attachOffsets.z and data.attachOffsets.z < -10.0 or data.attachOffsets.z > 10.0 and data.attachOffsets.z ~= nil then
				tempObj['position']['z'] = data.attachOffsets.z else return false end
				
			if tempObj['rotation']['x'] ~= data.attachRotation.x and data.attachRotation.x ~= nil then tempObj['rotation']['x'] = data.attachRotation.x end
			if tempObj['rotation']['y'] ~= data.attachRotation.y and data.attachRotation.y ~= nil then tempObj['rotation']['y'] = data.attachRotation.y end
			if tempObj['rotation']['z'] ~= data.attachRotation.z and data.attachRotation.z ~= nil then tempObj['rotation']['z'] = data.attachRotation.z end
		end
	end
	
	if data.attachToVehicleId ~= nil then
		if data.attachToVehicleId ~= 65535 then
			local vehicleData = {}
			
			vehicleData['id'] = data.attachToVehicleId
			vehicleData['data'] = tempObj
			
			vehicleData['OffsetX'] = data.attachOffsets.x
			vehicleData['OffsetY'] = data.attachOffsets.y
			vehicleData['OffsetZ'] = data.attachOffsets.z
			vehicleData['RotX'] = data.attachRotation.x
			vehicleData['RotY'] = data.attachRotation.y
			vehicleData['RotZ'] = data.attachRotation.z
			
			table.insert(objectsTable, vehicleData)
		end
	end
end

function h.onDestroyObject(objectId)
	for i = 1, #objectsTable do
		if objectsTable[i] ~= nil then
			if objectsTable[i]['data']['objectId'] == objectId then
				objectsTable[i] = nil
				break
			end
		end
	end
end
