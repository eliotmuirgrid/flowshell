function Insert(text)
    local lines = vim.split(text, "\n", { plain = true })

    vim.api.nvim_buf_set_lines(
        0, 0, 0,
        false,
        lines
    )
end

function Call(Command)
   return vim.fn.system(Command);
end

function StripExtension(FileName)
  return FileName:gsub("%.[^.]+$", "")
end

local Path = os.getenv('HOME').."/command/nvim/"

for Name in vim.fs.dir(Path) do
   local FName = StripExtension(Name);
   if FName ~= 'boot' then
      local Func = require(FName);
      vim.api.nvim_create_user_command(FName, Func, {nargs="+"});
   end
end
