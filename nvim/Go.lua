function VIMtraceTable(tbl, indent, visited)
    indent = indent or ""
    visited = visited or {}
    if visited[tbl] then
        print(indent .. "<recursive table>")
        return
    end
    visited[tbl] = true
    print(indent .. "{")
    for key, value in pairs(tbl) do
        local prefix = indent
            .. "  ["
            .. tostring(key)
            .. "] = "
        if type(value) == "table" then
            io.write(prefix)
            VIMtraceTable(value, indent .. "  ", visited)
        elseif type(value) == "string" then
            print(prefix .. string.format("%q", value))
        else
            print(prefix .. tostring(value))
        end
    end
    print(indent .. "}")
end

function trace(value)
    local value_type = type(value)
    if value_type == "table" then
        VIMtraceTable(value)
    elseif value_type == "string" then
        print(string.format("%q", value))
    elseif value_type == "nil" then
        print("nil")
    else
        print(tostring(value))
    end
end

function trace(X)
   print(X);
end	

function VIMcurrentWord()
   return vim.fn.expand("<cword>");
end

function VIMprefixRemainder(s)
   return s:match("^([A-Z]+)(.*)$")
end

function VIMeditFile(FileName)
   vim.cmd("edit " .. vim.fn.fnameescape(FileName))
end	

function VIMgoCpp()
   local Symbol            = VIMcurrentWord();
   local Prefix, Remainder = VIMprefixRemainder(Symbol);
   local File = "../"..Prefix.."/"..Prefix..Remainder..".cpp"
   trace(File);
   VIMeditFile(File);
end	

function VIMgoMd()
   local line = vim.fn.getline(".")
   trace(line)
   local file = string.match(line, "%(([^)]*)%)")
   trace(file or "")
   if file and file ~= "" then
      vim.cmd("edit " .. vim.fn.fnameescape(file))
   end
end

local Go = function(Arg)
   trace(Arg);
   local Ext = vim.fn.expand("%:e");
   if (Ext == "cpp") then VIMgoCpp() end;
   if (Ext ==  "md") then VIMgoMd () end;
end

return Go, {nargs="?"};
