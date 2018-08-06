if arg[1] == "time" then
	fp = io.popen ("date '+%l:%M'")
	io.write (" ")
	for line in fp:lines() do
		print(line)
	end
	fp:close()
end
