local vector3d = require('vector3d')
local bit = require('numberlua')
local hook = require('samp.events')

script_url('https://vk.com/f0rbka')
script_version_number(6)
script_version('v0.6-pre')
script_name('f0Re3t Stealer Objects | FSO SIX')
script_description('Copy server objects and textures (texts) and other ..')
script_author('f0Re3t')
script_moonloader(25)

local servers_deleted_objects = {}
local servers_database_objects = {}
local copy_start = 0
local f_id = -1
local path_to_save_file = ''
local copy_tipe_select = 0
local ma_x, ma_y, ma_z = 0.0, 0.0, 0.0
local selected_to_copy_objects = {}
local selected_to_delete_objects = {}
local render_id = -1
local render_font = renderCreateFont('Tahoma', 9.5, 12)
local mi_x, mi_y, mi_z = 0.0, 0.0, 0.0
local num_ids_deleted_objects = 1
local num_ids_created_objects = 1
local int_world, int_interior = -1, -1
local auto_set_int = true
local auto_set_dd = true
local show_deleted_obj = true
local show_fso_info = true
local fso_info_thread = -1
local type_two_radius = 0
local last_player_state = -1

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	
	sampAddChatMessage('[FSO SIX] Скрипт успешно загружен и начал сбор данных об объектах', 0xFFFFDAB9)
	sampAddChatMessage('[FSO SIX] Автор данного скрипта - f0Re3t', 0xFFEEE8AA)
	sampAddChatMessage('[FSO SIX] Обо всех багах и ошибках скрипта писать в лс в вк', 0xFFEEE8AA)
	
	if auto_set_int then sampAddChatMessage('[FSO SIX] Активирована система автоматического копирования интерьера! Для оффа - /fso_i', 0xFFFFDAB9) end
	if auto_set_dd then sampAddChatMessage('[FSO SIX] Включено копирование дальности объекта! Для оффа - /fso_dd', 0xFFFFDAB9) end
	if show_deleted_obj then sampAddChatMessage('[FSO SIX] Включен показ удаленных объектов! Для оффа - /fso_sdo', 0xFFFFDAB9) end
	if show_fso_info then
		sampAddChatMessage('[FSO SIX] Включен показ инфы об объектах на экране! Для оффа - /fso_info', 0xFFFFDAB9)
		fso_info_thread = lua_thread.create(fso_info_update)
	end
	
	sampRegisterChatCommand('fso', ffso_cmd_funcs)
	
	sampRegisterChatCommand('fso_d', fso_d)
	sampRegisterChatCommand('fso_w', fso_w)
	
	sampRegisterChatCommand('fso_i', fso_i)
	sampRegisterChatCommand('fso_dd', fso_dd)
	sampRegisterChatCommand('fso_sdo', fso_sdo)
	sampRegisterChatCommand('fso_info', fso_info)
	
	sampRegisterChatCommand('fso_un', fso_un)
	
	while true do
		wait(0)
		local state = sampGetGamestate()
		if state == 5 and last_player_state ~= 5 and last_player_state ~= -1 then
			for i = 1, #servers_database_objects do
				if servers_database_objects[i] ~= nil then
					servers_database_objects[i] = nil
				end
			end
			for i = 1, #servers_deleted_objects do
				if servers_deleted_objects[i] ~= nil then
					servers_deleted_objects[i] = nil
				end
			end
			sampAddChatMessage('[FSO SIX] Соединение с сервером потеряно, база объектов обнулена', 0xFFFFDAB9)
		end
		last_player_state = state
	end
end

function onQuitGame()
	if copy_start ~= 0 then os.execute(string.format('DEL /F /S /Q /A "%s"', path_to_save_file)) end
end

function onExitScript(quitGame)
	if copy_start ~= 0 then os.execute(string.format('DEL /F /S /Q /A "%s"', path_to_save_file)) end
end

function onScriptTerminate(s, quitGame)
	if copy_start ~= 0 and s == thisScript() then os.execute(string.format('DEL /F /S /Q /A "%s"', path_to_save_file)) end
end

function fso_info()
	if show_fso_info then
		show_fso_info = false
		sampAddChatMessage('[FSO SIX] Информация об объектах отключена!', 0xFFFFD700)
		fso_info_thread:terminate()
		fso_info_thread = -1
	else
		show_fso_info = true
		sampAddChatMessage('[FSO SIX] Информация об объектах включена!', 0xFFFFD700)
		fso_info_thread = lua_thread.create(fso_info_update)
	end
end

function fso_info_update()	
	repeat
		wait(0)
		local base_created, base_deleted = 0, 0
		local copy_created, copy_deleted = 0, 0
		if not sampIsChatInputActive() and not sampIsScoreboardOpen() then
			for i = 1, #servers_database_objects do
				if servers_database_objects[i] ~= nil then base_created = base_created + 1 end
			end
			for i = 1, #servers_deleted_objects do
				if servers_deleted_objects[i] ~= nil then base_deleted = base_deleted + 1 end
			end
			for i = 1, #selected_to_copy_objects do
				if selected_to_copy_objects[i] ~= nil and not selected_to_copy_objects[i]['deleted_obj'] then copy_created = copy_created + 1 end
			end
			for i = 1, #selected_to_delete_objects do
				if selected_to_delete_objects[i] ~= nil and not selected_to_delete_objects[i]['deleted_obj'] then copy_deleted = copy_deleted + 1 end
			end
			
			renderFontDrawText(render_font, string.format('Объектов в бд скрипта: %d | Выделено для копирования: %d | Всего: %d', base_created, copy_created,
				#servers_database_objects), 42, 213, 0xFF7FFFD4)
			renderFontDrawText(render_font, string.format('Удаленных объектов: %d | Выделено для копирования: %d | Всего: %d', base_deleted, copy_deleted,
				#servers_deleted_objects), 42, 233, 0xFFF0E68C)
		end
	until false
end

function fso_sdo(arg)
	if show_deleted_obj then
		show_deleted_obj = false
		sampAddChatMessage('[FSO SIX] Показ удаленных объектов отключен!', 0xFFFFD700)
	else
		show_deleted_obj = true
		sampAddChatMessage('[FSO SIX] Показ удаленных объектов включен!', 0xFFFFD700)
	end
end

function fso_dd(arg)
	if auto_set_dd then
		auto_set_dd = false
		sampAddChatMessage('[FSO SIX] Система установки дальности прорисовки отключена!', 0xFFFFD700)
	else
		auto_set_dd = true
		sampAddChatMessage('[FSO SIX] Система установки дальности прорисовки включена!', 0xFFFFD700)
	end
end

function fso_i(arg)
	if auto_set_int then
		auto_set_int = false
		sampAddChatMessage('[FSO SIX] Система установки ид интерьера отключена', 0xFFFFD700)
	else
		auto_set_int = true
		sampAddChatMessage('[FSO SIX] Система установки ид интерьера включена', 0xFFFFD700)
	end
end

function fso_w(arg)
	if copy_start ~= 0 then return sampAddChatMessage('[FSO SIX] В данный момент задать вирт мир нельзя', 0xFF9ACD32) end
	local W = string.match(arg, '(%d+)')
	W = tonumber(W)
	if W ~= nil then
		if W == 0 then int_world = -1 else int_world = W end
		sampAddChatMessage('[FSO SIX] Вирт мир для объектов успешно установлен', 0xFFFFD700)
		return
	end
	sampAddChatMessage('[FSO SIX] Не указан ид вирт мира (если не нужен напиши 0)', 0xFF9ACD32)
end

function fso_d(arg)
	if arg == nil then return sampAddChatMessage('[FSO SIX] Укажите тип удалямоего объекта', 0xFF9ACD32) end
	local name, id = string.match(arg, '(%a+)% (%d+)')
	name = tostring(name)
	id = tonumber(id)
	if id == nil then return sampAddChatMessage('[FSO SIX] Не указан ид или тип удаляемого объекта', 0xFF9ACD32) end
	if id < 1 then return sampAddChatMessage('[FSO SIX] Указан неверный тип удаляемого объекта', 0xFF9ACD32) end
	local deleted_or_not = false
	if name == 'CO' or name == 'co' then
		if id == nil then return sampAddChatMessage('[FSO SIX] Не указан ид или тип удаляемого объекта', 0xFF9ACD32) end
		for i = 1, #selected_to_copy_objects do
			if selected_to_copy_objects[i] ~= nil then
				if selected_to_copy_objects[i]['scr_id'] == id then
					if selected_to_copy_objects[i]['deleted_obj'] then
						sampAddChatMessage('[FSO SIX] Объект с указанным идом восстановлен из удаленных', 0xFFFFD700)
						selected_to_copy_objects[i]['deleted_obj'] = false
						deleted_or_not = true
						break
					end
					selected_to_copy_objects[i]['deleted_obj'] = true
					sampAddChatMessage('[FSO SIX] Объект с указанным идом удален из базы копируемых', 0xFFFFD700)
					deleted_or_not = true
				end
			end
		end
		if not deleted_or_not then sampAddChatMessage('[FSO SIX] Объект с указанным идом не найден в базе', 0xFF9ACD32) end
	elseif name == 'DO' or name == 'do' then
		if id == nil then return sampAddChatMessage('[FSO SIX] Не указан ид или тип удаляемого объекта', 0xFF9ACD32) end
		for i = 1, #selected_to_delete_objects do
			if selected_to_delete_objects[i] ~= nil then
				if selected_to_delete_objects[i]['scr_id'] == id then
					if selected_to_delete_objects[i]['deleted_obj'] then
						sampAddChatMessage('[FSO SIX] Объект с указанным идом восстановлен из удаленных', 0xFFFFD700)
						selected_to_delete_objects[i]['deleted_obj'] = false
						deleted_or_not = true
						break
					end
					selected_to_delete_objects[i]['deleted_obj'] = true
					sampAddChatMessage('[FSO SIX] Объект с указанным идом удален из базы копируемых', 0xFFFFD700)
					deleted_or_not = true
				end
			end
		end
		if not deleted_or_not then sampAddChatMessage('[FSO SIX] Объект с указанным идом не найден в базе', 0xFF9ACD32) end
	else
		sampAddChatMessage('[FSO SIX] Не указан ид или тип удаляемого объекта', 0xFF9ACD32)
	end
end

function ffso_cmd_funcs(arg)
	if copy_start == 0 then
		if arg == nil then return sampAddChatMessage('[FSO SIX] Введите название файла в который сохранится маппинг', 0xFF9ACD32) end
		arg = tostring(arg)
		if arg == nil or arg == '' then return sampAddChatMessage('[FSO SIX] Введите название файла в который сохранится маппинг', 0xFF9ACD32) end
		local serv_name = sampGetCurrentServerName()
		serv_name = serv_name:gsub('[|%%%[%]! :\\/*|"<>•!' .. string.char(0x08) .. string.char(0x3F) .. ']', '_')
		arg = arg:gsub('[|%%%[%]! :\\/*|"<>•!' .. string.char(0x08) .. string.char(0x3F) .. ']', '_')
		if not doesDirectoryExist('FSO') then createDirectory('FSO') end
		if not doesDirectoryExist(string.format('FSO\\%s', serv_name)) then createDirectory(string.format('FSO\\%s', serv_name)) end
		if not doesFileExist(string.format('FSO\\%s\\%s', serv_name, arg)) then
			f_id = io.open(string.format('FSO\\%s\\%s', serv_name, arg), 'a+')
			local gta_sa_path = getGameDirectory()
			path_to_save_file = string.format('%s\\FSO\\%s\\%s', gta_sa_path, serv_name, arg)
			local p_x, p_y, p_z = getCharCoordinates(PLAYER_PED)
			f_id:write(string.format('SetPlayerPos(playerid, %f, %f, %f);', p_x, p_y, p_z) .. '\n')
			if int_world ~= 0 and int_world ~= -1 then
				f_id:write(string.format('SetPlayerVirtualWorld(playerid, %d);', int_world) .. '\n')
			end
			sampAddChatMessage('[FSO SIX] Файл для сохранения маппинга создан, точка спавна установлена, следующий пункт - тип стиллинга объектов', 0xFFFFD700)
			sampAddChatMessage('[FSO SIX] Доступные типы стиллинга объектов: 1 - по кубоидной форме, 2 - по радиусной форме', 0xFFFFD700)
			copy_start = copy_start + 1
		else
			sampAddChatMessage('[FSO SIX] Файл в который вы собираетесь сохранить маппинг уже существует', 0xFF9ACD32)
		end
	elseif copy_start == 1 then
		if arg == nil then return sampAddChatMessage('[FSO SIX] Указан неверный тип стиллинга объектов', 0xFF9ACD32) end
		arg = tonumber(arg)
		if arg == nil then return sampAddChatMessage('[FSO SIX] Указан неверный тип стиллинга объектов', 0xFF9ACD32) end
		if arg < 1 or arg > 2 then return sampAddChatMessage('[FSO SIX] Тип стиллинга не может быть меньше 1 или больше 2', 0xFF9ACD32) end
		if arg == 1 then
			copy_start = copy_start + 10
			sampAddChatMessage('[FSO SIX] Тип стиллинга установлен - кубоидная форма, следующий пункт - минимальная позиция', 0xFFFFD700)
			copy_tipe_select = 2
		else
			copy_start = copy_start + 1
			sampAddChatMessage('[FSO SIX] Тип стиллинга установлен - радиусная форма, следующий пункт - центральная точка радиуса', 0xFFFFD700)
			copy_tipe_select = 1
		end
	elseif copy_start == 11 then
		mi_x, mi_y, mi_z = getCharCoordinates(PLAYER_PED)
		sampAddChatMessage('[FSO SIX] Минимальная позиция куба установлена, следующий пункт - максимальная позиция', 0xFFFFD700)
		copy_start = copy_start + 1
	elseif copy_start == 12 then
		ma_x, ma_y, ma_z = getCharCoordinates(PLAYER_PED)
		for i = 1, #servers_database_objects do
			if servers_database_objects[i] ~= nil then
				if PositionOnCuboid(ma_x, ma_y, ma_z, mi_x, mi_y, mi_z, servers_database_objects[i]['position']['x'], servers_database_objects[i]['position']['y'],
					servers_database_objects[i]['position']['z']) then
						table.insert(selected_to_copy_objects, servers_database_objects[i])
				end
			end
		end
		for i = 1, #servers_deleted_objects do
			if servers_deleted_objects[i] ~= nil then
				if PositionOnCuboid(ma_x, ma_y, ma_z, mi_x, mi_y, mi_z, servers_deleted_objects[i]['position']['x'], servers_deleted_objects[i]['position']['y'],
					servers_deleted_objects[i]['position']['z']) then
						table.insert(selected_to_delete_objects, servers_deleted_objects[i])
				end
			end
		end
		if #selected_to_copy_objects == 0 and #selected_to_delete_objects == 0 then
			f_id:close()
			os.remove(path_to_save_file)
			ma_x, ma_y, ma_z = 0.0, 0.0, 0.0
			copy_start = 0
			f_id = -1
			copy_tipe_select = 0
			path_to_save_file = ''
			render_id = -1
			mi_x, mi_y, mi_z = 0.0, 0.0, 0.0
			int_world, int_interior = -1, -1
			type_two_radius = 0
			for i = 1, #selected_to_copy_objects do
				selected_to_copy_objects[i] = nil
			end
			for i = 1, #selected_to_delete_objects do
				selected_to_delete_objects[i] = nil
			end
			sampAddChatMessage('[FSO SIX] В заданном кубе не найдено ни одного объекта для копирования', 0xFFFFFF00)
			return
		end
		sampAddChatMessage('[FSO SIX] Начинаем рендер всех выделенных объектов в заданном кубе, следующий пункт - сохранение маппинга в файл', 0xFFFFD700)
		render_id = lua_thread.create(render_objects_id_keys)
		copy_start = 4
	elseif copy_start == 2 then
		ma_x, ma_y, ma_z = getCharCoordinates(PLAYER_PED)
		sampAddChatMessage('[FSO SIX] Центральная точка радиуса установлена, следующий пункт - значеие самого радиуса', 0xFFFFD700)
		copy_start = copy_start + 1
	elseif copy_start == 3 then
		if arg == nil then return sampAddChatMessage('[FSO SIX] Указано неверное значение радиуса', 0xFF9ACD32) end
		arg = tonumber(arg)
		if arg == nil then return sampAddChatMessage('[FSO SIX] Указано неверное значение радиуса', 0xFF9ACD32) end
		if arg < 1 or arg > 5000 then return sampAddChatMessage('[FSO SIX] Задано кривое значеие радиуса | Радиус не может быть меньше 1 или больше 5000', 0xFF9ACD32) end
		type_two_radius = arg
		for i = 1, #servers_database_objects do
			if servers_database_objects[i] ~= nil then
				if PositionInRadius(ma_x, ma_y, ma_z, arg, servers_database_objects[i]['position']['x'], servers_database_objects[i]['position']['y'],
					servers_database_objects[i]['position']['z']) then
						table.insert(selected_to_copy_objects, servers_database_objects[i])
				end
			end
		end
		for i = 1, #servers_deleted_objects do
			if servers_deleted_objects[i] ~= nil then
				if PositionInRadius(ma_x, ma_y, ma_z, arg, servers_deleted_objects[i]['position']['x'], servers_deleted_objects[i]['position']['y'],
					servers_deleted_objects[i]['position']['z']) then
						table.insert(selected_to_delete_objects, servers_deleted_objects[i])
				end
			end
		end
		if #selected_to_copy_objects == 0 and #selected_to_delete_objects == 0 then
			f_id:close()
			os.remove(path_to_save_file)
			ma_x, ma_y, ma_z = 0.0, 0.0, 0.0
			copy_start = 0
			f_id = -1
			copy_tipe_select = 0
			path_to_save_file = ''
			render_id = -1
			mi_x, mi_y, mi_z = 0.0, 0.0, 0.0
			int_world, int_interior = -1, -1
			type_two_radius = 0
			for i = 1, #selected_to_copy_objects do
				selected_to_copy_objects[i] = nil
			end
			for i = 1, #selected_to_delete_objects do
				selected_to_delete_objects[i] = nil
			end
			sampAddChatMessage('[FSO SIX] В заданном радиусе не найдено ни одного объекта для копирования', 0xFFFFFF00)
			return
		end
		sampAddChatMessage('[FSO SIX] Начинаем рендер всех выделенных объектов в заданном радиусе, следующий пункт - сохранение маппинга в файл', 0xFFFFD700)
		render_id = lua_thread.create(render_objects_id_keys)
		copy_start = copy_start + 1
	elseif copy_start == 4 then
		if auto_set_int then
			local a_int = getActiveInterior()
			if a_int ~= 0 and a_int ~= -1 then
				int_interior = a_int
				f_id:write(string.format('SetPlayerInterior(playerid, %d);', int_interior) .. '\n')
			else
				int_interior = -1
			end
		else
			int_interior = -1
		end
		f_id:write('new fso_map;' .. '\n')
		
		local act_dd = auto_set_dd
		
		for i = 1, #selected_to_copy_objects do
			if selected_to_copy_objects[i] ~= nil then
				if not selected_to_copy_objects[i]['deleted_obj'] then
					local set_dd = 'STREAMER_OBJECT_DD'
					local set_dd_d = '0.0'
					if act_dd then
						if selected_to_copy_objects[i]['drawDistance'] > 0 then
							set_dd = tostring(selected_to_copy_objects[i]['drawDistance'])
							set_dd_d = tostring(selected_to_copy_objects[i]['drawDistance'])
							
							if set_dd == nil and set_dd_d == nil then
								set_dd = 'STREAMER_OBJECT_DD'
								set_dd_d = '0.0'
							else
								set_dd = tostring(math.floor(selected_to_copy_objects[i]['drawDistance'])) .. '.0'
								set_dd_d = tostring(math.floor(selected_to_copy_objects[i]['drawDistance'])) .. '.0'
							end
						else
							set_dd = 'STREAMER_OBJECT_DD'
							set_dd_d = '0.0'
						end
					else
						set_dd = 'STREAMER_OBJECT_DD'
						set_dd_d = '0.0'
					end
					if selected_to_copy_objects[i]['mat_num'] == 0 and selected_to_copy_objects[i]['mat_num_txt'] == 0 then
						local is_object_have_col = ''
						if selected_to_copy_objects[i]['cameraCol'] == 1 then is_object_have_col = 'fso_map = ' else is_object_have_col = '' end
						if selected_to_copy_objects[i]['is_dynamic'] then
							f_id:write(string.format('%sCreateDynamicObject(%d, %f, %f, %f, %f, %f, %f, %d, %d, -1, STREAMER_OBJECT_SD, %s); // %d', is_object_have_col, selected_to_copy_objects[i]['modelId'],
								selected_to_copy_objects[i]['position']['x'], selected_to_copy_objects[i]['position']['y'], selected_to_copy_objects[i]['position']['z'],
									selected_to_copy_objects[i]['rotation']['x'], selected_to_copy_objects[i]['rotation']['y'], selected_to_copy_objects[i]['rotation']['z'],
										int_world, int_interior, set_dd, selected_to_copy_objects[i]['mat_num'] + selected_to_copy_objects[i]['mat_num_txt']) .. '\n')
							if is_object_have_col ~= '' then f_id:write(string.format('SetDynamicObjectNoCameraCol(fso_map);') .. '\n') end
						else
							f_id:write(string.format('%sCreateObject(%d, %f, %f, %f, %f, %f, %f, %s); // %d', is_object_have_col, selected_to_copy_objects[i]['modelId'], selected_to_copy_objects[i]['position']['x'],
								selected_to_copy_objects[i]['position']['y'], selected_to_copy_objects[i]['position']['z'], selected_to_copy_objects[i]['rotation']['x'],
									selected_to_copy_objects[i]['rotation']['y'], selected_to_copy_objects[i]['rotation']['z'], set_dd_d, selected_to_copy_objects[i]['mat_num'] +
										selected_to_copy_objects[i]['mat_num_txt']) .. '\n')
							if is_object_have_col ~= '' then f_id:write(string.format('SetObjectNoCameraCol(fso_map);') .. '\n') end
						end
					else
						if selected_to_copy_objects[i]['is_dynamic'] then
							f_id:write(string.format('fso_map = CreateDynamicObject(%d, %f, %f, %f, %f, %f, %f, %d, %d, -1, STREAMER_OBJECT_SD, %s); // %d', selected_to_copy_objects[i]['modelId'],
								selected_to_copy_objects[i]['position']['x'], selected_to_copy_objects[i]['position']['y'], selected_to_copy_objects[i]['position']['z'],
									selected_to_copy_objects[i]['rotation']['x'], selected_to_copy_objects[i]['rotation']['y'], selected_to_copy_objects[i]['rotation']['z'],
										int_world, int_interior, set_dd, selected_to_copy_objects[i]['mat_num'] + selected_to_copy_objects[i]['mat_num_txt']) .. '\n')
							if selected_to_copy_objects[i]['cameraCol'] == 1 then f_id:write(string.format('SetDynamicObjectNoCameraCol(fso_map);') .. '\n') end
							for j = 1, #selected_to_copy_objects[i] do
								if selected_to_copy_objects[i][j] ~= nil then
									if selected_to_copy_objects[i][j]['mat_type'] == 1 then
										f_id:write(string.format('SetDynamicObjectMaterial(fso_map, %d, %d, "%s", "%s", %s);', selected_to_copy_objects[i][j]['materialId'],
											selected_to_copy_objects[i][j]['modelId'], selected_to_copy_objects[i][j]['libraryName'], selected_to_copy_objects[i][j]['textureName'],
												selected_to_copy_objects[i][j]['color']) .. '\n')
									else
										f_id:write(string.format('SetDynamicObjectMaterialText(fso_map, %d, "%s", %d, "%s", %d, %d, %s, %s, %d);', selected_to_copy_objects[i][j]['materialId'],
											selected_to_copy_objects[i][j]['text'], selected_to_copy_objects[i][j]['materialSize'], selected_to_copy_objects[i][j]['fontName'],
												selected_to_copy_objects[i][j]['fontSize'], selected_to_copy_objects[i][j]['bold'], selected_to_copy_objects[i][j]['fontColor'],
													selected_to_copy_objects[i][j]['backGroundColor'], selected_to_copy_objects[i][j]['align']) .. '\n')
									end
								end
							end
						else
							f_id:write(string.format('fso_map = CreateObject(%d, %f, %f, %f, %f, %f, %f, %s); // %d', selected_to_copy_objects[i]['modelId'],
								selected_to_copy_objects[i]['position']['x'], selected_to_copy_objects[i]['position']['y'], selected_to_copy_objects[i]['position']['z'],
									selected_to_copy_objects[i]['rotation']['x'], selected_to_copy_objects[i]['rotation']['y'], selected_to_copy_objects[i]['rotation']['z'],
										set_dd_d, selected_to_copy_objects[i]['mat_num'] + selected_to_copy_objects[i]['mat_num_txt']) .. '\n')
							if selected_to_copy_objects[i]['cameraCol'] == 1 then f_id:write(string.format('SetObjectNoCameraCol(fso_map);') .. '\n') end
							for j = 1, #selected_to_copy_objects[i] do
								if selected_to_copy_objects[i][j] ~= nil then
									if selected_to_copy_objects[i][j]['mat_type'] == 1 then
										f_id:write(string.format('SetObjectMaterial(fso_map, %d, %d, "%s", "%s", %s);', selected_to_copy_objects[i][j]['materialId'],
											selected_to_copy_objects[i][j]['modelId'], selected_to_copy_objects[i][j]['libraryName'], selected_to_copy_objects[i][j]['textureName'],
												selected_to_copy_objects[i][j]['color']) .. '\n')
									else
										f_id:write(string.format('SetObjectMaterialText(fso_map, "%s", %d, %d, "%s", %d, %d, %s, %s, %d);', selected_to_copy_objects[i][j]['text'],
											selected_to_copy_objects[i][j]['materialId'], selected_to_copy_objects[i][j]['materialSize'], selected_to_copy_objects[i][j]['fontName'],
												selected_to_copy_objects[i][j]['fontSize'], selected_to_copy_objects[i][j]['bold'], selected_to_copy_objects[i][j]['fontColor'],
													selected_to_copy_objects[i][j]['backGroundColor'], selected_to_copy_objects[i][j]['align']) .. '\n')
									end
								end
							end
						end
					end
				end
			end
		end
		
		for i = 1, #selected_to_delete_objects do
			if selected_to_delete_objects[i] ~= nil then
				if not selected_to_delete_objects[i]['deleted_obj'] then
					f_id:write(string.format('RemoveBuildingForPlayer(playerid, %d, %f, %f, %f, %f);', selected_to_delete_objects[i]['modelId'],
						selected_to_delete_objects[i]['position']['x'], selected_to_delete_objects[i]['position']['y'], selected_to_delete_objects[i]['position']['z'],
							selected_to_delete_objects[i]['radius']) .. '\n')
				end
			end
		end
		
		sampAddChatMessage('[FSO SIX] Маппинг успешно скопирован с сервера и сохранен в файл', 0xFFFFD700)
		
		f_id:close()
		render_id:terminate()
		ma_x, ma_y, ma_z = 0.0, 0.0, 0.0
		mi_x, mi_y, mi_z = 0.0, 0.0, 0.0
		copy_start = 0
		f_id = -1
		render_id = -1
		copy_tipe_select = 0
		path_to_save_file = ''
		render_id = -1
		int_world, int_interior = -1, -1
		type_two_radius = 0
		
		for i = 1, #selected_to_copy_objects do
			selected_to_copy_objects[i] = nil
		end
		for i = 1, #selected_to_delete_objects do
			selected_to_delete_objects[i] = nil
		end
	end
end

function Draw_3D_Circle(x, y, z, radius, r, accuracy)
	local accuracy = accuracy or 3
	local screen_x_line_old, screen_y_line_old
	
	for rot = 0, 360, accuracy do
		local rot_temp = math.rad(rot)
		local lineX, lineY, lineZ = radius * math.cos(rot_temp) + x, radius * math.sin(rot_temp) + y, z
		local screen_x_line, screen_y_line = convert3DCoordsToScreen(lineX, lineY, lineZ)
		if isPointOnScreen(lineX, lineY, lineZ, 0.0) and screen_x_line ~= nil and screen_x_line_old ~= nil then
			renderDrawLine(screen_x_line, screen_y_line, screen_x_line_old, screen_y_line_old, 2.5, r)
		end
		screen_x_line_old, screen_y_line_old = screen_x_line, screen_y_line
	end
end

function render_objects_id_keys()
	repeat
		wait(0)
		for i = 1, #selected_to_copy_objects do
			if selected_to_copy_objects[i] ~= nil then
				if isPointOnScreen(selected_to_copy_objects[i]['position']['x'], selected_to_copy_objects[i]['position']['y'], selected_to_copy_objects[i]['position']['z'], 0.0) then
					local o_x, o_y = convert3DCoordsToScreen(selected_to_copy_objects[i]['position']['x'], selected_to_copy_objects[i]['position']['y'],
						selected_to_copy_objects[i]['position']['z'])
					if not selected_to_copy_objects[i]['deleted_obj'] then
						if selected_to_copy_objects[i]['is_dynamic'] then
							renderFontDrawText(render_font, string.format('SID: %d | M: %d | TXT: %d | TXT T: %d | STATIC', selected_to_copy_objects[i]['scr_id'], selected_to_copy_objects[i]['modelId'], selected_to_copy_objects[i]['mat_num'],
								selected_to_copy_objects[i]['mat_num_txt']), o_x, o_y, 0xFFFFFF00)
						else
							renderFontDrawText(render_font, string.format('SID: %d | M: %d | TXT: %d | TXT T: %d | DYNAMIC', selected_to_copy_objects[i]['scr_id'], selected_to_copy_objects[i]['modelId'], selected_to_copy_objects[i]['mat_num'],
								selected_to_copy_objects[i]['mat_num_txt']), o_x, o_y, 0xFFFFFF00)
						end
					elseif selected_to_copy_objects[i]['deleted_obj'] and show_deleted_obj then
						if selected_to_copy_objects[i]['is_dynamic'] then
							renderFontDrawText(render_font, string.format('SID: %d | M: %d | TXT: %d | TXT T: %d | STATIC', selected_to_copy_objects[i]['scr_id'], selected_to_copy_objects[i]['modelId'], selected_to_copy_objects[i]['mat_num'],
								selected_to_copy_objects[i]['mat_num_txt']), o_x, o_y, 0xFF696969)
						else
							renderFontDrawText(render_font, string.format('SID: %d | M: %d | TXT: %d | TXT T: %d | DYNAMIC', selected_to_copy_objects[i]['scr_id'], selected_to_copy_objects[i]['modelId'], selected_to_copy_objects[i]['mat_num'],
								selected_to_copy_objects[i]['mat_num_txt']), o_x, o_y, 0xFF696969)
						end
					end
				end
			end
		end
		for i = 1, #selected_to_delete_objects do
			if selected_to_delete_objects[i] ~= nil then
				if isPointOnScreen(selected_to_delete_objects[i]['position']['x'], selected_to_delete_objects[i]['position']['y'], selected_to_delete_objects[i]['position']['z'], 0.0) then
					local o_x, o_y = convert3DCoordsToScreen(selected_to_delete_objects[i]['position']['x'], selected_to_delete_objects[i]['position']['y'],
						selected_to_delete_objects[i]['position']['z'])
					if not selected_to_delete_objects[i]['deleted_obj'] then
						renderFontDrawText(render_font, string.format('SID: %d | M: %d', selected_to_delete_objects[i]['scr_id'], selected_to_delete_objects[i]['modelId']), o_x, o_y, 0xFFFF0000)
					elseif selected_to_delete_objects[i]['deleted_obj'] and show_deleted_obj then
						renderFontDrawText(render_font, string.format('SID: %d | M: %d', selected_to_delete_objects[i]['scr_id'], selected_to_delete_objects[i]['modelId']), o_x, o_y, 0xFF696969)
					end
				end
			end
		end
		if copy_tipe_select == 1 then Draw_3D_Circle(ma_x, ma_y, ma_z, type_two_radius, 0xFF20B2AA) end
	until false
end

function PositionInRadius(cx, cy, cz, radius, x, y, z)
	local dist = getDistanceBetweenCoords3d(cx, cy, cz, x, y, z)
	if dist <= radius then return true end
	return false
end

function PositionOnCuboid(maxx, maxy, maxz, minx, miny, minz, cx, cy, cz)
	if isPointInArea3D(cx, cy, cz, minx, miny, minz, maxx, maxy, maxz) then return true else return false end
end

function isPointInArea3D(px, py, pz, fx, fy, fz, sx, sy, sz)
    local pmin = {x = 0.0, y = 0.0, z = 0.0}
    local pmax = {x = 0.0, y = 0.0, z = 0.0}
    if fx > sx then
        pmax.x = fx
        pmin.x = sx
    else
        pmax.x = sx
        pmin.x = fx
    end
    if fy > sy then
        pmax.y = fy
        pmin.y = sy
    else
        pmax.y = sy
        pmin.y = fy
    end
    if fz > sz then
        pmax.z = fz
        pmin.z = sz
    else
        pmax.z = sz
        pmin.z = fz
    end
    return (px >= pmin.x and pmax.x >= px) and (py >= pmin.y and pmax.y >= py) and (pz >= pmin.z and pmax.z >= pz)
end

function check_data(t, m)
	if tonumber(t) == nil or tonumber(m) == nil then return false end
	if t == 1 then
		if m >= 321 and m <= 328 or m >= 330 and m <= 331 then
			return true
		elseif m >= 333 and m <= 339 or m >= 341 and m <= 373 then
			return true
		elseif m >= 615 and m <= 661 or m == 664 then
			return true
		elseif m >= 669 and m <= 698 or m >= 700 and m <= 792 then
			return true
		elseif m >= 800 and m <= 906 or m >= 910 and m <= 964 then
			return true
		elseif m >= 966 and m <= 998 or m >= 1000 and m <= 1193 then
			return true
		elseif m >= 1207 and m <= 1325 or m >= 1327 and m <= 1572 then
			return true
		elseif m >= 1574 and m <= 1698 or m >= 1700 and m <= 2882 then
			return true
		elseif m >= 2885 and m <= 3135 or m >= 3167 and m <= 3175 then
			return true
		elseif m == 3178 or m == 3187 or m == 3193 or m == 3214 then
			return true
		elseif m == 3221 or m >= 3241 and m <= 3244 then
			return true
		elseif m == 3246 or m >= 3249 and m <= 3250 then
			return true
		elseif m >= 3252 and m <= 3253 or m >= 3255 and m <= 3265 then
			return true
		elseif m >= 3267 and m <= 3347 or m >= 3350 and m <= 3415 then
			return true
		elseif m >= 3417 and m <= 3428 or m >= 3430 and m <= 3609 then
			return true
		elseif m >= 3612 and m <= 3783 or m >= 3785 and m <= 3869 then
			return true
		elseif m >= 3872 and m <= 3882 or m >= 3884 and m <= 3888 then
			return true
		elseif m >= 3890 and m <= 3973 or m >= 3975 and m <= 4541 then
			return true
		elseif m >= 4550 and m <= 4762 or m >= 4806 and m <= 5084 then
			return true
		elseif m >= 5086 and m <= 5089 or m >= 5105 and m <= 5375 then
			return true
		elseif m >= 5390 and m <= 5682 or m >= 5703 and m <= 6010 then
			return true
		elseif m >= 6035 and m <= 6253 or m >= 6255 and m <= 6257 then
			return true
		elseif m >= 6280 and m <= 6347 or m >= 6349 and m <= 6525 then
			return true
		elseif m >= 6863 and m <= 7392 or m >= 7415 and m <= 7973 then
			return true
		elseif m >= 7978 and m <= 9193 or m >= 9205 and m <= 9267 then
			return true
		elseif m >= 9269 and m <= 9478 or m >= 9482 and m <= 10310 then
			return true
		elseif m >= 10315 and m <= 10744 or m >= 10750 and m <= 11417 then
			return true
		elseif m >= 11420 and m <= 11753 or m >= 12800 and m <= 13563 then
			return true
		elseif m >= 13590 and m <= 13667 or m >= 13672 and m <= 13890 then
			return true
		elseif m >= 14383 and m <= 14528 or m >= 14530 and m <= 14554 then
			return true
		elseif m == 14556 or m >= 14558 and m <= 14643 then
			return true
		elseif m >= 14650 and m <= 14657 or m >= 14660 and m <= 14695 then
			return true
		elseif m >= 14699 and m <= 14728 or m >= 14735 and m <= 14765 then
			return true
		elseif m >= 14770 and m <= 14856 or m >= 14858 and m <= 14883 then
			return true
		elseif m >= 14885 and m <= 14898 or m >= 14900 and m <= 14903 then
			return true
		elseif m >= 15025 and m <= 15064 or m >= 16000 and m <= 16790 then
			return true
		elseif m >= 17000 and m <= 17474 or m >= 17500 and m <= 17974 then
			return true
		elseif m == 17976 or m == 17978 or m >= 18000 and m <= 18036 then
			return true
		elseif m >= 18038 and m <= 18102 or m >= 18104 and m <= 18105 then
			return true
		elseif m == 18109 or m == 18112 or m >= 18200 and m <= 18859 then
			return true
		elseif m >= 18860 and m <= 19274 or m >= 19275 and m <= 19595 then
			return true
		elseif m >= 19596 and m <= 19999 then
			return true
		else return false end
	elseif t == 2 then
		if m >= 0 and m <= 15 then
			return true
		else return false end
	end
end

function hook.onCreateObject(objectId, data)
	local temp_object_data = {}
	
	temp_object_data['objectId'] = objectId
	temp_object_data['modelId'] = data.modelId
	temp_object_data['position'] = data.position
	temp_object_data['rotation'] = data.rotation
	temp_object_data['drawDistance'] = data.drawDistance
	temp_object_data['cameraCol'] = data.cameraCol
	temp_object_data['mat_have'] = false
	temp_object_data['mat_num'] = 0
	temp_object_data['mat_num_txt'] = 0
	temp_object_data['scr_id'] = num_ids_created_objects
	temp_object_data['deleted_obj'] = false
	
	-- if not check_data(1, temp_object_data['modelId']) then return false end
	
	if sampGetGamestate() == 2 then temp_object_data['is_dynamic'] = false else temp_object_data['is_dynamic'] = true end
	
	if data.texturesCount > 0 then
		if #data.materials ~= 0 then
			for i = 1, #data.materials do
				local temp_object_mat_data = {}
				
				temp_object_mat_data['objectId'] = data.objectId
				temp_object_mat_data['materialId'] = data.materials[i]['materialId']
				temp_object_mat_data['modelId'] = data.materials[i]['modelId']
				temp_object_mat_data['libraryName'] = data.materials[i]['libraryName']
				temp_object_mat_data['textureName'] = data.materials[i]['textureName']
				temp_object_mat_data['mat_type'] = 1
				
				-- if not check_data(1, temp_object_mat_data['modelId']) and temp_object_mat_data['modelId'] ~= 0 and temp_object_mat_data['modelId'] ~= -1 then return false end
				-- if not check_data(2, temp_object_mat_data['materialId']) then return false end
				
				if data.materials[i]['color'] == 0 then temp_object_mat_data['color'] = '0' else
					temp_object_mat_data['color'] = string.format('0x%X', bit.band(0xFFFFFFFF, data.materials[i]['color']))
				end
				
				temp_object_data['mat_have'] = true
				temp_object_data['mat_num'] = temp_object_data['mat_num'] + 1
				
				table.insert(temp_object_data, temp_object_mat_data)
			end
		end
		if #data.materialText ~= 0 then
			for i = 1, #data.materialText do
				local temp_object_mat_txt_data = {}
				
				temp_object_mat_txt_data['objectId'] = data.objectId
				temp_object_mat_txt_data['materialId'] = data.materialText[i]['materialId']
				temp_object_mat_txt_data['materialSize'] = data.materialText[i]['materialSize']
				temp_object_mat_txt_data['fontName'] = data.materialText[i]['fontName']
				temp_object_mat_txt_data['fontSize'] = data.materialText[i]['fontSize']
				temp_object_mat_txt_data['bold'] = data.materialText[i]['bold']
				temp_object_mat_txt_data['mat_type'] = 2
				
				-- if not check_data(2, temp_object_mat_txt_data['materialId']) then return false end
				
				if data.materialText[i]['fontColor'] == 0 then temp_object_mat_txt_data['fontColor'] = '0' else
					temp_object_mat_txt_data['fontColor'] = string.format('0x%X', bit.band(0xFFFFFFFF, data.materialText[i]['fontColor']))
				end
				
				if data.materialText[i]['backGroundColor'] == 0 then temp_object_mat_txt_data['backGroundColor'] = '0' else
					temp_object_mat_txt_data['backGroundColor'] = string.format('0x%X', bit.band(0xFFFFFFFF, data.materialText[i]['backGroundColor']))
				end
				
				temp_object_mat_txt_data['align'] = data.materialText[i]['align']
				data.materialText[i]['text'] = string.gsub(data.materialText[i]['text'], '\n', '\\n')
				temp_object_mat_txt_data['text'] = data.materialText[i]['text']
				
				temp_object_data['mat_have'] = true
				temp_object_data['mat_num_txt'] = temp_object_data['mat_num_txt'] + 1
				
				table.insert(temp_object_data, temp_object_mat_txt_data)
			end
		end
	end
	
	function hook.onMoveObject(objectId, fromPos, destPos, speed, rotation)
		if temp_object_data['objectId'] == objectId then
			if temp_object_data['position']['x'] ~= destPos.x then temp_object_data['position']['x'] = destPos.x end
			if temp_object_data['position']['y'] ~= destPos.y then temp_object_data['position']['y'] = destPos.y end
			if temp_object_data['position']['z'] ~= destPos.z then temp_object_data['position']['z'] = destPos.z end
			
			if temp_object_data['rotation']['x'] ~= rotation.x and rotation.x ~= -1000.0 then temp_object_data['rotation']['x'] = rotation.x end
			if temp_object_data['rotation']['y'] ~= rotation.y and rotation.y ~= -1000.0 then temp_object_data['rotation']['y'] = rotation.y end
			if temp_object_data['rotation']['z'] ~= rotation.z and rotation.z ~= -1000.0 then temp_object_data['rotation']['z'] = rotation.z end
		end
	end
	
	function hook.onSetObjectMaterial(objectId, data)
		if temp_object_data['objectId'] == objectId then
			local temp_object_mat_data = {}
			
			temp_object_mat_data['objectId'] = objectId
			temp_object_mat_data['materialId'] = data.materialId
			temp_object_mat_data['modelId'] = data.modelId
			temp_object_mat_data['libraryName'] = data.libraryName
			temp_object_mat_data['textureName'] = data.textureName
			temp_object_mat_data['mat_type'] = 1
			
			-- if not check_data(1, temp_object_mat_data['modelId']) and temp_object_mat_data['modelId'] ~= 0 and temp_object_mat_data['modelId'] ~= -1 then return false end
			-- if not check_data(2, temp_object_mat_data['materialId']) then return false end
			
			if data.color == 0 then temp_object_mat_data['color'] = '0' else temp_object_mat_data['color'] = string.format('0x%X', bit.band(0xFFFFFFFF, data.color)) end
			
			temp_object_data['mat_have'] = true
			temp_object_data['mat_num'] = temp_object_data['mat_num'] + 1
			
			table.insert(temp_object_data, temp_object_mat_data)
		end
	end
	
	function hook.onSetObjectMaterialText(objectId, data)
		if temp_object_data['objectId'] == objectId then
			local temp_object_mat_txt_data = {}
			
			temp_object_mat_txt_data['objectId'] = objectId
			temp_object_mat_txt_data['materialId'] = data.materialId
			temp_object_mat_txt_data['materialSize'] = data.materialSize
			temp_object_mat_txt_data['fontName'] = data.fontName
			temp_object_mat_txt_data['fontSize'] = data.fontSize
			temp_object_mat_txt_data['bold'] = data.bold
			temp_object_mat_txt_data['mat_type'] = 2
			
			-- if not check_data(2, temp_object_mat_txt_data['materialId']) then return false end
			
			if data.fontColor == 0 then temp_object_mat_txt_data['fontColor'] = '0' else temp_object_mat_txt_data['fontColor'] = string.format('0x%X', bit.band(0xFFFFFFFF, data.fontColor)) end
			if data.backGroundColor == 0 then temp_object_mat_txt_data['backGroundColor'] = '0' else temp_object_mat_txt_data['backGroundColor'] = string.format('0x%X', bit.band(0xFFFFFFFF,
				data.backGroundColor)) end
				
			temp_object_mat_txt_data['align'] = data.align
			data.text = string.gsub(data.text, '\n', '\\n')
			temp_object_mat_txt_data['text'] = data.text
			
			temp_object_data['mat_have'] = true
			temp_object_data['mat_num_txt'] = temp_object_data['mat_num_txt'] + 1
			
			table.insert(temp_object_data, temp_object_mat_txt_data)
		end
	end
	
	function hook.onSetObjectPosition(objectId, position)
		if temp_object_data['objectId'] == objectId then
			if temp_object_data['position']['x'] ~= position.x then temp_object_data['position']['x'] = position.x end
			if temp_object_data['position']['y'] ~= position.y then temp_object_data['position']['y'] = position.y end
			if temp_object_data['position']['z'] ~= position.z then temp_object_data['position']['z'] = position.z end
		end
	end
	
	function hook.onSetObjectRotation(objectId, rotation)
		if temp_object_data['objectId'] == objectId then
			if temp_object_data['rotation']['x'] ~= rotation.x then temp_object_data['rotation']['x'] = rotation.x end
			if temp_object_data['rotation']['y'] ~= rotation.y then temp_object_data['rotation']['y'] = rotation.y end
			if temp_object_data['rotation']['z'] ~= rotation.z then temp_object_data['rotation']['z'] = rotation.z end
		end
	end
	
	if data.attachToVehicleId ~= nil then
		if data.attachToVehicleId ~= 65535 then
			if not select(1, sampGetCarHandleBySampVehicleId(data.attachToVehicleId)) then return false end
		
			if temp_object_data['position']['x'] ~= data.attachOffsets.x and data.attachOffsets.x < -100.0 or data.attachOffsets.x > 100.0 and data.attachOffsets.x ~= nil then
				temp_object_data['position']['x'] = data.attachOffsets.x else return false end
			if temp_object_data['position']['y'] ~= data.attachOffsets.y and data.attachOffsets.y < -100.0 or data.attachOffsets.y > 100.0 and data.attachOffsets.y ~= nil then
				temp_object_data['position']['y'] = data.attachOffsets.y else return false end
			if temp_object_data['position']['z'] ~= data.attachOffsets.z and data.attachOffsets.z < -100.0 or data.attachOffsets.z > 100.0 and data.attachOffsets.z ~= nil then
				temp_object_data['position']['z'] = data.attachOffsets.z else return false end
				
			if temp_object_data['rotation']['x'] ~= data.attachRotation.x and data.attachRotation.x ~= nil then temp_object_data['rotation']['x'] = data.attachRotation.x end
			if temp_object_data['rotation']['y'] ~= data.attachRotation.y and data.attachRotation.y ~= nil then temp_object_data['rotation']['y'] = data.attachRotation.y end
			if temp_object_data['rotation']['z'] ~= data.attachRotation.z and data.attachRotation.z ~= nil then temp_object_data['rotation']['z'] = data.attachRotation.z end
		end
	end
	
	if data.attachToPlayerId ~= nil then
		if data.attachToPlayerId ~= 65535 then
			if not sampIsPlayerConnected(data.attachToPlayerId) then return false end
		
			if temp_object_data['position']['x'] ~= data.attachOffsets.x and data.attachOffsets.x < -10.0 or data.attachOffsets.x > 10.0 and data.attachOffsets.x ~= nil then
				temp_object_data['position']['x'] = data.attachOffsets.x else return false end
			if temp_object_data['position']['y'] ~= data.attachOffsets.y and data.attachOffsets.y < -10.0 or data.attachOffsets.y > 10.0 and data.attachOffsets.y ~= nil then
				temp_object_data['position']['y'] = data.attachOffsets.y else return false end
			if temp_object_data['position']['z'] ~= data.attachOffsets.z and data.attachOffsets.z < -10.0 or data.attachOffsets.z > 10.0 and data.attachOffsets.z ~= nil then
				temp_object_data['position']['z'] = data.attachOffsets.z else return false end
				
			if temp_object_data['rotation']['x'] ~= data.attachRotation.x and data.attachRotation.x ~= nil then temp_object_data['rotation']['x'] = data.attachRotation.x end
			if temp_object_data['rotation']['y'] ~= data.attachRotation.y and data.attachRotation.y ~= nil then temp_object_data['rotation']['y'] = data.attachRotation.y end
			if temp_object_data['rotation']['z'] ~= data.attachRotation.z and data.attachRotation.z ~= nil then temp_object_data['rotation']['z'] = data.attachRotation.z end
		end
	end

	-- if sampGetGamestate() == 2 then	
		-- if #servers_database_objects ~= 0 then
			-- if temp_object_data['mat_num'] == 0 and temp_object_data['mat_num_txt'] == 0 then
				-- for i = 1, #servers_database_objects do
					-- if servers_database_objects[i] ~= nil then
						-- if servers_database_objects[i]['modelId'] == temp_object_data['modelId'] and
						   -- servers_database_objects[i]['position']['x'] == temp_object_data['position']['x'] and
						   -- servers_database_objects[i]['position']['y'] == temp_object_data['position']['y'] and
						   -- servers_database_objects[i]['position']['z'] == temp_object_data['position']['z'] and
						   -- servers_database_objects[i]['rotation']['x'] == temp_object_data['rotation']['x'] and
						   -- servers_database_objects[i]['rotation']['y'] == temp_object_data['rotation']['y'] and
						   -- servers_database_objects[i]['rotation']['z'] == temp_object_data['rotation']['z'] and
						   -- servers_database_objects[i]['drawDistance'] == temp_object_data['drawDistance'] and
						   -- not servers_database_objects[i]['is_dynamic'] and not temp_object_data['is_dynamic'] and
						   -- servers_database_objects[i]['mat_num'] == 0 and servers_database_objects[i]['mat_num_txt'] == 0 then
							-- servers_database_objects[i] = nil
							-- break
						-- end
					-- end
				-- end
			-- else
				-- for i = 1, #servers_database_objects do
					-- if servers_database_objects[i] ~= nil then
						-- local txt_num_exists = 0
						-- local txt_text_num_exists = 0
						-- if servers_database_objects[i]['modelId'] == temp_object_data['modelId'] and
						   -- servers_database_objects[i]['position']['x'] == temp_object_data['position']['x'] and
						   -- servers_database_objects[i]['position']['y'] == temp_object_data['position']['y'] and
						   -- servers_database_objects[i]['position']['z'] == temp_object_data['position']['z'] and
						   -- servers_database_objects[i]['rotation']['x'] == temp_object_data['rotation']['x'] and
						   -- servers_database_objects[i]['rotation']['y'] == temp_object_data['rotation']['y'] and
						   -- servers_database_objects[i]['rotation']['z'] == temp_object_data['rotation']['z'] and
						   -- servers_database_objects[i]['drawDistance'] == temp_object_data['drawDistance'] and
						   -- servers_database_objects[i]['is_dynamic'] == temp_object_data['is_dynamic'] and
						   -- servers_database_objects[i]['mat_num'] == temp_object_data['mat_num'] and
						   -- servers_database_objects[i]['mat_num_txt'] == temp_object_data['mat_num_txt'] then
							-- for j = 1, #servers_database_objects[i] do
								-- if servers_database_objects[i][j] ~= nil then
									-- if servers_database_objects[i][j]['mat_type'] == 1 then
										-- if servers_database_objects[i][j]['materialId'] == temp_object_data[j]['materialId'] and
										   -- servers_database_objects[i][j]['modelId'] == temp_object_data[j]['modelId'] and
										   -- servers_database_objects[i][j]['libraryName'] == temp_object_data[j]['libraryName'] and
										   -- servers_database_objects[i][j]['textureName'] == temp_object_data[j]['textureName'] and
										   -- servers_database_objects[i][j]['color'] == temp_object_data[j]['color'] then
											-- txt_num_exists = txt_num_exists + 1
										-- end
									-- else
										-- if servers_database_objects[i][j]['materialId'] == temp_object_data[j]['materialId'] and
										   -- servers_database_objects[i][j]['materialSize'] == temp_object_data[j]['materialSize'] and
										   -- servers_database_objects[i][j]['fontName'] == temp_object_data[j]['fontName'] and
										   -- servers_database_objects[i][j]['fontSize'] == temp_object_data[j]['fontSize'] and
										   -- servers_database_objects[i][j]['bold'] == temp_object_data[j]['bold'] and
										   -- servers_database_objects[i][j]['fontColor'] == temp_object_data[j]['fontColor'] and
										   -- servers_database_objects[i][j]['backGroundColor'] == temp_object_data[j]['backGroundColor'] and
										   -- servers_database_objects[i][j]['align'] == temp_object_data[j]['align'] and
										   -- servers_database_objects[i][j]['text'] == temp_object_data[j]['text'] then
											-- txt_text_num_exists = txt_text_num_exists + 1
										-- end
									-- end
								-- end
							-- end
						-- end
						
						-- if servers_database_objects[i]['mat_num'] == txt_num_exists and servers_database_objects[i]['mat_num_txt'] == txt_text_num_exists then
							-- servers_database_objects[i] = nil
							-- break
						-- end
					-- end
				-- end
			-- end
		-- end
	-- end
	
	table.insert(servers_database_objects, temp_object_data)
	num_ids_created_objects = num_ids_created_objects + 1
end

function hook.onDestroyObject(objectId)
	for i = 1, #servers_database_objects do
		if servers_database_objects[i] ~= nil then
			if servers_database_objects[i]['objectId'] == objectId then
				servers_database_objects[i] = nil
				break
			end
		end
	end
end

function hook.onRemoveBuilding(modelId, position, radius)
	local temp_delete_object = {}
	local num_objects_ex = false
	
	temp_delete_object['modelId'] = modelId
	temp_delete_object['position'] = position
	temp_delete_object['radius'] = radius
	temp_delete_object['scr_id'] = num_ids_deleted_objects
	temp_delete_object['deleted_obj'] = false
	
	-- if not check_data(1, temp_delete_object['modelId']) then return false end
	
	-- if #servers_deleted_objects ~= 0 then
		-- for i = 1, #servers_deleted_objects do
			-- if servers_deleted_objects[i] ~= nil then
				-- if servers_deleted_objects[i]['modelId'] == temp_delete_object['modelId'] and
				   -- servers_deleted_objects[i]['position']['x'] == temp_delete_object['position']['x'] and
				   -- servers_deleted_objects[i]['position']['y'] == temp_delete_object['position']['y'] and
				   -- servers_deleted_objects[i]['position']['z'] == temp_delete_object['position']['z'] and
				   -- servers_deleted_objects[i]['radius'] == temp_delete_object['radius'] then
					-- num_objects_ex = true
				-- end
			-- end
		-- end
	-- else
		-- num_objects_ex = true
		-- table.insert(servers_deleted_objects, temp_delete_object)
		-- num_ids_deleted_objects = num_ids_deleted_objects + 1
	-- end
	
	-- if not num_objects_ex then
		table.insert(servers_deleted_objects, temp_delete_object)
		num_ids_deleted_objects = num_ids_deleted_objects + 1
	-- end	
end

-- function onSendPacket(id, bitStream, priority, reliability, orderingChannel)
	-- if id == 24 then
		-- for i = 1, #servers_database_objects do
			-- if servers_database_objects[i] ~= nil then
				-- servers_database_objects[i] = nil
			-- end
			-- if servers_deleted_objects[i] ~= nil then
				-- servers_deleted_objects[i] = nil
			-- end
		-- end
	-- end
-- end

function fso_un(arg)
	local debug_id = io.open('debug_map', 'w+')
	
	local act_dd = auto_set_dd
	
	for i = 1, #servers_database_objects do
		if servers_database_objects[i] ~= nil then
			local set_dd = 'STREAMER_OBJECT_DD'
			local set_dd_d = '0.0'
			if act_dd then
				if servers_database_objects[i]['drawDistance'] > 0 then
					set_dd = tostring(servers_database_objects[i]['drawDistance'])
					set_dd_d = tostring(servers_database_objects[i]['drawDistance'])
					
					if set_dd == nil and set_dd_d == nil then
						set_dd = 'STREAMER_OBJECT_DD'
						set_dd_d = '0.0'
					else
						set_dd = tostring(math.floor(servers_database_objects[i]['drawDistance'])) .. '.0'
						set_dd_d = tostring(math.floor(servers_database_objects[i]['drawDistance'])) .. '.0'
					end
				else
					set_dd = 'STREAMER_OBJECT_DD'
					set_dd_d = '0.0'
				end
			else
				set_dd = 'STREAMER_OBJECT_DD'
				set_dd_d = '0.0'
			end
			if servers_database_objects[i]['mat_num'] == 0 and servers_database_objects[i]['mat_num_txt'] == 0 then
				local is_object_have_col = ''
				if servers_database_objects[i]['cameraCol'] == 1 then is_object_have_col = 'fso_map = ' else is_object_have_col = '' end
				if servers_database_objects[i]['is_dynamic'] then
					debug_id:write(string.format('%sCreateDynamicObject(%d, %f, %f, %f, %f, %f, %f, %d, %d, -1, STREAMER_OBJECT_SD, %s); // %d', is_object_have_col, servers_database_objects[i]['modelId'],
						servers_database_objects[i]['position']['x'], servers_database_objects[i]['position']['y'], servers_database_objects[i]['position']['z'],
							servers_database_objects[i]['rotation']['x'], servers_database_objects[i]['rotation']['y'], servers_database_objects[i]['rotation']['z'],
								int_world, int_interior, set_dd, servers_database_objects[i]['mat_num'] + servers_database_objects[i]['mat_num_txt']) .. '\n')
					if is_object_have_col ~= '' then debug_id:write(string.format('SetDynamicObjectNoCameraCol(fso_map);') .. '\n') end
				else
					debug_id:write(string.format('%sCreateObject(%d, %f, %f, %f, %f, %f, %f, %s); // %d', is_object_have_col, servers_database_objects[i]['modelId'], servers_database_objects[i]['position']['x'],
						servers_database_objects[i]['position']['y'], servers_database_objects[i]['position']['z'], servers_database_objects[i]['rotation']['x'],
							servers_database_objects[i]['rotation']['y'], servers_database_objects[i]['rotation']['z'], set_dd_d, servers_database_objects[i]['mat_num'] +
								servers_database_objects[i]['mat_num_txt']) .. '\n')
					if is_object_have_col ~= '' then debug_id:write(string.format('SetObjectNoCameraCol(fso_map);') .. '\n') end
				end
			else
				if servers_database_objects[i]['is_dynamic'] then
					debug_id:write(string.format('fso_map = CreateDynamicObject(%d, %f, %f, %f, %f, %f, %f, %d, %d, -1, STREAMER_OBJECT_SD, %s); // %d', servers_database_objects[i]['modelId'],
						servers_database_objects[i]['position']['x'], servers_database_objects[i]['position']['y'], servers_database_objects[i]['position']['z'],
							servers_database_objects[i]['rotation']['x'], servers_database_objects[i]['rotation']['y'], servers_database_objects[i]['rotation']['z'],
								int_world, int_interior, set_dd, servers_database_objects[i]['mat_num'] + servers_database_objects[i]['mat_num_txt']) .. '\n')
					if servers_database_objects[i]['cameraCol'] == 1 then debug_id:write(string.format('SetDynamicObjectNoCameraCol(fso_map);') .. '\n') end
					for j = 1, #servers_database_objects[i] do
						if servers_database_objects[i][j] ~= nil then
							if servers_database_objects[i][j]['mat_type'] == 1 then
								debug_id:write(string.format('SetDynamicObjectMaterial(fso_map, %d, %d, "%s", "%s", %s);', servers_database_objects[i][j]['materialId'],
									servers_database_objects[i][j]['modelId'], servers_database_objects[i][j]['libraryName'], servers_database_objects[i][j]['textureName'],
										servers_database_objects[i][j]['color']) .. '\n')
							else
								debug_id:write(string.format('SetDynamicObjectMaterialText(fso_map, %d, "%s", %d, "%s", %d, %d, %s, %s, %d);', servers_database_objects[i][j]['materialId'],
									servers_database_objects[i][j]['text'], servers_database_objects[i][j]['materialSize'], servers_database_objects[i][j]['fontName'],
										servers_database_objects[i][j]['fontSize'], servers_database_objects[i][j]['bold'], servers_database_objects[i][j]['fontColor'],
											servers_database_objects[i][j]['backGroundColor'], servers_database_objects[i][j]['align']) .. '\n')
							end
						end
					end
				else
					debug_id:write(string.format('fso_map = CreateObject(%d, %f, %f, %f, %f, %f, %f, %s); // %d', servers_database_objects[i]['modelId'],
						servers_database_objects[i]['position']['x'], servers_database_objects[i]['position']['y'], servers_database_objects[i]['position']['z'],
							servers_database_objects[i]['rotation']['x'], servers_database_objects[i]['rotation']['y'], servers_database_objects[i]['rotation']['z'],
								set_dd_d, servers_database_objects[i]['mat_num'] + servers_database_objects[i]['mat_num_txt']) .. '\n')
					if servers_database_objects[i]['cameraCol'] == 1 then debug_id:write(string.format('SetObjectNoCameraCol(fso_map);') .. '\n') end
					for j = 1, #servers_database_objects[i] do
						if servers_database_objects[i][j] ~= nil then
							if servers_database_objects[i][j]['mat_type'] == 1 then
								debug_id:write(string.format('SetObjectMaterial(fso_map, %d, %d, "%s", "%s", %s);', servers_database_objects[i][j]['materialId'],
									servers_database_objects[i][j]['modelId'], servers_database_objects[i][j]['libraryName'], servers_database_objects[i][j]['textureName'],
										servers_database_objects[i][j]['color']) .. '\n')
							else
								debug_id:write(string.format('SetObjectMaterialText(fso_map, "%s", %d, %d, "%s", %d, %d, %s, %s, %d);', servers_database_objects[i][j]['text'],
									servers_database_objects[i][j]['materialId'], servers_database_objects[i][j]['materialSize'], servers_database_objects[i][j]['fontName'],
										servers_database_objects[i][j]['fontSize'], servers_database_objects[i][j]['bold'], servers_database_objects[i][j]['fontColor'],
											servers_database_objects[i][j]['backGroundColor'], servers_database_objects[i][j]['align']) .. '\n')
							end
						end
					end
				end
			end
		end
	end
	
	for i = 1, #servers_deleted_objects do
		if servers_deleted_objects[i] ~= nil then
			debug_id:write(string.format('RemoveBuildingForPlayer(playerid, %d, %f, %f, %f, %f);', servers_deleted_objects[i]['modelId'],
				servers_deleted_objects[i]['position']['x'], servers_deleted_objects[i]['position']['y'], servers_deleted_objects[i]['position']['z'],
					servers_deleted_objects[i]['radius']) .. '\n')
		end
	end
	
	sampAddChatMessage('[FSO SIX] Дамп базы объектов скрипта сохранен в папке игры с названием debug_map', 0xFFFFD700)
	debug_id:close()
end