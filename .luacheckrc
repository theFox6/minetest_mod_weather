max_line_length = false

read_globals = {
	"dump2",
	"minetest",
	"vector",
	"VoxelManip",
	"VoxelArea",
	table = { fields = {
			"copy"
	} },
	lightning = {
		fields = {
			auto = {
				read_only = false
			}
		},
		other_fields = true
	},
}

globals = {
	"weather",
}

exclude_files = {"weather/development/"}

ignore = {
	--unused variables
	"21.",
	--whitespace
	"61.",
}
