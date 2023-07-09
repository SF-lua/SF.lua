--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: MIT License
    Author: imring
]]

local sampapi = require 'sampapi'
local shared = require 'sampapi.shared'
local ffi = shared.ffi

require 'sflua.cdef.dxut'
local dialog = sampapi.require('CDialog', true)

function sampGetDialogInfoPtr()
    return shared.get_pointer(dialog.RefDialog())
end
jit.off(sampGetDialogInfoPtr, true)

function sampShowDialog(id, caption, text, button1, button2, style)
    dialog.RefDialog():Show(id, style, caption, text, button1, button2, false)
end
jit.off(sampShowDialog, true)

function sampCloseCurrentDialogWithButton(button)
    dialog.RefDialog():Close(button)
end
jit.off(sampCloseCurrentDialogWithButton, true)

function sampGetCurrentDialogListItem()
    local listbox = ffi.cast('char*', dialog.RefDialog().m_pListbox)
    return ffi.cast('int*', listbox + 0x143)[0] -- CDXUTListBox::m_nSelected
end
jit.off(sampGetCurrentDialogListItem, true)

function sampSetCurrentDialogListItem(list)
    local listbox = ffi.cast('char*', dialog.RefDialog().m_pListbox)
    ffi.cast('int*', listbox + 0x143)[0] = list -- CDXUTListBox::m_nSelected
end
jit.off(sampSetCurrentDialogListItem, true)

function sampGetCurrentDialogEditboxText()
    return ffi.string(dialog.RefDialog().m_pEditbox:GetText())
end
jit.off(sampGetCurrentDialogEditboxText, true)

function sampSetCurrentDialogEditboxText(text)
    dialog.RefDialog().m_pEditbox:SetText(text, false)
end
jit.off(sampSetCurrentDialogEditboxText, true)

function sampIsDialogActive()
    return dialog.RefDialog().m_bIsActive ~= 0
end
jit.off(sampIsDialogActive, true)

function sampGetCurrentDialogType()
    return dialog.RefDialog().m_nType
end
jit.off(sampGetCurrentDialogType, true)

function sampGetCurrentDialogId()
    return dialog.RefDialog().m_nId
end
jit.off(sampGetCurrentDialogId, true)

function sampGetDialogCaption()
    return ffi.string(dialog.RefDialog().m_szCaption)
end
jit.off(sampGetDialogCaption, true)

function sampGetDialogText()
    return ffi.string(dialog.RefDialog().m_szText)
end
jit.off(sampGetDialogText, true)

function sampIsDialogClientside()
    return dialog.RefDialog().m_bServerside == 0
end
jit.off(sampIsDialogClientside, true)

function sampSetDialogClientside(client)
    dialog.RefDialog().m_bServerside = client and 0 or 1
end
jit.off(sampSetDialogClientside, true)

function sampGetListboxItemsCount()
    local listbox = ffi.cast('char*', dialog.RefDialog().m_pListbox)
    return ffi.cast('int*', listbox + 0x150)[0] -- CDXUTListBox::m_Items::m_nSize
end
jit.off(sampGetListboxItemsCount, true)

function sampGetListboxItemText(list)
    list = tonumber(list) or 0
    local listbox = ffi.cast('char*', dialog.RefDialog().m_pListbox)
    if list >= 0 and sampGetListboxItemsCount() - 1 >= list then
        local data = ffi.cast('struct DXUTComboBoxItem***', listbox + 0x14C)[0] -- CDXUTListBox::m_Items::m_pData
        return ffi.string(data[list].strText)
    end
    return ''
end
jit.off(sampGetListboxItemText, true)