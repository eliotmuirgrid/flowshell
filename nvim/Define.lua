local Define = function(opts)
   local Topic = opts.args;
   local Definition = Call("agent:chatgpt 'Define "..Topic.. " in a few paragraphs'");
   Insert("# "..Topic.."\n"..Definition);
end

return Define
