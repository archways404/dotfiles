return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = [[

                                                                                                      .x+=:.   
                                     .uef^"      x=~                            ..           z`    ^%  
               .u    .             :d88E        88x.   .e.   .e.               @L               .   <k 
      u      .d88B :@8c        .   `888E       '8888X.x888:.x888        u     9888i   .dL     .@8Ned8" 
   us888u.  ="8888f8888r  .udR88N   888E .z8k   `8888  888X '888k    us888u.  `Y888k:*888.  .@^%8888"  
.@88 "8888"   4888>'88"  <888'888k  888E~?888L   X888  888X  888X .@88 "8888"   888E  888I x88:  `)8b. 
9888  9888    4888> '    9888 'Y"   888E  888E   X888  888X  888X 9888  9888    888E  888I 8888N=*8888 
9888  9888    4888>      9888       888E  888E   X888  888X  888X 9888  9888    888E  888I  %8"    R88 
9888  9888   .d888L .+   9888       888E  888E  .X888  888X. 888~ 9888  9888    888E  888I   @8Wou 9%  
9888  9888   ^"8888*"    ?8888u../  888E  888E  `%88%``"*888Y"    9888  9888   x888N><888' .888888P`   
"888*""888"     "Y"       "8888P'  m888N= 888>    `~     `"       "888*""888"   "88"  888  `   ^"F     
 ^Y"   ^Y'                  "P'     `Y"   888                      ^Y"   ^Y'          88F              
                                         J88"                                        98"               
                                         @%                                        ./"                 
                                       :"                                         ~`                   
        
 ]],
        -- stylua: ignore
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
}

