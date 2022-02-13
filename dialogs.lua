local h = require('lib.samp.events')
local i = require('imgui')
local k = require('vkeys')
local e = require('encoding')
local b = require('bit')

e.default = 'CP1251'

local act_menu = i.ImBool(false)
local act_type = i.ImBuffer(4097)

local FSD_base = { }
local f_id = -1

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	sampAddChatMessage('[FSD] Скрипт успешно загружен / перезагружен, удачного использования!', 0xAFEEEE)
	sampAddChatMessage('[FSD] Автор всея творения f0Re3t!', 0xAFEEEE)
	while true do
		wait(0)
		if wasKeyPressed(k.VK_X) and not sampIsChatInputActive() and not sampIsDialogActive() and f_id ~= -1 then act_menu.v = not act_menu.v end
		i.Process = act_menu.v
	end
end

function h.onInitGame(playerId, hostName, settings, vehicleModels, unknown)
	if f_id == -1 then
		local serv_name = hostName
		serv_name = serv_name:gsub('[|%%%[%]! :\\/*|"<>Х!' .. string.char(0x08) .. string.char(0x3F) .. ']', '_')
		if not doesDirectoryExist('FSD') then createDirectory('FSD') end
		if not doesFileExist(string.format('FSD\\%s', serv_name)) then
			f_id = io.open(string.format('FSD\\%s', serv_name), 'a+')
			sampAddChatMessage('[FSD] Файл создан, двойное нажатие в спсике сохранит выбранный диалог в файл!', 0xFFA500)
		else
			f_id = io.open(string.format('FSD\\%s', serv_name), 'w+')
			sampAddChatMessage('[FSD] Файл сервера уже существуюет, удаляем!', 0xFFA500)
		end
	end
end

function h.onShowDialog(dialogId, style, title, button1, button2, text)
	local FSD_temp = { }
	FSD_temp['dialogId'] = dialogId
	FSD_temp['style'] = style
	FSD_temp['title'] = title
	FSD_temp['button1'] = button1
	FSD_temp['button2'] = button2
	FSD_temp['text'] = text
	
	local num_fsd_ex = 0
	
	if #FSD_base ~= 0 then
		for m = 1, #FSD_base do
			if FSD_base[m] ~= nil then
				if style == FSD_base[m]['style'] and title == FSD_base[m]['title'] and text == FSD_base[m]['text'] then num_fsd_ex = num_fsd_ex + 1 end
			end
		end
		if num_fsd_ex == 0 then table.insert(FSD_base, FSD_temp) end
	else
		table.insert(FSD_base, FSD_temp)
	end
end

function i.OnDrawFrame()
	if act_menu.v then
		local sx, sy = getScreenResolution()
		i.SetNextWindowSize(i.ImVec2(800, 500), i.Cond.FirstUseEver)
		i.SetNextWindowPos(i.ImVec2((sx / 2) - 400, (sy / 2) - 250), i.Cond.FirstUseEver, i.ImVec2(0, 0))
		i.Begin(e.UTF8(string.format('Стиллер Текстов Диалога (В Базе %d Текстов)', #FSD_base)), act_menu,
			i.WindowFlags.NoResize + i.WindowFlags.NoMove + i.WindowFlags.NoCollapse + i.WindowFlags.NoScrollbar + i.WindowFlags.NoBringToFrontOnFocus + i.WindowFlags.NoScrollWithMouse)
		i.Columns(4)
		i.Separator()
		i.NewLine()
		i.SameLine(2)
		i.Text(e.UTF8('Ид'))
		i.SetColumnWidth(-1, 60)
		i.NextColumn()
		i.Text(e.UTF8('Стиль'))
		i.SetColumnWidth(-1, 230)
		i.NextColumn()
		i.Text(e.UTF8('Заголовок'))
		i.SetColumnWidth(-1, 250)
		i.NextColumn()
		i.Text(e.UTF8('Текст'))
		i.SetColumnWidth(-1, 260)
		i.NextColumn()
		i.Columns(1)
		i.Separator()
		i.BeginChild('##ScrollingRegion', i.ImVec2(0, 0), false)
		i.Columns(4)
		for m = 1, #FSD_base do
			if FSD_base[m] ~= nil then
				local text = string.gsub(FSD_base[m]['text'], '\n', '\\n')
				local dlg_style = ''
				if FSD_base[m]['style'] == 0 then dlg_style = 'DIALOG_STYLE_MSGBOX'
					elseif FSD_base[m]['style'] == 1 then dlg_style = 'DIALOG_STYLE_INPUT'
					elseif FSD_base[m]['style'] == 2 then dlg_style = 'DIALOG_STYLE_LIST'
					elseif FSD_base[m]['style'] == 3 then dlg_style = 'DIALOG_STYLE_PASSWORD'
					elseif FSD_base[m]['style'] == 4 then dlg_style = 'DIALOG_STYLE_TABLIST'
					elseif FSD_base[m]['style'] == 5 then dlg_style = 'DIALOG_STYLE_TABLIST_HEADERS'
					else dlg_style = 'error auth'
				end
				
				local ed_code = ''
				ed_code = e.UTF8(string.format('ShowPlayerDialog(playerid, %d, %s, "%s", "%s", "%s", "%s");', FSD_base[m]['dialogId'], dlg_style,
					FSD_base[m]['title'], text, FSD_base[m]['button1'], FSD_base[m]['button2']))
				
				if i.Selectable(m, false, i.SelectableFlags.SpanAllColumns + i.SelectableFlags.AllowDoubleClick) then
					if i.IsMouseDoubleClicked(0) then
						if f_id ~= -1 then
							f_id:write(ed_code .. '\n\n')
							f_id:flush()
							sampAddChatMessage('[FSD] Выбранный текст диалога записан в файл!', 0xFFA500)
						else
							sampAddChatMessage('[FSD] Ошибка сохранения в файл!', 0xFF4500)
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
				i.SetColumnWidth(-1, 60)
				i.NextColumn()
				i.Text(e.UTF8(string.format('%s', dlg_style)))
				i.SetColumnWidth(-1, 230)
				i.NextColumn()
				i.Text(e.UTF8(string.format('%s', FSD_base[m]['title'])))
				i.SetColumnWidth(-1, 250)
				i.NextColumn()
				i.Text(e.UTF8(string.format('%s', text)))
				i.SetColumnWidth(-1, 260)
				i.NextColumn()
			end
		end
		i.Columns(1)
		if #FSD_base == 0 then
			i.SameLine(5.0)
			i.Text(e.UTF8('Диалогов в базе скрипта нет'))
		end
		i.Separator()
		i.EndChild()
		i.End()
	end
end

function onScriptTerminate(s, quitGame)
	if s == thisScript() then
		showCursor(false)
	end
end