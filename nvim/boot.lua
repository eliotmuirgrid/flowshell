function FileRead(Name)
   local File = io.open(Name, "r")
   if not File then
      return nil
   end
   local Content = File:read("*a")
   File:close()
   return Content
end

function KeyGet(Name)
   local F = os.getenv('HOME').."/."..Name;
   local C = FileRead(F);
   local V = C:match("^KEY%s*=%s*(.-)%s*$")
   return V;
end

function FilterTrimBegin(String, Search)
   local Start, End = String:find(Search,1,true)
   if not Start then
     print("Not found"); 
     return String
   end
   return String:sub(End+1)
end

function FilterTrimEnd(String, Search)
   local LastStart

   local Pos = 1
   while true do
      local Start = String:find(Search, Pos, true)
      if not Start then
         break
      end
      LastStart = Start
      Pos = Start + 1
   end

   if not LastStart then
      return String
   end

   return String:sub(1, LastStart - 1)
end

function JsonEncode(T)
   return vim.json.encode(T);
end

-- Returns {code=<code>, stdout=out, stderr=err}
function Call(CommandArray)
   return vim.system(CommandArray, {text=true}):wait();
end

function HttpPost(T)
   local url     = T.url
   local headers = T.headers
   local data    = T.data 
   local A = {"curl", "-s", url};
   if headers then
      for k, v in pairs(headers) do
         A[#A+1] = "-H"
         A[#A+1] = k .. ": " .. v
      end
   end
   if data then
      A[#A+1] = '-d';
      A[#A+1] = JsonEncode(data)
   end
   local Result =  Call(A).stdout; 
   return Result;
end

function BeginInsert(text)
    local lines = vim.split(text, "\n", { plain = true })

    vim.api.nvim_buf_set_lines(
        0, 0, 0,
        false,
        lines
    )
end

function JsonUnescape(s)
   s=s:gsub('\\n', '\n');
   s=s:gsub('\\u2013', '–');
   s=s:gsub('\\u2014', '—');
   s=s:gsub('\\u201c', '“');
   s=s:gsub('\\u201d', '”');
   s=s:gsub('\\u2026', '…');
   s=s:gsub('\\u2019', '’');
   s=s:gsub('\\u00e9', 'é');
   s=s:gsub('\\u00e0', 'è');
   s=s:gsub('\\u00e8', 'è');
   s=s:gsub(' \\ud83e\\udd8e ',' '); -- gets rid of those blasted creepy Iguanas 
   s=s:gsub('\\u00f6', 'o'); -- TODO 0  
   s=s:gsub('\\"', '"');
   s=s:gsub("\\'", "'");
   return s 
end

--vim.json.decode(s);

AgentGpt = function(Prompt)
   local Key = KeyGet('chatgpt');
   local P = {}
   P.url = 'https://api.openai.com/v1/responses';
   P.headers = {}
   --print(Key)
   P.headers["Authorization"] = 'Bearer '..Key;
   P.headers["Content-Type"] = 'application/json';
   P.data = {model="gpt-4.1", input=Prompt}
   local Response = HttpPost(P);
   Response = FilterTrimBegin(Response,'"text": \"');
   Response = FilterTrimEnd(Response,'"role": "assistant"')
   Response = FilterTrimEnd(Response, '"');
   Response = JsonUnescape(Response);
   return Response;
end

AgentLama = function(Prompt)
   local P = {}
   P.url = 'http://localhost:11434/api/generate'
   P.headers = {}
   P.headers["Content-Type"] = 'application/json'
   P.data = {
      model  = "llama3.2",
      prompt = Prompt,
      stream = false
   }
   local Response = HttpPost(P)
   Response = FilterTrimBegin(Response,'"response":\"');
   Response = FilterTrimEnd(Response,'"done":true')
   Response = FilterTrimEnd(Response, '"');
   Response = JsonUnescape(Response);
   return Response;
end

function StripExtension(FileName)
  return FileName:gsub("%.[^.]+$", "")
end

function BufferCompleteGet()
   -- Get all lines from the current buffer                                  
   local buf = vim.api.nvim_get_current_buf()                                
   local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)               
   local content = table.concat(lines, "\n")  
   return content;
end

-- TODO should be more soft coded.
local Path = os.getenv('HOME').."/flowshell/nvim/"

for Name in vim.fs.dir(Path) do
   if Name ~= 'boot.lua' and Name:sub(1,1) ~= "." then
      local FName = StripExtension(Name);
      local Func, Args = dofile(Path..Name);
      if type(Args)~= 'table' then
        Args={}
      end
      vim.api.nvim_create_user_command(FName, Func,Args); 
   end
end
