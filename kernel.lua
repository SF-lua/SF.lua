--[[
	Authors: FYP, imring, DonHomka.
	Thanks BH Team for development.
	Structuers/addresses/other were taken in s0beit 0.3.7: https://github.com/BlastHackNet/mod_s0beit_sa
	http://blast.hk/ (ñ) 2018.
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
typedef int HWND;
typedef bool BOOL;

typedef struct _stdvector
{
	float x, y, z;
} stdvector;

typedef struct _stdstring {
	union {
		char str[16];
		char* pstr;
	};
	size_t length;
	size_t allocated;
} stdstring;

typedef void(__cdecl *CMDPROC) (PCHAR);

typedef DWORD D3DCOLOR;

typedef struct stRECT
{
    int left, top, right, bottom;
} RECT;

typedef struct stID3DXFont
{
    struct ID3DXFont_vtbl* vtbl;
} ID3DXFont;

struct ID3DXFont_vtbl
{
    void* QueryInterface; // STDMETHOD(QueryInterface)(THIS_ REFIID iid, LPVOID *ppv) PURE;
    void* AddRef; // STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    uint32_t (__stdcall * Release)(ID3DXFont* font); // STDMETHOD_(ULONG, Release)(THIS) PURE;

    // ID3DXFont
    void* GetDevice; // STDMETHOD(GetDevice)(THIS_ LPDIRECT3DDEVICE9 *ppDevice) PURE;
    void* GetDescA; // STDMETHOD(GetDescA)(THIS_ D3DXFONT_DESCA *pDesc) PURE;
    void* GetDescW; // STDMETHOD(GetDescW)(THIS_ D3DXFONT_DESCW *pDesc) PURE;
    void* GetTextMetricsA; // STDMETHOD_(BOOL, GetTextMetricsA)(THIS_ TEXTMETRICA *pTextMetrics) PURE;
    void* GetTextMetricsW; // STDMETHOD_(BOOL, GetTextMetricsW)(THIS_ TEXTMETRICW *pTextMetrics) PURE;

    void* GetDC; // STDMETHOD_(HDC, GetDC)(THIS) PURE;
    void* GetGlyphData; // STDMETHOD(GetGlyphData)(THIS_ UINT Glyph, LPDIRECT3DTEXTURE9 *ppTexture, RECT *pBlackBox, POINT *pCellInc) PURE;

    void* PreloadCharacters; // STDMETHOD(PreloadCharacters)(THIS_ UINT First, UINT Last) PURE;
    void* PreloadGlyphs; // STDMETHOD(PreloadGlyphs)(THIS_ UINT First, UINT Last) PURE;
    void* PreloadTextA; // STDMETHOD(PreloadTextA)(THIS_ LPCSTR pString, INT Count) PURE;
    void* PreloadTextW; // STDMETHOD(PreloadTextW)(THIS_ LPCWSTR pString, INT Count) PURE;

    int (__stdcall * DrawTextA)(ID3DXFont* font, void* pSprite, const char* pString, int Count, RECT* pRect, uint32_t Format, uint32_t Color); // STDMETHOD_(INT, DrawTextA)(THIS_ LPD3DXSPRITE pSprite, LPCSTR pString, INT Count, LPRECT pRect, DWORD Format, D3DCOLOR Color) PURE;
    void* DrawTextW; // STDMETHOD_(INT, DrawTextW)(THIS_ LPD3DXSPRITE pSprite, LPCWSTR pString, INT Count, LPRECT pRect, DWORD Format, D3DCOLOR Color) PURE;

    void (__stdcall * OnLostDevice)(ID3DXFont* font); // STDMETHOD(OnLostDevice)(THIS) PURE;
    void (__stdcall * OnResetDevice)(ID3DXFont* font); // STDMETHOD(OnResetDevice)(THIS) PURE;
};

void * memcpy( void * destptr, const void * srcptr, size_t num );
void *malloc(size_t size);
void free( void * ptrmem );
void * memset( void * memptr, int val, size_t num );
void *realloc(void *ptr, size_t newsize);
]]

local k = {}

function k.getStruct(struct_name, mem)
	return ffi.cast('struct '..struct_name..'*', mem)
end

function k.getAddressByCData(cdata)
	return tonumber(ffi.cast('intptr_t', ffi.cast('void*', cdata)))
end

function k.explode_color(color)
	local a = bit.band(bit.rshift(color, 24), 0xFF)
	local r = bit.band(bit.rshift(color, 16), 0xFF)
	local g = bit.band(bit.rshift(color, 8), 0xFF)
	local b = bit.band(color, 0xFF)
	return a, r, g, b
 end

 function k.join_color(a, r, g, b)
	local color = b  -- b
	color = bit.bor(color, bit.lshift(g, 8))  -- g
	color = bit.bor(color, bit.lshift(r, 16)) -- r
	color = bit.bor(color, bit.lshift(a, 24)) -- a
	return color
 end

function k.convertARGBToRGBA(color)
	local color = tonumber(color)
	local a, r, g, b = k.explode_color(color)
	return k.join_color(r, g, b, a)
end

function k.convertRGBAToARGB(color)
	local color = tonumber(color)
	local r, g, b, a = k.explode_color(color)
	return k.join_color(a, r, g, b)
end

function k.tonumber(value, name)
	local v = assert(tonumber(value), 'Value '..tostring(value)..' is not number.')
	return tonumber(v)
end

function k.boolean(value, name)
	assert(type(value) == 'boolean', 'Type value is not boolean.')
end

return k
