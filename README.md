# Samp Stealers — Collection of various SA:MP stealers

**English** | [Русский](#readme-на-русском)

---

> ℹ️ **Fork Notice:** This repository is a **fork** of the original [samp_stealers](https://github.com/f0Re3t/samp_stealers) project by **[f0Re3t](https://github.com/f0Re3t)**. All credits for the scripts go to the original author. This fork translates the code comments and UI strings from Russian to English, and adds this bilingual (English/Russian) README.

## Overview

A collection of MoonLoader scripts for GTA San Andreas multiplayer (SA:MP) designed to steal and extract various server-side elements such as objects, textdraws, 3D text labels, dialogs, and vehicle-attached objects. All scripts are developed by **f0Re3t**.

### Files / Scripts

| File | Description |
|---|---|
| [fso.lua](#fsolua---object-stealer) | Objects stealer (with materials/textures/text) |
| [fstd.lua](#fstdlua---textdraw-stealer) | Textdraws stealer (global & player) |
| [3d text stealer.lua](#3d-text-stealerlua---3d-text-stealer) | 3D Texts stealer |
| [dialogs.lua](#dialogslua---dialog-stealer) | Dialogs stealer |
| [vaos.lua](#vaoslua---vehicle-attached-objects-stealer) | Vehicle Attached Objects stealer |

---

## fso.lua - Object Stealer

**FSO SIX** — Powerful server object stealer. Copies objects (with their textures/material texts) and removed buildings from a SA:MP server and generates Pawn code for sa-mp-plugin/streamer.

### Features
- Collects all objects from the server stream into an internal database
- Tracks object movements, material changes, and position/rotation updates in real-time
- Records deleted/removed buildings (RemoveBuildingForPlayer)
- Two selection modes: **Cuboid** shape (box) and **Radius** shape (circle)
- Auto-capture of interior ID and draw distance
- On-screen display of object info and database stats
- Generates ready-to-use Pawn source code

### Commands

| Command | Description |
|---|---|
| `/fso [filename]` | Start stealing process — creates file, then step-by-step wizard |
| `/fso_w [world]` | Set virtual world for copied objects (0 = disable) |
| `/fso_d CO [id]` / `/fso_d DO [id]` | Mark/unmark objects for exclusion from copy/delete lists |
| `/fso_i` | Toggle auto interior ID capture |
| `/fso_dd` | Toggle auto draw distance capture |
| `/fso_sdo` | Toggle display of deleted objects on screen |
| `/fso_info` | Toggle on-screen info display |
| `/fso_un` | Dump entire object database to `debug_map` file |

### Usage Flow
1. Type `/fso mapping_name` to create a new mapping file
2. Walk to where you want to set the spawn point, then press Enter again
3. Choose stealing type: `1` for cuboid, `2` for radius
4. For cuboid: walk to minimum corner → walk to maximum corner
5. For radius: walk to center → enter radius value (1-5000)
6. Objects will render on screen with IDs; use `/fso_d` to exclude any
7. Press Enter again to save the mapping to file

---

## fstd.lua - TextDraw Stealer

**FSTD** — Steals global and player textdraws from SA:MP servers.

### Features
- Captures all textdraw properties: position, color, size, font, box, shadow, outline, preview models, etc.
- Tracks text changes via `TextDrawSetString`
- Separates global textdraws (ID < 2048) and player textdraws (ID >= 2048)
- Generates ready-to-use Pawn source code with arrays and show commands

### Commands

| Command | Description |
|---|---|
| `/fstd [filename]` | Start/stop textdraw stealing. Type once to begin capture, type again to save |

### Usage Flow
1. Type `/fstd my_tds` — script starts capturing all textdraws shown on screen
2. Navigate through server menus to display all textdraws you want
3. Type `/fstd my_tds` again — saves all captured textdraws to `FSTD/<server>/my_tds`

### Controls
- **VK_X** (X key) — Toggle textdraw list GUI (for dialogs.lua-like interface; not applicable here)

---

## 3d text stealer.lua - 3D Text Stealer

**FS3DT** — Steals 3D text labels from SA:MP servers.

### Features
- Captures all 3D text labels in stream: ID, color, position, distance, LOS, attached player/vehicle, text
- Real-time tracking of label creation and removal
- GUI window with sortable columns
- Right-click to edit generated code before saving
- Generates `Create3DTextLabel` / `Attach3DTextLabelToPlayer` / `Attach3DTextLabelToVehicle` Pawn code

### Controls
- **VK_Z** (Z key) — Toggle the GUI window
- **Double-click** a row — save that 3D text label to file
- **Right-click** a row — open code editor popup

---

## dialogs.lua - Dialog Stealer

**FSD** — Steals server dialog texts from SA:MP servers.

### Features
- Captures dialog ID, style (MSGBOX, INPUT, LIST, PASSWORD, TABLIST, TABLIST_HEADERS), title, text, and buttons
- Automatic duplicate detection (doesn't store identical dialogs)
- GUI window with sortable columns
- Generates `ShowPlayerDialog` Pawn code
- Right-click to edit generated code before saving

### Controls
- **VK_X** (X key) — Toggle the GUI window
- **Double-click** a row — save that dialog to file
- **Right-click** a row — open code editor popup

---

## vaos.lua - Vehicle Attached Objects Stealer

**VAOS** — Steals objects attached to vehicles from SA:MP servers.

### Features
- Captures all objects attached to vehicles: model, position, rotation, materials, material texts
- Records attachment offsets and rotations
- Generates vehicle creation + object creation + attachment Pawn code
- Supports both dynamic (CreateDynamicObject) and static (CreateObject) objects
- GPLv3 licensed

### Commands

| Command | Description |
|---|---|
| `/vaos [vehicle_id]` | Steal attached objects from the specified vehicle ID in stream |

### Usage Flow
1. Find a vehicle with attached objects in your stream
2. Type `/vaos [vehicle_id]` (e.g., `/vaos 42`)
3. Script saves vehicle creation and all attached objects to `VAOS/<ip_port>/<vehicle_id>`

---

## Installation

1. Install [MoonLoader](https://gtaforums.com/topic/890961-moonloader/) for GTA San Andreas
2. Copy the `.lua` files into the `moonloader` folder in your GTA SA directory
3. Launch the game, join a SA:MP server
4. Use the commands described above

### Required Libraries
- `lib.samp.events` (samp.events)
- `imgui` (for GUI-based stealers)
- `vkeys` (for key bindings)
- `encoding` (for CP1251/UTF8 conversion)
- `numberlua` / `bit` / `bitex` (for bit operations)
- `vector3d` (for FSO)

---

## License

This project is a collection of scripts by **f0Re3t**. Individual files may have their own license headers (vaos.lua is GPLv3).

---

> ℹ️ **Форк:** Этот репозиторий является **форком** оригинального проекта [samp_stealers](https://github.com/f0Re3t/samp_stealers) от **[f0Re3t](https://github.com/f0Re3t)**. Все права на скрипты принадлежат оригинальному автору. Этот форк переводит комментарии и строки интерфейса с русского на английский, а также добавляет двуязычный (английский/русский) README.

# README на русском

## Обзор

Коллекция MoonLoader-скриптов для GTA San Andreas multiplayer (SA:MP), предназначенная для стиллинга (извлечения/копирования) различных серверных элементов: объектов, текстдро, 3D-текстов, диалогов и объектов, прикрепленных к транспорту. Все скрипты разработаны **f0Re3t**.

### Файлы / Скрипты

| Файл | Описание |
|---|---|
| [fso.lua](#fsolua---стиллер-объектов) | Стиллер объектов (с материалами/текстурами/текстом) |
| [fstd.lua](#fstdlua---стиллер-текстдро) | Стиллер текстдро (глобальных и игроков) |
| [3d text stealer.lua](#3d-text-stealerlua---стиллер-3d-текстов) | Стиллер 3D-текстов |
| [dialogs.lua](#dialogslua---стиллер-диалогов) | Стиллер диалогов |
| [vaos.lua](#vaoslua---стиллер-объектов-на-транспорте) | Стиллер объектов, прикрепленных к транспорту |

---

## fso.lua - Стиллер объектов

**FSO SIX** — Мощный стиллер серверных объектов. Копирует объекты (с их текстурами/материальными текстами) и удаленные здания с сервера SA:MP и генерирует Pawn-код для sa-mp-plugin/streamer.

### Возможности
- Собирает все объекты из серверного стрима во внутреннюю базу данных
- Отслеживает перемещения объектов, изменения материалов, позиции и вращения в реальном времени
- Записывает удаленные здания (RemoveBuildingForPlayer)
- Два режима выделения: **Кубоидная** форма (прямоугольник) и **Радиусная** форма (круг)
- Автоматический захват ID интерьера и дальности прорисовки
- Отображение информации об объектах и статистики БД на экране
- Генерирует готовый к использованию Pawn-исходный код

### Команды

| Команда | Описание |
|---|---|
| `/fso [имя_файла]` | Запуск процесса стиллинга — создает файл, затем пошаговый мастер |
| `/fso_w [мир]` | Установка виртуального мира для копируемых объектов (0 = отключить) |
| `/fso_d CO [id]` / `/fso_d DO [id]` | Пометка/снятие пометки объектов для исключения из копирования/удаления |
| `/fso_i` | Включение/отключение авто-захвата интерьера |
| `/fso_dd` | Включение/отключение авто-захвата дальности прорисовки |
| `/fso_sdo` | Включение/отключение показа удаленных объектов на экране |
| `/fso_info` | Включение/отключение информации на экране |
| `/fso_un` | Дамп всей базы объектов в файл `debug_map` |

### Порядок использования
1. Введите `/fso имя_маппинга` для создания файла
2. Подойдите к месту, где хотите установить точку спавна, нажмите Enter
3. Выберите тип стиллинга: `1` — кубоид, `2` — радиус
4. Для кубоида: подойдите к минимальному углу → подойдите к максимальному углу
5. Для радиуса: подойдите к центру → введите значение радиуса (1-5000)
6. Объекты отобразятся на экране с ID; используйте `/fso_d` для исключения
7. Нажмите Enter снова для сохранения маппинга в файл

---

## fstd.lua - Стиллер текстдро

**FSTD** — Стиллит глобальные и игроковские текстдро с серверов SA:MP.

### Возможности
- Захватывает все свойства текстдро: позицию, цвет, размер, шрифт, бокс, тень, контур, модель для предпросмотра и т.д.
- Отслеживает изменения текста через TextDrawSetString
- Разделяет глобальные текстдро (ID < 2048) и игроковские (ID >= 2048)
- Генерирует готовый Pawn-код с массивами и командами показа

### Команды

| Команда | Описание |
|---|---|
| `/fstd [имя_файла]` | Старт/стоп стиллинга. Введите один раз для начала захвата, введите снова для сохранения |

### Порядок использования
1. Введите `/fstd мои_тд` — скрипт начнет захватывать все показываемые текстдро
2. Пройдите по серверным меню, чтобы отобразить все нужные текстдро
3. Введите `/fstd мои_тд` снова — сохранит все захваченные текстдро в `FSTD/<сервер>/мои_тд`

---

## 3d text stealer.lua - Стиллер 3D-текстов

**FS3DT** — Стиллит 3D-текстовые метки с серверов SA:MP.

### Возможности
- Захватывает все 3D-тексты в стриме: ID, цвет, позицию, дистанцию, LOS, привязку к игроку/ТС, текст
- Отслеживает создание и удаление меток в реальном времени
- GUI-окно с сортируемыми колонками
- Правый клик для редактирования кода перед сохранением
- Генерирует код `Create3DTextLabel` / `Attach3DTextLabelToPlayer` / `Attach3DTextLabelToVehicle`

### Управление
- **VK_Z** (клавиша Z) — открытие/закрытие GUI-окна
- **Двойной клик** по строке — сохранение 3D-текста в файл
- **Правый клик** по строке — открытие редактора кода

---

## dialogs.lua - Стиллер диалогов

**FSD** — Стиллит тексты серверных диалогов с SA:MP.

### Возможности
- Захватывает ID диалога, стиль (MSGBOX, INPUT, LIST, PASSWORD, TABLIST, TABLIST_HEADERS), заголовок, текст и кнопки
- Автоматическое обнаружение дубликатов (не сохраняет одинаковые диалоги)
- GUI-окно с сортируемыми колонками
- Генерирует код `ShowPlayerDialog`
- Правый клик для редактирования кода перед сохранением

### Управление
- **VK_X** (клавиша X) — открытие/закрытие GUI-окна
- **Двойной клик** по строке — сохранение диалога в файл
- **Правый клик** по строке — открытие редактора кода

---

## vaos.lua - Стиллер объектов на транспорте

**VAOS** — Стиллит объекты, прикрепленные к транспортным средствам, с серверов SA:MP.

### Возможности
- Захватывает все объекты, прикрепленные к ТС: модель, позиция, вращение, материалы, материальные тексты
- Записывает смещения и вращения прикрепления
- Генерирует Pawn-код создания ТС + создания объектов + прикрепления
- Поддерживает как динамические (CreateDynamicObject), так и статические (CreateObject) объекты
- Лицензия GPLv3

### Команды

| Команда | Описание |
|---|---|
| `/vaos [id_тс]` | Стиллинг объектов, прикрепленных к указанному ID транспорта в стриме |

### Порядок использования
1. Найдите ТС с прикрепленными объектами в своем стриме
2. Введите `/vaos [id_тс]` (например, `/vaos 42`)
3. Скрипт сохранит создание ТС и всех прикрепленных объектов в `VAOS/<ip_порт>/<id_тс>`

---

## Установка

1. Установите [MoonLoader](https://gtaforums.com/topic/890961-moonloader/) для GTA San Andreas
2. Скопируйте файлы `.lua` в папку `moonloader` в директории GTA SA
3. Запустите игру, зайдите на сервер SA:MP
4. Используйте команды, описанные выше

### Необходимые библиотеки
- `lib.samp.events` (samp.events)
- `imgui` (для GUI-стиллеров)
- `vkeys` (для привязки клавиш)
- `encoding` (для конвертации CP1251/UTF8)
- `numberlua` / `bit` / `bitex` (для битовых операций)
- `vector3d` (для FSO)

---

## Лицензия

Этот проект представляет собой коллекцию скриптов от **f0Re3t**. Отдельные файлы могут иметь собственные заголовки лицензий (vaos.lua распространяется под GPLv3).