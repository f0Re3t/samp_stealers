local hook = require('lib.samp.events')
local bitex = require('lib.bitex')
local bit = require('bit')

local start_copy = 0
local f_id = 0
local g_td_base = { }

function main()
	if not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	
	sampAddChatMessage('[FSTD] Скрипт успешно загружен / перезагружен, удачного использования!', 0x20B2AA)
	
	sampRegisterChatCommand('fstd', fstd)
end

function fstd(arg)
	if start_copy == 0 then
		arg = tostring(arg)
		if arg == nil or arg == '' then return sampAddChatMessage('[FSTD] Кривое название файла!', 0xFF4500) end
		local serv_name = sampGetCurrentServerName()
		serv_name = serv_name:gsub('[|%%%[%]! :\\/*|"<>•!' .. string.char(0x08) .. string.char(0x3F) .. ']', '_')
		arg = arg:gsub('[|%%%[%]! :\\/*|"<>•!' .. string.char(0x08) .. string.char(0x3F) .. ']', '_')
		if not doesDirectoryExist('FSTD') then createDirectory('FSTD') end
		if not doesDirectoryExist(string.format('FSTD\\%s', serv_name)) then createDirectory(string.format('FSTD\\%s', serv_name)) end
		if not doesFileExist(string.format('FSTD\\%s\\%s', serv_name, arg)) then
			f_id = io.open(string.format('FSTD\\%s\\%s', serv_name, arg), 'a+')
			sampAddChatMessage('[FSTD] Все показанные далее текстдравы будут скопированы в файл!', 0xFFA500)
			start_copy = 1
		else sampAddChatMessage('[FSTD] Файл с таким названием существует уже!', 0xFF4500) end
	elseif start_copy == 1 then
		local num_glob_td = 0;
		local num_play_td = 0;
		
		for i = 1, #g_td_base do
			if g_td_base[i]['textdrawId'] < 2048 then
				num_glob_td = num_glob_td + 1;
			else
				num_play_td = num_play_td + 1;
			end
		end
		
		if num_glob_td > 0 then f_id:write(string.format('new Text:fstd[%d];', num_glob_td) .. '\n') end
		if num_play_td > 0 then f_id:write(string.format('new PlayerText:fstd_p[MAX_PLAYERS][%d];', num_play_td) .. '\n') end
		
		local num_glob_cyc = num_glob_td
		local num_play_cyc = num_play_td
		
		for i = 1, #g_td_base do
			local byteBox = bitex.bextract(g_td_base[i]['flags'], 0, 1)
			local byteLeft = bitex.bextract(g_td_base[i]['flags'], 1, 1)
			local byteRight = bitex.bextract(g_td_base[i]['flags'], 2, 1)
			local byteCenter = bitex.bextract(g_td_base[i]['flags'], 3, 1)
			local byteProportional = bitex.bextract(g_td_base[i]['flags'], 4, 1)
			local bytePadding = bitex.bextract(g_td_base[i]['flags'], 5, 3)
			
			local alg = 0
			if byteLeft ~= 0 and byteRight == 0 and byteCenter == 0 then
				alg = 1
			elseif byteLeft == 0 and byteRight ~= 0 and byteCenter == 0 then
				alg = 3
			elseif byteLeft == 0 and byteRight == 0 and byteCenter ~= 0 then
				alg = 2
			else
				alg = 0
			end
			
			if g_td_base[i]['textdrawId'] < 2048 then
				num_glob_cyc = num_glob_cyc - 1
				f_id:write('\n' .. string.format('fstd[%d] = TextDrawCreate(%f, %f, "%s");', num_glob_cyc, g_td_base[i]['position']['x'], g_td_base[i]['position']['y'], g_td_base[i]['text']) .. '\n')
				f_id:write(string.format('TextDrawLetterSize(fstd[%d], %f, %f);', num_glob_cyc, g_td_base[i]['letterWidth'], g_td_base[i]['letterHeight']) .. '\n')
				f_id:write(string.format('TextDrawTextSize(fstd[%d], %f, %f);', num_glob_cyc, g_td_base[i]['lineWidth'], g_td_base[i]['lineHeight']) .. '\n')
				f_id:write(string.format('TextDrawAlignment(fstd[%d], %d);', num_glob_cyc, alg) .. '\n')
				f_id:write(string.format('TextDrawColor(fstd[%d], %s);', num_glob_cyc, string.format('0x%08X', bit.bor(bit.rshift(argb_to_rgba(g_td_base[i]['letterColor']), 24), bit.lshift(argb_to_rgba(g_td_base[i]['letterColor']), 8)))) .. '\n')
				f_id:write(string.format('TextDrawUseBox(fstd[%d], %d);', num_glob_cyc, byteBox) .. '\n')
				f_id:write(string.format('TextDrawBoxColor(fstd[%d], %s);', num_glob_cyc, string.format('0x%08X', bit.bor(bit.rshift(argb_to_rgba(g_td_base[i]['boxColor']), 24), bit.lshift(argb_to_rgba(g_td_base[i]['boxColor']), 8)))) .. '\n')
				f_id:write(string.format('TextDrawSetShadow(fstd[%d], %d);', num_glob_cyc, g_td_base[i]['shadow']) .. '\n')
				f_id:write(string.format('TextDrawSetOutline(fstd[%d], %d);', num_glob_cyc, g_td_base[i]['outline']) .. '\n')
				f_id:write(string.format('TextDrawBackgroundColor(fstd[%d], %s);', num_glob_cyc, string.format('0x%08X', bit.bor(bit.rshift(argb_to_rgba(g_td_base[i]['backgroundColor']), 24), bit.lshift(argb_to_rgba(g_td_base[i]['backgroundColor']), 8)))) .. '\n')
				f_id:write(string.format('TextDrawFont(fstd[%d], %d);', num_glob_cyc, g_td_base[i]['style']) .. '\n')
				f_id:write(string.format('TextDrawSetProportional(fstd[%d], %d);', num_glob_cyc, byteProportional) .. '\n')
				f_id:write(string.format('TextDrawSetSelectable(fstd[%d], %d);', num_glob_cyc, g_td_base[i]['selectable']) .. '\n')
				
				if g_td_base[i]['style'] == 5 then
					f_id:write(string.format('TextDrawSetPreviewModel(fstd[%d], %d);', num_glob_cyc, g_td_base[i]['modelId']) .. '\n')
					f_id:write(string.format('TextDrawSetPreviewRot(fstd[%d], %f, %f, %f, %f);', num_glob_cyc, g_td_base[i]['rotation']['x'], g_td_base[i]['rotation']['y'], g_td_base[i]['rotation']['z'], g_td_base[i]['zoom']) .. '\n')
					
					if g_td_base[i]['modelId'] >= 400 and g_td_base[i]['modelId'] <= 611 then
						f_id:write(string.format('TextDrawSetPreviewVehCol(fstd[%d], %d, %d);', num_glob_cyc, g_td_base[i]['color'], g_td_base[i]['color2']) .. '\n')
					end
				end
			else
				num_play_cyc = num_play_cyc - 1
				f_id:write('\n' .. string.format('fstd_p[playerid][%d] = CreatePlayerTextDraw(playerid, %f, %f, "%s");', num_play_cyc, g_td_base[i]['position']['x'], g_td_base[i]['position']['y'], g_td_base[i]['text']) .. '\n')
				f_id:write(string.format('PlayerTextDrawLetterSize(playerid, fstd_p[playerid][%d], %f, %f);', num_play_cyc, g_td_base[i]['letterWidth'], g_td_base[i]['letterHeight']) .. '\n')
				f_id:write(string.format('PlayerTextDrawTextSize(playerid, fstd_p[playerid][%d], %f, %f);', num_play_cyc, g_td_base[i]['lineWidth'], g_td_base[i]['lineHeight']) .. '\n')
				f_id:write(string.format('PlayerTextDrawAlignment(playerid, fstd_p[playerid][%d], %d);', num_play_cyc, alg) .. '\n')
				f_id:write(string.format('PlayerTextDrawColor(playerid, fstd_p[playerid][%d], %s);', num_play_cyc, string.format('0x%08X', bit.bor(bit.rshift(argb_to_rgba(g_td_base[i]['letterColor']), 24), bit.lshift(argb_to_rgba(g_td_base[i]['letterColor']), 8)))) .. '\n')
				f_id:write(string.format('PlayerTextDrawUseBox(playerid, fstd_p[playerid][%d], %d);', num_play_cyc, byteBox) .. '\n')
				f_id:write(string.format('PlayerTextDrawBoxColor(playerid, fstd_p[playerid][%d], %s);', num_play_cyc, string.format('0x%08X', bit.bor(bit.rshift(argb_to_rgba(g_td_base[i]['boxColor']), 24), bit.lshift(argb_to_rgba(g_td_base[i]['boxColor']), 8)))) .. '\n')
				f_id:write(string.format('PlayerTextDrawSetShadow(playerid, fstd_p[playerid][%d], %d);', num_play_cyc, g_td_base[i]['shadow']) .. '\n')
				f_id:write(string.format('PlayerTextDrawSetOutline(playerid, fstd_p[playerid][%d], %d);', num_play_cyc, g_td_base[i]['outline']) .. '\n')
				f_id:write(string.format('PlayerTextDrawBackgroundColor(playerid, fstd_p[playerid][%d], %s);', num_play_cyc, string.format('0x%08X', bit.bor(bit.rshift(argb_to_rgba(g_td_base[i]['backgroundColor']), 24), bit.lshift(argb_to_rgba(g_td_base[i]['backgroundColor']), 8)))) .. '\n')
				f_id:write(string.format('PlayerTextDrawFont(playerid, fstd_p[playerid][%d], %d);', num_play_cyc, g_td_base[i]['style']) .. '\n')
				f_id:write(string.format('PlayerTextDrawSetProportional(playerid, fstd_p[playerid][%d], %d);', num_play_cyc, byteProportional) .. '\n')
				f_id:write(string.format('PlayerTextDrawSetSelectable(playerid, fstd_p[playerid][%d], %d);', num_play_cyc, g_td_base[i]['selectable']) .. '\n')
				
				if g_td_base[i]['style'] == 5 then
					f_id:write(string.format('PlayerTextDrawSetPreviewModel(playerid, fstd_p[playerid][%d], %d);', num_play_cyc, g_td_base[i]['modelId']) .. '\n')
					f_id:write(string.format('PlayerTextDrawSetPreviewRot(playerid, fstd_p[playerid][%d], %f, %f, %f, %f);', num_play_cyc, g_td_base[i]['rotation']['x'], g_td_base[i]['rotation']['y'], g_td_base[i]['rotation']['z'], g_td_base[i]['zoom']) .. '\n')
					
					if g_td_base[i]['modelId'] >= 400 and g_td_base[i]['modelId'] <= 611 then
						f_id:write(string.format('PlayerTextDrawSetPreviewVehCol(playerid, fstd_p[playerid][%d], %d, %d);', num_play_cyc, g_td_base[i]['color'], g_td_base[i]['color2']) .. '\n')
					end
				end
			end
		end
		
		num_glob_cyc = num_glob_td
		num_play_cyc = num_play_td
		
		for i = 1, #g_td_base do
			if i == 1 then f_id:write('\n') end
			if g_td_base[i]['textdrawId'] < 2048 then
				num_glob_cyc = num_glob_cyc - 1
				f_id:write(string.format('TextDrawShowForPlayer(playerid, fstd[%d]);', num_glob_cyc) .. '\n')
			else
				num_play_cyc = num_play_cyc - 1
				f_id:write(string.format('PlayerTextDrawShow(playerid, fstd_p[playerid][%d]);', num_play_cyc) .. '\n')
			end
		end
		
		sampAddChatMessage('[FSTD] Текстдравы успешно скопированы и сохранены в файл!', 0xFFA500)
		start_copy = 0
		f_id:close()
		for i = 1, #g_td_base do
			g_td_base[i] = nil
		end
	end
end

function hook.onTextDrawSetString(td, str)
	if #g_td_base ~= 0 then
		for i = 1, #g_td_base do
			if g_td_base[i]['textdrawId'] == td then
				if g_td_base[i]['text'] ~= str then g_td_base[i]['text'] = str end
			end
		end
	end
end

function hook.onShowTextDraw(td, d)
	if start_copy == 1 then
		local l_td_base = { }
		local num_td_ex = 0
		l_td_base['textdrawId'] = td
		l_td_base['flags'] = d.flags
		l_td_base['letterWidth'] = d.letterWidth
		l_td_base['letterHeight'] = d.letterHeight
		l_td_base['letterColor'] = d.letterColor
		l_td_base['lineWidth'] = d.lineWidth
		l_td_base['lineHeight'] = d.lineHeight
		l_td_base['boxColor'] = d.boxColor
		l_td_base['shadow'] = d.shadow
		l_td_base['outline'] = d.outline
		l_td_base['backgroundColor'] = d.backgroundColor
		l_td_base['style'] = d.style
		l_td_base['selectable'] = d.selectable
		l_td_base['position'] = d.position
		l_td_base['modelId'] = d.modelId
		l_td_base['rotation'] = d.rotation
		l_td_base['zoom'] = d.zoom
		l_td_base['color'] = d.color
		l_td_base['color2'] = d.color2
		l_td_base['text'] = d.text
		if #g_td_base ~= 0 then
			for i = 1, #g_td_base do
				if g_td_base[i]['textdrawId'] == l_td_base['textdrawId'] then num_td_ex = 1 end
			end
		else return table.insert(g_td_base, l_td_base) end
		if num_td_ex == 0 then return table.insert(g_td_base, l_td_base) end
	end
end

function explode_argb(argb)
	local a = bit.band(bit.rshift(argb, 24), 0xFF)
	local r = bit.band(bit.rshift(argb, 16), 0xFF)
	local g = bit.band(bit.rshift(argb, 8), 0xFF)
	local b = bit.band(argb, 0xFF)
	return a, r, g, b
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8))
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function argb_to_rgba(argb)
	local a, r, g, b = explode_argb(argb)
	return join_argb(a, b, g, r)
end