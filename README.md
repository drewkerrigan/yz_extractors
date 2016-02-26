# yz_extractors
Example custom extractors for Riak Search (yokozuna)

# Compilation

	make

# Installation

	cp ebin/* /path/to/riak/basho-patches

# Activation

	yz_extractor:register("application/deflate+json", yz_deflate_json_extractor).
