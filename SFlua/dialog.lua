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

function sampShowDialog(id, caption, text, button1, button2, style)
    dialog.RefDialog():Show(id, style, caption, text, button1, button2, false)
end

function sampCloseCurrentDialogWithButton(button)
    dialog.RefDialog():Close(button)
end

function sampGetCurrentDialogListItem()
    local listbox = ffi.cast('char*', dialog.RefDialog().m_pListbox)
    return ffi.cast('int*', listbox + 0x143)[0] -- CDXUTListBox::m_nSelected
end

function sampSetCurrentDialogListItem(list)
    local listbox = ffi.cast('char*', dialog.RefDialog().m_pListbox)
    ffi.cast('int*', listbox + 0x143)[0] = list -- CDXUTListBox::m_nSelected
end

function sampGetCurrentDialogEditboxText()
    return ffi.string(dialog.RefDialog().m_pEditbox:GetText())
end

function sampSetCurrentDialogEditboxText(text)
    dialog.RefDialog().m_pEditbox:SetText(text, false)
end

function sampIsDialogActive()
    return dialog.RefDialog().m_bIsActive ~= 0
end

function sampGetCurrentDialogType()
    return dialog.RefDialog().m_nType
end

function sampGetCurrentDialogId()
    return dialog.RefDialog().m_nId
end

function sampGetDialogCaption()
    return ffi.string(dialog.RefDialog().m_szCaption)
end

function sampGetDialogText()
    return ffi.string(dialog.RefDialog().m_szText)
end

function sampIsDialogClientside()
    return dialog.RefDialog().m_bServerside == 0
end

function sampSetDialogClientside(client)
    dialog.RefDialog().m_bServerside = client and 0 or 1
end

function sampGetListboxItemsCount()
    local listbox = ffi.cast('char*', dialog.RefDialog().m_pListbox)
    return ffi.cast('int*', listbox + 0x150)[0] -- CDXUTListBox::m_Items::m_nSize
end

function sampGetListboxItemText(list)
    list = tonumber(list) or 0
    local listbox = ffi.cast('char*', dialog.RefDialog().m_pListbox)
    if list >= 0 and sampGetListboxItemsCount() - 1 >= list then
        local data = ffi.cast('struct DXUTComboBoxItem***', listbox + 0x14C)[0] -- CDXUTListBox::m_Items::m_pData
        return ffi.string(data[list].strText)
    end
    return ''
end