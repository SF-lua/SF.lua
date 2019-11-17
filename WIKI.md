# ВВЕДЕНИЕ
SF_LUA - мощный инструмент для работы с GTA San Andreas MultiPlayer. Библиотека содержит в себе все функции взаимодействия с клиентом SA:MP 0.3.7.

## Функции чата
`uint chatPtr = sampGetChatInfoPtr()` - возвращает адрес начала структуры чата

`sampAddChatMessage(zstring text, uint color)` - вывод сообщения в чат клиента

`sampAddChatMessageEx(int type, zstring text, zstring prefix, uint color, uint pcolor)` - вывод расширеных сообщений в чат клиента

`sampSendChat(zstring text)` - отправляет строку `text` на сервер игнорируя клиентский обработчик чата. Если строка начинается с правого слэша (/) будет отправлено команда
`bool result = sampIsChatInputActive()` - возвращает статус поля ввода чата. true - чат открыт, false - закрыт

`sampSetChatInputEnabled(bool enabled)` - устанавливает активность поля ввода чата

`bool result = sampRegisterChatCommand(zstring cmd, function func)` - регистрирует клиентскую команду чата при вводе которой будет вызван колбек `func`. В `func` передается единственный аргумент - всё что было введено после команды. Функция вернет false в случае ошибки регистрации команды

`bool result = sampUnregisterChatCommand(zstring cmd)` - удаляет клиентскую команду. По аналогии с `sampRegisterChatCommand` вернет false в случае ошибки

`bool result = sampIsChatCommandDefined(zstring cmd)` - проверяет существование клинтской команды

`zstring text - sampGetChatInputText()` - возвращает текст находящийся в поле ввода чата

`sampSetChatInputText(zstring text)` - устанавливает значения поля ввода чата

`zstring text, zstring prefix, uint color, uint pcolor = sampGetChatString(int id)` - возвращает тест, префикс, цвет текста и профикса строки в чате по ID

`sampSetChatString(int id, zstring text, zstring prefix, uint color, uint pcolor)` - устанавливает тест, префикс, цвет текста и префикса строки в чате по ID

`bool result = sampIsChatVisible()` - возвращает статус видимости чата

`int mode = sampGetChatDisplayMode()` - возвращает текущий тип показа чата. 0 - стантартный, 1 - полупрозрачный, 2 - невидимый

`sampSetChatDisplayMode(int mode)` - устанавливает тип показа чата

`sampProcessChatInput(zstring text)` - отправляет строку `text` клиентскому обработчику чата, что позволяет вызывать локальные команды


## Функции диалогов
`uint dialogPtr = sampGetDialogInfoPtr()` - возвращает адрес начала структуры диалогов

`sampShowDialog(int id, zstring caption, zstring text, zstring button1, zstring button2, int style)` - показывает локальный диалог

`bool result, int button, int list, zstring input = sampHasDialogRespond(int id)` - получает данные из локального диалога по ID

`sampCloseCurrentDialogWithButton(int button)` - закрывает диалог с нажатием левой (1) или правой (0) клавиши диалога

`int list = sampGetCurrentDialogListItem()` - возвращает текущую позицию выделеного элемента в списке

`sampSetCurrentDialogListItem(int list)` - устанавливает текущую позиция выделеного элемента в списке

`zstring text = sampGetCurrentDialogEditboxText()` - возвращает текст находящийся в поле ввода диалога

`sampSetCurrentDialogEditboxText(zstring text)` - устанавливает текст в поле ввода диалога

`bool result = sampIsDialogActive()` - проверяет открыт диалог или нет

`int type = sampGetCurrentDialogType()` - возвращает тип активного диалога

`int id = sampGetCurrentDialogId()` - возвращает ID активного диалога

`zstring text = sampGetDialogText()` - возращает текст активного диалога

`zstring caption = sampGetDialogCaption()` - возвращает заголовок активного диалога

`sampSendDialogResponse(int id, int button, int listitem, zstring input)` - отправляет на сервер события взаимодействия с диалогом

`sampSetDialogClientside(bool clientside)` - устанавливает будет ли отправляеться на сервер информация взаимодействия с диалогами

`bool result = sampIsDialogClientside()` - возвращает текщие настройки отправки информации о взаимодействии с диалогами

``
``
``