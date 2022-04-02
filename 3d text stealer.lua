local h = require('lib.samp.events')
local i = require('imgui')
local k = require('vkeys')
local e = require('encoding')
local b = require('numberlua')

e.default = 'CP1251'

local act_menu = i.ImBool(false)
local act_type = i.ImBuffer(256)

local fs3dt_base = { }
local f_id = -1
local saved_3dts = 0
local path_to_file = ''

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	sampAddChatMessage('[FS3DT] Скрипт успешно загружен / перезагружен, удачного использования!', 0xAFEEEE)
	sampAddChatMessage('[FS3DT] Автор всея творения f0Re3t!', 0xAFEEEE)
	while true do
		wait(0)
		if wasKeyPressed(k.VK_Z) and not sampIsChatInputActive() and not sampIsDialogActive() and f_id ~= -1 then act_menu.v = not act_menu.v end
		i.Process = act_menu.v
	end
end

function h.onInitGame(playerId, hostName, settings, vehicleModels, unknown)
	if f_id == -1 then
		local serv_name = hostName
		serv_name = serv_name:gsub('[|%%%[%]! :\\/*|"<>Х!' .. string.char(0x08) .. string.char(0x3F) .. ']', '_')
		if not doesDirectoryExist('FS3DT') then createDirectory('FS3DT') end
		if not doesFileExist(string.format('FS3DT\\%s', serv_name)) then
			f_id = io.open(string.format('FS3DT\\%s', serv_name), 'a+')
			sampAddChatMessage('[FS3DT] Файл создан, двойное нажатие в спсике сохранит выбранный 3д текст в файл!', 0xFFA500)
			path_to_file = string.format('FS3DT\\%s', serv_name)
			saved_3dts = 0
		else
			f_id = io.open(string.format('FS3DT\\%s', serv_name), 'w+')
			sampAddChatMessage('[FS3DT] Файл сервера уже существуюет, удаляем!', 0xFFA500)
			saved_3dts = 0
			path_to_file = string.format('FS3DT\\%s', serv_name)
		end
	end
end

function h.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
	local fs3dt_temp = { }
	fs3dt_temp['id'] = id
	fs3dt_temp['color'] = color
	fs3dt_temp['position'] = position
	fs3dt_temp['distance'] = distance
	fs3dt_temp['testLOS'] = testLOS
	fs3dt_temp['attachedPlayerId'] = attachedPlayerId
	fs3dt_temp['attachedVehicleId'] = attachedVehicleId
	fs3dt_temp['text'] = text
	table.insert(fs3dt_base, fs3dt_temp)
end

function h.onRemove3DTextLabel(textLabelId)
	for i, v in pairs(fs3dt_base) do
		for i1, v1 in pairs(v) do
			if i1 == 'id' and v1 == textLabelId then
				table.remove(fs3dt_base, i)
			end
		end
	end
end

function i.OnDrawFrame()
	if act_menu.v then
		local sx, sy = getScreenResolution()
		i.SetNextWindowSize(i.ImVec2(800, 500), i.Cond.FirstUseEver)
		i.SetNextWindowPos(i.ImVec2((sx / 2) - 400, (sy / 2) - 250), i.Cond.FirstUseEver, i.ImVec2(0, 0))
		i.Begin(e.UTF8(string.format('Стиллер 3д Текстов (В Стриме %d Текстов)', #fs3dt_base)), act_menu,
			i.WindowFlags.NoResize + i.WindowFlags.NoMove + i.WindowFlags.NoCollapse + i.WindowFlags.NoScrollbar + i.WindowFlags.NoBringToFrontOnFocus + i.WindowFlags.NoScrollWithMouse)
		i.Columns(6)
		i.Separator()
		i.NewLine()
		i.SameLine(2)
		i.Text(e.UTF8('Ид'))
		i.SetColumnWidth(-1, 55)
		i.NextColumn()
		i.Text(e.UTF8('Позиция'))
		i.SetColumnWidth(-1, 193)
		i.NextColumn()
		i.Text(e.UTF8('Дистанция'))
		i.SetColumnWidth(-1, 80)
		i.NextColumn()
		i.Text(e.UTF8('Аттач к игроку'))
		i.SetColumnWidth(-1, 100)
		i.NextColumn()
		i.Text(e.UTF8('Аттач к машине'))
		i.SetColumnWidth(-1, 105)
		i.NextColumn()
		i.Text(e.UTF8('Текст'))
		i.SetColumnWidth(-1, 267)
		i.NextColumn()
		i.Columns(1)
		i.Separator()
		i.BeginChild('##ScrollingRegion', i.ImVec2(0, 0), false)
		i.Columns(6)
		for m = 1, #fs3dt_base do
			if fs3dt_base[m] ~= nil then
				local testLOS = 0
				if fs3dt_base[m]['testLOS'] then testLOS = 1 else testLOS = 0 end
				local color = string.format('0x%X', b.band(0xFFFFFFFF, fs3dt_base[m]['color']))
				local text = string.gsub(fs3dt_base[m]['text'], '\n', '\\n')
				
				local ed_code = ''
				if fs3dt_base[m]['attachedPlayerId'] ~= 65535 then
					ed_code = e.UTF8(string.format('new Text3D:fs3dt;\nCreate3DTextLabel("%s", %s, %f, %f, %f, %f, 0, %d);\nAttach3DTextLabelToPlayer(fs3dt, playerid, %f, %f, %f);', text, color, fs3dt_base[m]['position']['x'], fs3dt_base[m]['position']['y'],
						fs3dt_base[m]['position']['z'], fs3dt_base[m]['distance'], testLOS, fs3dt_base[m]['position']['x'], fs3dt_base[m]['position']['y'], fs3dt_base[m]['position']['z']))
				elseif fs3dt_base[m]['attachedVehicleId'] ~= 65535 then
					ed_code = e.UTF8(string.format('new Text3D:fs3dt;\nCreate3DTextLabel("%s", %s, %f, %f, %f, %f, 0, %d);\nAttach3DTextLabelToVehicle(fs3dt, vehicleid, %f, %f, %f);', text, color, fs3dt_base[m]['position']['x'], fs3dt_base[m]['position']['y'],
						fs3dt_base[m]['position']['z'], fs3dt_base[m]['distance'], testLOS, fs3dt_base[m]['position']['x'], fs3dt_base[m]['position']['y'], fs3dt_base[m]['position']['z']))
				else
					ed_code = e.UTF8(string.format('Create3DTextLabel("%s", %s, %f, %f, %f, %f, 0, %d);', text, color, fs3dt_base[m]['position']['x'], fs3dt_base[m]['position']['y'],
						fs3dt_base[m]['position']['z'], fs3dt_base[m]['distance'], testLOS))
				end
				
				if i.Selectable(m, false, i.SelectableFlags.SpanAllColumns + i.SelectableFlags.AllowDoubleClick) then
					if i.IsMouseDoubleClicked(0) then
						if f_id ~= -1 then
							f_id:write(ed_code .. '\n\n')
							f_id:flush()
							sampAddChatMessage('[FS3DT] Выбранный 3д текст записан в файл!', 0xFFA500)
							saved_3dts = saved_3dts + 1
						else
							sampAddChatMessage('[FS3DT] Ошибка сохранения в файл!', 0xFF4500)
						end
					end
				end
				
				i.PushStyleVar(i.StyleVar.WindowPadding, i.ImVec2(4, 4))
				if i.BeginPopupContextItem() then
					act_type.v = ed_code
					i.InputTextMultiline('Редактор кода', act_type, 16384, i.ImVec2(250, 250))
					i.EndPopup()
				end
				i.PopStyleVar()
				
				i.NewLine()
				i.SameLine(2)
				i.SetColumnWidth(-1, 55)
				i.NextColumn()
				i.Text(e.UTF8(string.format('%.4f %.4f %.4f', fs3dt_base[m]['position']['x'], fs3dt_base[m]['position']['y'], fs3dt_base[m]['position']['z'])))
				i.SetColumnWidth(-1, 193)
				i.NextColumn()
				i.Text(e.UTF8(string.format('%.4f', fs3dt_base[m]['distance'])))
				i.SetColumnWidth(-1, 80)
				i.NextColumn()
				i.Text(e.UTF8(string.format('%d', fs3dt_base[m]['attachedPlayerId'])))
				i.SetColumnWidth(-1, 100)
				i.NextColumn()
				i.Text(e.UTF8(string.format('%d', fs3dt_base[m]['attachedVehicleId'])))
				i.SetColumnWidth(-1, 105)
				i.NextColumn()
				i.Text(e.UTF8(string.format('%s', text)))
				i.SetColumnWidth(-1, 267)
				i.NextColumn()
			end
		end
		i.Columns(1)
		if #fs3dt_base == 0 then
			i.SameLine(5.0)
			i.Text(e.UTF8('3д Текстов В зоне Стрима Нет'))
		end
		i.Separator()
		i.EndChild()
		i.End()
	end
end

function onScriptTerminate(s, quitGame)
	if s == thisScript() then
		showCursor(false)
		if saved_3dts == 0 then
			os.remove(path_to_file)
		end
	end
end

function onExitScript(quitGame)
	showCursor(false)
	if saved_3dts == 0 then
		os.remove(path_to_file)
	end
end
