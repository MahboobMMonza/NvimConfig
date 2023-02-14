-- Additional plugins
return function(use)

	-- which-key
	use({
		'folke/which-key.nvim',
		config = function()
			require('which-key').setup{}
		end
	})

	-- nvim Surround
	use({
		'kylechui/nvim-surround',
		tag = '*',
	})

	-- Nvim-Tree
use {
		'nvim-tree/nvim-tree.lua',
		requires = {
			'nvim-tree/nvim-web-devicons',
		},
		tag = 'nightly',
	}

end
