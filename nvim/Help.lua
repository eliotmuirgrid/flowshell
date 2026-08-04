local F = function(opts)
   local Topic = opts.args;
   local Buffer = BufferCompleteGet();

   local Definition = Agent(Topic..":"..Buffer);
   BeginInsert(Definition);
end

return F, {nargs="+"}
