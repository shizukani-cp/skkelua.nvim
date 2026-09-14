-- 擬似プリエディット (preedit.ts に相当)
-- Virtual Text を活用することで
-- Vim 上に IME の PreEdit を擬似的に実現する

local M = {}

---@class skkelua.PreEdit
---@field private current string
---@field private kakutei string
local PreEdit = {}
PreEdit.__index = PreEdit

function PreEdit.new()
	return setmetatable({
		current = "",
		kakutei = "",
		ns_id = vim.api.nvim_create_namespace("skkelua_preedit"),
	}, PreEdit)
end

---@param str string
function PreEdit:do_kakutei(str)
	self.kakutei = self.kakutei .. str
end

--- 次の表示状態を受け取り、表示を行う
---@param str string
function PreEdit:sync(str)
	local kakutei_str = self.kakutei -- 確定した文字を保持

	self.current = str
	self.kakutei = ""

	-- Virtual Text の更新
	local bufnr = 0
	vim.api.nvim_buf_clear_namespace(bufnr, self.ns_id, 0, -1)
	if self.current ~= "" then
		local cursor = vim.api.nvim_win_get_cursor(0)
		local line, col = cursor[1] - 1, cursor[2]
		vim.api.nvim_buf_set_extmark(bufnr, self.ns_id, line, col, {
			virt_text = { { self.current, "Search" } },
			virt_text_pos = "inline",
		})
	end

	-- 確定した文字だけを feedkeys 側に返してバッファへ書き込ませる
	return kakutei_str
end

--- 表示中として追跡しているテキストを返す
---@return string
function PreEdit:shown()
	return self.current
end

--- virtual textとcurrent、kakuteiの内容をクリアする
function PreEdit:clear()
	self:sync("")
end

--- 次の表示状態を受け取り、表示を行う
---@param str string
function PreEdit:output(next_str)
	return self:sync(next_str)
end

M.PreEdit = PreEdit

return M
