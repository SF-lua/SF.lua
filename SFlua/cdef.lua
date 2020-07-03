--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: GNU General Public License v3.0
    Authors: look in file <AUTHORS>.
]]

local ffi = require 'ffi'

ffi.cdef[[
    typedef unsigned int UINT;
    typedef unsigned char BYTE;
    typedef unsigned long DWORD;
    typedef unsigned short WORD;
    typedef char *PCHAR;
    typedef const char *PCSTR;
    typedef long HRESULT;
    typedef int INT;
    typedef void *HWND;

    typedef unsigned long D3DCOLOR;
    typedef unsigned long TICK;
    typedef int           BOOL;

    typedef int            GTAREF; // gta pool reference (scm handle)
    typedef unsigned short ID;     // player, vehicle, object, etc
    typedef unsigned char  NUMBER;
    typedef void(__cdecl* CMDPROC)(const char*);

    typedef struct _stdstring {
        union {
            char  str[16];
            char *pstr;
        };
        size_t length;
        size_t allocated;
    } stdstring;

    typedef struct {
        int left, top, right, bottom;
    } RECT;

    typedef struct {
        struct ID3DXFont_vtbl *vtbl;
    } ID3DXFont;

    struct ID3DXFont_vtbl
    {
        void *QueryInterface, *AddRef;
        uint32_t(__stdcall *Release)(ID3DXFont* font);
        void *GetDevice, *GetDescA, *GetDescW, *GetTextMetricsA, *GetTextMetricsW,
             *GetDC, *GetGlyphData, *PreloadCharacters, *PreloadGlyphs,
             *PreloadTextA, *PreloadTextW;
        int(__stdcall *DrawTextA)(ID3DXFont *font, void *pSprite, const char *pString, int Count, RECT *pRect, uint32_t Format, uint32_t Color);
        void* DrawTextW;
        void(__stdcall *OnLostDevice)(ID3DXFont* font);
        void(__stdcall *OnResetDevice)(ID3DXFont* font);
    };

    typedef struct {
        float x, y, z;
    } CVector;

    typedef struct {
        CVector       right;
        unsigned long flags;
        CVector       up;
        float         pad_u;
        CVector       at;
        float         pad_a;
        CVector       pos;
        float         pad_p;    
    } CMatrix;

    struct DXUTComboBoxItem
    {
        char strText[256];
        void *pData;
        RECT rcActive;
        bool bVisible;
    };
]]