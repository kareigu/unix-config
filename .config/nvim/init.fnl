;;
;; MACROS
;;
(macro gbo! [bufnr key]
  `(. (. vim.bo ,bufnr) ,key))

(macro gb! [bufnr key]
  `(. (. vim.b ,bufnr) ,key))

(macro opt! [key value]
  `(set ,(sym (.. :vim. (tostring key))) ,value))

(macro optbo! [bufnr key value]
  `(tset (. vim.bo ,bufnr) ,key ,value))

(macro optb! [bufnr key value]
  `(tset (. vim.b ,bufnr) ,key ,value))

(macro map! [& binds]
  `(do
     ,(unpack (icollect [_ args (ipairs binds)]
        `(vim.keymap.set 
           ,args.mode 
           ,args.keys 
           ,args.act 
           ,args.opts)))))

(macro api! [cmd & args]
  `(,(sym (.. :vim.api. (tostring cmd))) ,(unpack args)))

(macro papi! [cmd & args]
  `(pcall ,(sym (.. :vim.api. (tostring cmd))) ,(unpack args)))

(macro user! [& args]
  `(api! nvim_create_user_command ,(unpack args)))

(macro auto! [& args]
  `(api! nvim_create_autocmd ,(unpack args)))

(macro req! [module func & args]
  `((. (require ,module) ,(tostring func)) ,(unpack args)))

(macro setup! [module & args]
  `(req! ,module setup ,(unpack args)))

;;
;; UTILS
;;
(fn append-list [target source]
  (each [_ v (ipairs source)]
    (table.insert target v))
  target)

(fn ansi-strip [str]
    (str:gsub "\x1b%[[%d;]*[a-zA-Z]" ""))

;;
;; BASIC SETTINGS
;;

(opt! g.mapleader " ")
(opt! g.maplocalleader " ")
(opt! opt.number true)
(opt! opt.mouse :a)
(opt! opt.showmode true)
(opt! opt.breakindent true)
(opt! opt.wrap true)
(opt! opt.undofile true)
(opt! opt.ignorecase true)
(opt! opt.smartcase true)
(opt! opt.signcolumn :yes)
(opt! opt.updatetime 250)
(opt! opt.timeoutlen 300)
(opt! opt.splitright true)
(opt! opt.splitbelow true)
(opt! opt.inccommand :split)
(opt! opt.cursorline true)
(opt! opt.scrolloff 10)
(opt! opt.hlsearch true)
(opt! opt.autocomplete true)
(opt! opt.completeopt "noselect,menuone,fuzzy")
(opt! o.pumborder :rounded)
(opt! o.textwidth 0)
(opt! o.colorcolumn :100)
(opt! o.showbreak "↪ ")
(opt! o.autoindent true)
(opt! o.shiftwidth 4)
(opt! o.softtabstop 4)
(opt! o.expandtab true)
(opt! o.smartindent true)
(opt! o.smarttab true)
(opt! o.wildmenu true)
(opt! o.wildmode "longest:full,full")
(opt! env.MYVIMRC (.. (vim.fn.stdpath "config") "/init.fnl"))

(when (and (= (. (vim.uv.os_uname) :sysname) :Darwin)
           (= (vim.fn.executable :ghostty) 1))
  (vim.opt.rtp:prepend :/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/))

(var transparent true)
(when vim.g.neovide
  (opt! opt.guifont
        "TX-02,Symbols Nerd Font Mono:h13:#e-subpixelantialias:#h-none")
  (when (= (. (vim.uv.os_uname) :sysname) :Darwin)
    (opt! g.neovide_window_blurred true)
    (opt! g.neovide_transparency 0.7))
  (opt! g.neovide_title_background_color "#1F1F28")
  (opt! g.neovide_floating_shadow true)
  (opt! g.neovide_floating_z_height 10)
  (opt! g.neovide_floating_corner_radius 0.5)
  (opt! g.neovide_light_angle_degrees 45)
  (opt! g.neovide_light_radius 5)
  (set transparent false))

;;
;; KEYS
;;

(map! {:mode :n 
       :keys :<Esc> 
       :act :<cmd>nohlsearch<CR>}
      {:mode [:n :x] 
       :keys :m 
       :act :<Nop>})

(map! {:mode :n
       :keys :<leader>ce
       :act vim.diagnostic.open_float
       :opts {:desc "Diagnostic error messages"}}
      {:mode :n
       :keys :<leader>cq
       :act vim.diagnostic.setloclist
       :opts {:desc "Diagnostic quickfix list"}}
      {:mode :n
       :keys :<leader>cc
       :act :<cmd>Compile<cr>
       :opts {:desc :Compile}}
      {:mode :t
       :keys :<Esc><Esc>
       :act "<C-\\><C-n>"
       :opts {:desc "Exit terminal mode"}})

(map! {:mode :n
       :keys :<C-h>
       :act :<C-w><C-h>
       :opts {:desc "Focus the left window"}}
      {:mode :n
       :keys :<C-l>
       :act :<C-w><C-l>
       :opts {:desc "Focus the right window"}}
      {:mode :n
       :keys :<C-j>
       :act :<C-w><C-j>
       :opts {:desc "Focus the lower window"}}
      {:mode :n
       :keys :<C-k>
       :act :<C-w><C-k>
       :opts {:desc "Focus the upper window"}})

(map! {:mode :n 
       :keys :L 
       :act :<cmd>bn<cr> 
       :opts {:desc "Next buffer"}}
      {:mode :n 
       :keys :H 
       :act :<cmd>bp<cr> 
       :opts {:desc "Previous buffer"}}
      {:mode :n
       :keys :<leader>bb
       :act "<cmd>b #<cr>"
       :opts {:desc "Go to last buffer"}})

(map! {:mode :n
       :keys :<leader>ll
       :act :<cmd>ListPackages<cr>
       :opts {:desc "List packages"}}
      {:mode :n
       :keys :<leader>lu
       :act (fn [] (vim.pack.update))
       :opts {:desc "Update packages"}})

;;
;; COMMANDS
;;

(user! :OpenConfig (fn []
                     (vim.fn.chdir (vim.fn.stdpath :config))
                     (vim.cmd.edit :$MYVIMRC)) {})

(user! :CompileConfig 
       (fn []
        (let [config-path vim.env.MYVIMRC
              lua-config (.. (vim.fn.stdpath :config) "/init.lua")
              write-config (fn [path contents]
                (vim.uv.fs_open path :w (tonumber :644 8) 
                    (fn [err fd]
                      (if (or err (= fd nil))
                        (vim.notify 
                          (string.format "failed writing config: %s" (or err "unknown"))
                          vim.log.levels.ERROR)
                        (vim.uv.fs_write fd contents 0 
                            (fn [err bytes] 
                                (if (or err (not= bytes (length contents))) 
                                    (vim.notify 
                                      (string.format "failed writing config: %s" (or err "partial write"))
                                      vim.log.levels.ERROR)
                                    (vim.notify (string.format "config written to %s" path) vim.log.levels.INFO))))))))
              on-exit (fn [obj]
                (if (= obj.code 0)
                    (do
                      (vim.notify "compilation finished" vim.log.levels.INFO)
                      (write-config lua-config obj.stdout))
                    (vim.notify 
                      (string.format "compilation failed: %s" (ansi-strip obj.stderr)) 
                      vim.log.levels.ERROR)))
            ]
            (if (= (vim.fn.executable :fennel) 1)
                (do 
                    (vim.notify (string.format "compiling %s" config-path) vim.log.levels.INFO)
                    (vim.system ["fennel" "-c" config-path] {:text true} on-exit))
                (vim.notify "fennel not in path, unable to compile" vim.log.levels.ERROR))))
{})

(user! :ListPackages
       (fn []
         (let [packages (vim.pack.get)
               lines (if (= (length packages) 0)
                    ["No packages installed"]
                    (accumulate [acc [] _ package (ipairs packages)]
                        (let [icon (if package.active " " " ")]
                            (append-list acc
                              [
                               (string.format "%s - %s" package.spec.name icon)
                               (string.format "\tsrc = %s" package.spec.src)
                               (string.format "\trev = %s" package.rev)
                               (string.format "\tpath = %s" package.path)
                               ""
                              ]))))
               bufnr (api! nvim_create_buf false true)
               winid (api! nvim_open_win bufnr true
                           {:relative :editor
                            :border :rounded
                            :width (- vim.o.columns 6)
                            :height (- vim.o.lines 6)
                            :col 2
                            :row 2
                            :style :minimal})]
           (api! nvim_buf_set_lines bufnr 0 -1 true lines)
           (let [ns (api! nvim_create_namespace :pkg_hl)]
             (api! nvim_buf_clear_namespace bufnr ns 0 -1)
             (each [i package (ipairs packages)]
               (let [line (* (- i 1) 5)
                     header_len (- (length (. lines (+ line 1))) 6)
                     icon_colour (if package.active :DiagnosticOk
                                     :DiagnosticError)]
                 (api! nvim_buf_add_highlight bufnr ns :Title line 0 header_len)
                 (api! nvim_buf_add_highlight bufnr ns icon_colour line
                       (+ header_len 1) -1)
                 (api! nvim_buf_add_highlight bufnr ns :Special (+ line 1) 0 -1)
                 (api! nvim_buf_add_highlight bufnr ns :Number (+ line 2) 0 -1)
                 (api! nvim_buf_add_highlight bufnr ns :Directory (+ line 3) 0
                       -1))))
           (optbo! bufnr :modifiable false)
           (optbo! bufnr :modified false)
           (optbo! bufnr :bufhidden :wipe)
           (optbo! bufnr :filetype :pack-info)
           (map! {:mode :n
                  :keys :q
                  :act :<cmd>close<cr>
                  :opts {:buffer bufnr :nowait true}}
                 {:mode :n
                  :keys :<C-c>
                  :act :<cmd>close<cr>
                  :opts {:buffer bufnr}}
                 {:mode :n
                  :keys :<Esc>
                  :act :<cmd>close<cr>
                  :opts {:buffer bufnr}})
           (auto! :BufLeave
                  {:desc "Close pack info on buffer closure"
                   :buffer bufnr
                   :once true
                   :nested true
                   :callback (fn []
                    (when (vim.api.nvim_win_is_valid winid)
                        (vim.api.nvim_win_close winid true)))
            })))
       {})

(user! :Compile
  (fn [opts]
    (when (= vim.g.krg_compile_last_command nil)
      (opt! g.krg_compile_last_command "ninja -C build"))
    (local handle-compile (fn [input]
        (let [bufnr (api! nvim_create_buf false true)
              winid (api! nvim_open_win bufnr true
                        {:relative :editor
                         :border :rounded
                         :width (- vim.o.columns 6)
                         :height (- vim.o.lines 6)
                         :col 2
                         :row 2
                         :style :minimal})
              handle-output (fn [err data] 
                              (case [err data]
                                [err _] (vim.notify err vim.log.levels.ERROR)
                                [nil data] (vim.schedule (fn []
                                    (when (api! nvim_win_is_valid winid)
                                      (api! nvim_buf_set_lines 
                                        bufnr -1 -1 true 
                                        (vim.split (ansi-strip data) "\n" { :trimempty true})))))
                              ))
              stdout (vim.uv.new_pipe)
              stderr (vim.uv.new_pipe)
              args (vim.split input "%s")
              cmd (table.remove args 1)
              (handle pid err) (vim.uv.spawn cmd
                                 {:args args
                                  :stdio [nil stdout stderr]
                                  :hide true}
                                 (fn [code signal]
                                   (vim.schedule
                                     (fn []
                                       (when (api! nvim_win_is_valid winid)
                                         (api! nvim_buf_set_lines bufnr -1 -1 true
                                           [(string.format "-- exited with code %d --" code)])
                                         (stdout:read_stop)
                                         (stderr:read_stop)
                                         (optbo! bufnr :modifiable false)
                                         (when handle nil
                                           (handle:close)))))))
              ]
        (if err
            (api! nvim_buf_set_lines bufnr -1 -1 true
              [(string.format "-- failed running: %s --" err)])
            (do
              (api! nvim_buf_set_lines bufnr -1 -1 true
                [(string.format "-- running(%d): %s --" pid input)])
              (vim.uv.read_start stdout handle-output)
              (vim.uv.read_start stderr handle-output)))
        (optbo! bufnr :modified false)
        (optbo! bufnr :bufhidden :wipe)
        (optbo! bufnr :filetype :compilation)
        (map! 
          {:mode "n" 
           :keys "q" 
           :act "<cmd>close<cr>" 
           :opts {:buffer bufnr :nowait true}}
          {:mode "n" 
           :keys "<C-c>" 
           :act "<cmd>close<cr>" 
           :opts {:buffer bufnr}}
          {:mode "n" 
           :keys "<Esc>" 
           :act "<cmd>close<cr>" 
           :opts {:buffer bufnr}}
          {:mode "n" 
           :keys "c" 
           :act (fn [] (when (and handle (not (handle:is_closing)))
                            (handle:kill)
                            (vim.notify "compilation aborted")))
           :opts {:buffer bufnr}}
          {:mode "n" 
           :keys "o" 
           :act (fn [] (when (api! nvim_win_is_valid winid)
                            (vim.api.nvim_win_set_config winid
                                {:split 
                                 :right
                                 :win (vim.fn.win_getid (vim.fn.winnr "#"))})))
           :opts {:buffer bufnr}})
        (auto! :BufUnload
          {:desc "Close compilation window on buffer close"
           :buffer bufnr
           :once true
           :nested true
           :callback (fn [] 
                       (when (and handle (handle:is_closing))
                         (stdout:read_stop)
                         (stderr:read_stop)
                         (handle:kill))
                       (when (api! nvim_win_is_valid winid)
                         (api! nvim_win_close winid true)))})
        )))
    (if (> (length opts.args) 0)
        (handle-compile opts.args)
        (vim.ui.input 
          {:prompt "Compile: " :default vim.g.krg_compile_last_command :completion "shellcmdline"}
          (fn [input]
            (when input
                (if (= (length input) 0)
                    (do
                        (opt! g.krg_compile_last_command nil)
                        (vim.notify "Empty command not allowed" vim.log.levels.ERROR))
                    (do
                        (set vim.g.krg_compile_last_command input)
                        (handle-compile input))
                    ))))))
  {:desc "Run compilation command and display the output in a buffer"
   :complete "shellcmdline"
   :nargs "*"})


(auto! :BufReadPost {
    :group (api! nvim_create_augroup :krg_last_location {:clear true})
    :callback (fn [event]
        (let [buf event.buf
              exclude [:gitcommit :jjdescription]
              excluded (vim.tbl_contains exclude (gbo! buf :filetype))
              l_loc (gb! buf :krg_last_location)]
            (when (not (or excluded l_loc))
                (optb! buf :krg_last_location true)
                (let [mark (vim.api.nvim_buf_get_mark buf "\"")
                      lcount (vim.api.nvim_buf_line_count buf)]
                    (when (and (> (. mark 1) 0) (<= (. mark 1) lcount))
                        (papi! nvim_win_set_cursor 0 mark))))))
})

(auto! :FileType {
    :group (api! nvim_create_augroup :krg_wrap_spell {:clear true})
    :pattern [:gitcommit :markdown :jjdescription]
    :callback (fn []
        (opt! opt_local.wrap true)
        (opt! opt_local.spell true))
})

(auto! :TextYankPost
       {:desc "Highlight yanked text"
        :group (api! nvim_create_augroup :highlight-yank {:clear true})
        :callback (fn [] (vim.highlight.on_yank))})

(auto! :BufWritePost
       {:pattern vim.env.MYVIMRC
       :callback (fn [] (vim.cmd "CompileConfig"))})

;;
;; PACKAGES
;;

(local INSTANT 1)
(local DEFER 2)
(var packages-to-install [])
(var on-update-hooks [])

(fn append-package [load-time spec]
  (if (not (. packages-to-install load-time))
      (tset packages-to-install load-time
            {:urls [spec.src] :setups [spec.setup] :deps [(or spec.deps {})]})
      (let [len (length (. (. packages-to-install load-time) :urls))]
        (tset packages-to-install load-time :urls (+ len 1) spec.src)
        (tset packages-to-install load-time :setups (+ len 1)
              (or spec.setup false))
        (tset packages-to-install load-time :deps (+ len 1) (or spec.deps {})))))

(macro use-pack! [spec]
  `(do
     (let [s# ,spec]
     ,(case spec
       {: instant} `(append-package INSTANT s#)
       {: event} `(append-package ,event s#)
       {} `(append-package DEFER s#)
       _# (assert-compile "invalid input"))
     ,(when spec.init
       `((. s# :init)))
     ,(when spec.keys
        `(each [_# args# (ipairs (. s# :keys))]
            (vim.keymap.set (. args# :mode) (. args# :keys) (. args# :act) (. args# :opts))))
     ,(when spec.on_update
        (if spec.src.src
           `(table.insert on-update-hooks [(. s# :src :src) (. s# :on_update)])
           `(table.insert on-update-hooks [(. s# :src) (. s# :on_update)])
        )))))

(fn init-pack []
  (fn add-and-setup [specs]
    (vim.pack.add specs.urls)
    (each [_ setup (ipairs specs.setups)]
      (when (setup)
        (setup)))
    (each [_ deps (ipairs specs.deps)]
      (vim.pack.add deps)))

  (each [load-time specs (pairs packages-to-install)]
    (match load-time
      INSTANT (add-and-setup specs)
      DEFER (vim.schedule (fn [] (add-and-setup specs)))
      event (auto! event {:once true :callback (fn [] (add-and-setup specs))})))
  (auto! :PackChanged
         {
    :callback (fn [ev]
        (when (= ev.data.kind :update)
            (each [_ hook (ipairs on-update-hooks)]
                (when (= (. hook 1) ev.data.spec.src)
                    (when (not ev.data.active)
                        (vim.cmd.packadd ev.data.spec.name))
                    (vim.cmd (. hook 2))))))}))

(use-pack! {
    :src "https://github.com/rebelot/kanagawa.nvim"
    :instant true
    :on_update :KanagawaCompile
    :setup (fn []
    (let [kanagawa (require :kanagawa)
          overrides (fn [colors]
              (let [theme colors.theme
                palette colors.palette]
                {
                 :MiniStatuslineModeNormal {:fg theme.ui.fg :bg palette.waveRed}
                 :MiniStatuslineModeInsert {:fg theme.ui.bg_m1 :bg palette.springBlue}
                 :MiniStatuslineModeVisual {:fg theme.ui.fg :bg palette.lotusGreen}
                 :MiniStatuslineModeReplace {:fg theme.ui.fg :bg palette.lotusOrange}
                 :MiniStatuslineModeCommand {:fg theme.ui.fg :bg palette.fujiGray}
                 :MiniStatuslineModeOther {:fg theme.ui.fg :bg palette.lotusCyan}
                 :MiniStatuslineFileinfo {:fg theme.ui.fg_dim :bg theme.ui.whitespace}
                 :MiniStatuslineFilename {:fg theme.ui.fg :bg theme.ui.bg_p2 :italic true}
                 :MiniStatuslineDevinfo {:fg theme.ui.special :bg theme.ui.bg_m3}
                 :MiniStatuslineInactive {:fg theme.ui.fg_dim :bg theme.ui.bg_dim :italic true}
                 :Pmenu {:fg theme.ui.fg :bg theme.ui.bg_p1 :blend vim.o.pumblend}
                 :PmenuSel {:fg theme.ui.fg_dim :bg theme.ui.bg_p2}
                 :PmenuSbar {:bg theme.ui.bg_m1}
                 :PmenuThumb {:bg theme.ui.fg_dim}
                 :NormalFloat {:bg :none}
                 :FloatBorder {:bg :none}
                 :FloatTitle {:bg :none}
                 :NormalDark {:fg theme.ui.fg_dim :bg theme.ui.bg_m3}
                 }))]
            (kanagawa.setup {
                :compile true
                : transparent
                :keywordStyle {:italic false}
                :commentStyle {:italic false}
                : overrides
            }))
            (vim.cmd.colorscheme :kanagawa))
})

(use-pack! {
    :src "https://github.com/stevearc/conform.nvim"
    :setup (fn []
        (var ft_formatters 
               {:lua [ :stylua ]
                :cmake [ :gersemi ]
                :c [ :clang-format ]
                :cpp [ :clang-format ]
                :zig [ :zigfmt ]
                :toml [ :taplo ]
                :rust [ :rustfmt ]
                :odin [ :odinfmt ]})
        (var formatters 
                {:odinfmt 
                    {:command "odinfmt"
                     :args [ "-stdin" ]}
                })
        (let [(ok local_fmt) (pcall require :local_fmt)]
          (if ok
            (do
                (when local_fmt.ft_formatters
                    (set ft_formatters 
                        (vim.tbl_deep_extend :force ft_formatters local_fmt.ft_formatters)))
                (when local_fmt.formatters
                    (set formatters 
                        (vim.tbl_deep_extend :force formatters local_fmt.formatters))))
            (vim.notify "error loading local_fmt")))
        (setup! :conform 
            {:notify_on_error true
             :formatters_by_ft ft_formatters
             :formatters formatters}))
    :keys [
        {:mode "n"
         :keys "<leader>cf"
         :act (fn [] (req! :conform format { :async true }))
         :opts { :desc "Format buffer" }}
        {:mode [ "x" "v" ]
         :keys "<leader>cf"
         :act (fn [] (req! :conform format { :async true }))
         :opts { :desc "Format selection" }}
        {:mode "n"
         :keys "<leader>ci" 
         :act "<cmd>ConformInfo<cr>"
         :opts { :desc "Formatter info" }}
    ]
})

(use-pack! {
    :src "https://github.com/folke/which-key.nvim"
    :setup (fn []
        (setup! :which-key
            {:preset "helix"
             :expand 0
             :spec [ 
                { 1 "<leader>b" :group "buffer" }
                { 1 "<leader>c" :group "code" :mode [ "n" "v" ] }
                { 1 "<leader>s" :group "search" }
                { 1 "<leader>u" :group "ui" }
                { 1 "<leader>g" :group "git" }
                { 1 "<leader>q" :group "session" }
                { 1 "<leader>m" :icon "󰇘 " :group "misc" :mode [ "n" "v" ] }
                { 1 "<leader>ms" :icon "󰛔 " :desc "Search and replace" :mode [ "n" "v" ] }
                { 1 "<leader>l" :icon " " :group "packages" }
                { 1 "<leader>y" 2 "\"+y" :icon " " :desc "Copy to clipboard" :mode [ "n" "x" "v" "t" ] }
                { 1 "<leader>Y" 2 "\"+Y" :icon " " :desc "Copy line to clipboard" }
                { 1 "<leader>p" 2 "\"+p" :icon " " :desc "Paste from clipboard after selection" }
                { 1 "<leader>P" 2 "\"+P" :icon " " :desc "Paste from clipboard before selection" }
                { :mode [ "v" ]
                    1 { 1 "<leader>g" :group "git hunk" }
                }]
        })
    )
})

(use-pack! {
    :src "https://github.com/nvim-lualine/lualine.nvim"
    :init (fn [] (set vim.g.lualine_laststatus vim.o.laststatus)
                 (if (> (vim.fn.argc -1) 0)
                    (set vim.o.statusline " ")
                    (set vim.o.laststatus 0)))
    :setup (fn []
            (let [get-hl (fn [name] (vim.api.nvim_get_hl 0 {: name}))
                  get-colour (fn [name key] (string.format "%x" (. (get-hl name) key)))
                  colours {
                    :bg (get-colour :StatusLine :bg)
                    :fg (get-colour :StatusLine :fg)
                    :inactive (get-colour :StatusLineNC :fg)
                    :filepath (get-colour :MiniStatuslineFilename :fg)
                    :fileinfo (get-colour :MiniStatuslineFileinfo :fg)
                    :vcs (get-colour :SpecialKey :fg)
                    :error (get-colour :DiagnosticError :fg)
                    :warn (get-colour :DiagnosticWarn :fg)
                    :info (get-colour :DiagnosticInfo :fg)
                    :mode {
                        :normal (get-colour :MiniStatuslineModeNormal :bg)
                        :insert (get-colour :MiniStatuslineModeInsert :bg)
                        :visual (get-colour :MiniStatuslineModeVisual :bg)
                        :replace (get-colour :MiniStatuslineModeReplace :bg)
                        :command (get-colour :MiniStatuslineModeCommand :bg)
                        :other (get-colour :MiniStatuslineModeOther :bg)
                    }}
                  mode-color {
                    :n colours.mode.normal :no colours.mode.normal
                    :i colours.mode.insert
                    :v colours.mode.visual "\22" colours.mode.visual :V colours.mode.visual
                    :c colours.mode.command "!" colours.mode.command :t colours.mode.command
                    :R colours.mode.replace :Rv colours.mode.replace :r colours.mode.replace
                    :rm colours.mode.replace "r?" colours.mode.replace
                    :s colours.mode.other :S colours.mode.other "\19" colours.mode.other
                    :ic colours.mode.other :cv colours.mode.other :ce colours.mode.other
                    }
                  conditions {
                    :buffer_not_empty (fn [] (not= (vim.fn.empty (vim.fn.expand "%:t")) 1))
                    :check_git_workspace (fn [] (let [filepath (vim.fn.expand "%:p:h")
                                                      gitdir (vim.fn.finddir ".git" (.. filepath ";"))]
                                                    (and gitdir 
                                                        (> (length gitdir) 0)
                                                        (< (length gitdir) (length filepath)))))
                    }
                  opts {
                    :options {
                        :component_separators ""
                        :section_separators ""
                        :theme {:normal {:c {:fg colours.fg :bg colours.bg}}
                        :inactive {:c {:fg colours.fg :bg colours.bg}}}
                        :global_status (= vim.o.laststatus 3)
                        :disabled_filetypes {:statusline ["dashboard"]}
                    }
                    :sections {
                        :lualine_a []
                        :lualine_b []
                        :lualine_y []
                        :lualine_z []
                        :lualine_c [
                            {1 (fn [] "  ")
                            :color (fn [] {:fg (. mode-color (vim.fn.mode))})
                            :padding {:right 1}}
                            {1 "filesize" 
                             :cond conditions.buffer_not_empty}
                            {1 "filename"
                             :cond conditions.buffer_not_empty
                             :color {:fg colours.filepath :gui "bold"}
                             :newfile_status true
                             :path 1}
                            "location"
                            {1 "progress" 
                             :color {:fg colours.fg :gui "bold"}}
                             ]
                        :lualine_x [
                            {1 "o:encoding"
                             :fmt string.upper
                             :color {:fg colours.fileinfo :gui "bold"}}
                            {1 "fileformat"
                             :fmt string.upper
                             :icons_enabled false
                             :color {:fg colours.fileinfo :gui "bold"}}
                            {1 "branch"
                             :icon ""
                             :color {:fg colours.vcs :gui "bold"}}
                            {1 "filetype"
                             :icons_enabled true
                             :color {:fg colours.fileinfo :gui "bold"}}]}
                    :inactive_sections {
                        :lualine_a [] :lualine_b [] :lualine_y []
                        :lualine_z [] :lualine_c [] :lualine_x []}
                    }]
                  (each [_ component (ipairs opts.sections.lualine_c)]
                    (when (= (type component) :table)
                      (let [copy (vim.deepcopy component)]
                        (tset copy :color {:fg colours.inactive})
                        (table.insert opts.inactive_sections.lualine_c copy))))
                  (each [_ component (ipairs opts.sections.lualine_x)]
                    (when (= (type component) :table)
                      (let [copy (vim.deepcopy component)]
                        (tset copy :color {:fg colours.inactive})
                        (table.insert opts.inactive_sections.lualine_x copy))))
                  (setup! :lualine opts)))
})
              
                            

(use-pack! {
    :src { :src "https://github.com/nvim-treesitter/nvim-treesitter" :version "main" }
    :instant true
    :on_update "TSUpdate"
    :setup (fn []
        (let [ensure_installed
               [ "bash"
                 "c"
                 "cpp"
                 "diff"
                 "html"
                 "lua"
                 "luadoc"
                 "rust"
                 "toml"
                 "vim"
                 "vimdoc"
                 "yaml"
                 "zig"
               ]]
        (req! :nvim-treesitter install ensure_installed))
        (auto! :FileType 
            {:pattern (req! :nvim-treesitter get_installed)
             :callback (fn [] (vim.treesitter.start))})
    )
})

(use-pack! {
    :src "https://github.com/folke/todo-comments.nvim"
    :event "BufReadPost"
    :deps [ "https://github.com/nvim-lua/plenary.nvim" ]
    :setup (fn []
        (setup! :todo-comments { :signs false })
    )
})

(use-pack! {
    :src "https://github.com/nvim-mini/mini.icons"
    :setup (fn []
        (let [icons (require :mini.icons)]
            (icons.setup)
            (icons.mock_nvim_web_devicons))
    )
})
(use-pack! {
    :src "https://github.com/rcarriga/nvim-notify"
    :event "VimEnter"
    :setup (fn []
        (setup! :notify { :render "compact" })
        (opt! notify (require :notify))
    )
})
(use-pack! {
    :src "https://github.com/ojroques/nvim-bufdel"
    :setup (fn [] (setup! :bufdel { :quit false }))
    :keys [ 
        { :mode "n" :keys "<leader>bd" :act "<cmd>BufDel<cr>" :opts { :desc "Close current buffer" } }
        { :mode "n" :keys "<leader>bD" :act "<cmd>BufDel!<cr>" :opts { :desc "Force close current buffer" } }
        { :mode "n" :keys "<leader>bo" :act "<cmd>BufDelOthers<cr>" :opts { :desc "Close all other buffers" } }
        { :mode "n" :keys "<leader>bO" :act "<cmd>BufDelOthers!<cr>" :opts { :desc "Force close all other buffers" } }
        { :mode "n" :keys "<leader>bA" :act "<cmd>BufDelAll!<cr>" :opts { :desc "Force close all buffers" } }
    ]
})

(use-pack! {
    :src "https://github.com/ibhagwan/fzf-lua"
    :setup (fn [] (setup! :fzf-lua [ "ivy" ]))
    :keys [
        {:mode "n" 
         :keys "<leader><leader>" 
         :act "<cmd>FzfLua files<cr>" 
         :opts { :desc "Search files" }}
        {:mode "n" 
         :keys "<leader>." 
         :act (fn [] (req! :fzf-lua files { :cwd (vim.fn.expand "%:p:h") }))
         :opts { :desc "Search files (cwd)" }}
        {:mode "n" 
         :keys "<leader>sh" 
         :act "<cmd>FzfLua helptags<cr>"
         :otps { :desc "Search help" }}
        {:mode "n"
         :keys "<leader>sm" 
         :act "<cmd>FzfLua manpages<cr>" 
         :opts { :desc "Search manpages" }}
        {:mode "n" 
         :keys "<leader>s\""
         :act "<cmd>FzfLua registers<cr>" 
         :opts { :desc "Search registers" }}
        {:mode "n" 
         :keys "<leader>sk" 
         :act "<cmd>FzfLua keymaps<cr>" 
         :opts { :desc "Search keymaps" }}
        {:mode "n" 
         :keys "<leader>ss" 
         :act "<cmd>FzfLua<cr>" 
         :opts { :desc "Search select" }}
        {:mode "n" 
         :keys "<leader>sj" 
         :act "<cmd>FzfLua jumps<cr>" 
         :opts { :desc "Search jumplist" }}
        {:mode "n" 
         :keys "<leader>sw" 
         :act "<cmd>FzfLua grep_cword<cr>"
         :opts { :desc "Search current word" }}
        {:mode "n"
         :keys "<leader>sg" 
         :act "<cmd>FzfLua live_grep_native<cr>" 
         :opts { :desc "Search by grep" }}
        {:mode "n"
         :keys "<leader>sG"
         :act (fn [] (req! :fzf-lua live_grep_native { :cwd (vim.fn.expand "%:p:h") }))
         :opts { :desc "Search by grep (cwd)" }}
        {:mode "n" 
         :keys "<leader>sd"
         :act "<cmd>FzfLua diagnostics_workspace<cr>"
         :opts { :desc "Search diagnostics" }}
        {:mode "n" 
         :keys "<leader>sr" 
         :act "<cmd>FzfLua resume<cr>" 
         :opts { :desc "Search resume" }}
        {:mode "n"
         :keys "<leader>bs" 
         :act "<cmd>FzfLua buffers<cr>" 
         :opts { :desc "Find buffers" }}
        {:mode "n" 
         :keys "<leader>/" 
         :act "<cmd>FzfLua blines<cr>" 
         :opts { :desc "Search in current buffer" }}
        {:mode "n"
         :keys "<leader>s/" 
         :act "<cmd>FzfLua lines<cr>" 
         :opts { :desc "Search in open files" }}
        {:mode "n"
         :keys "<leader>sc"
         :act (fn [] (req! :fzf-lua files { :cwd (vim.fn.stdpath "config") }))
         :opts { :desc "Search config files" }}
    ]
})

(use-pack! {
    :src "https://github.com/nvim-mini/mini.surround"
    :setup (fn []
        (setup! :mini.surround 
            {:mappings {
                :add "ys"
                :delete "ds"
                :replace "cs"
                :highlight "sh"
                :find "sf"
                :find_left "sF"
                :update_lines "sn"
                :suffix_last ""
                :suffix_next ""
            }
            :search_method "cover_or_next"
            :custom_surroundings {
                :B { :output { :left "{" :right "}" }}
            }
        }))
    :keys [ 
        {:mode "x" :keys "S" :act "ys" :opts { :desc "surround selection" :remap true }}
        {:mode "n" :keys "yss" :act "ys_" :opts { :desc "surround line" :remap true }}
    ]
})

(use-pack! {
    :src "https://github.com/lewis6991/gitsigns.nvim"
    :event [ "BufReadPost" "BufNew" ]
    :keys [ 
        {:mode "n" :keys "<leader>gc" :act "<cmd>FzfLua git_commits<CR>" :opts { :desc "Search commits" }}
        {:mode "n" :keys "<leader>gB" :act "<cmd>FzfLua git_branches<CR>" :opts { :desc "Search branches" }}
        {:mode "n" :keys "<leader>gf" :act "<cmd>FzfLua git_files<CR>" :opts { :desc "Search files" }} 
    ]
    :setup (fn []
        (let [on_attach (fn [bufnr]
                (local map (fn [mode l r opts]
                    (var opts (or opts {}))
                    (set opts.buffer bufnr)
                    (vim.keymap.set mode l r opts)))
                (let [gitsigns (require :gitsigns)]
                    (map  "n" "]c" 
                        (fn [] (if vim.wo.diff
                                (vim.cmd.normal { 1 "]c" :bang true })
                                (gitsigns.nav_hunk :next)))
                        { :desc "Next git change" })
                    (map "n" "[c" 
                        (fn [] (if vim.wo.diff
                                (vim.cmd.normal { 1 "[c" :bang true })
                                (gitsigns.nav_hunk :prev)))
                        { :desc "Previous git change" })

                    ;; Actions
                    ;; visual mode
                    (map "v" "<leader>gs" 
                        (fn [] (gitsigns.stage_hunk [ (vim.fn.line ".") (vim.fn.line "v") ])) 
                        { :desc "Stage git hunk" })
                    (map "v" "<leader>gr" 
                        (fn [] (gitsigns.reset_hunk [ (vim.fn.line ".") (vim.fn.line "v") ]))
                        { :desc "Reset git hunk" })
                    ;; normal mode
                    (map "n" "<leader>gs" gitsigns.stage_hunk { :desc "git stage hunk" })
                    (map "n" "<leader>gr" gitsigns.reset_hunk { :desc "git reset hunk" })
                    (map "n" "<leader>gS" gitsigns.stage_buffer { :desc "git stage buffer" })
                    (map "n" "<leader>gu" gitsigns.undo_stage_hunk { :desc "git undo stage hunk" })
                    (map "n" "<leader>gR" gitsigns.reset_buffer { :desc "git reset buffer" })
                    (map "n" "<leader>gp" gitsigns.preview_hunk { :desc "git preview hunk" })
                    (map "n" "<leader>gb" (fn [] (gitsigns.blame_line { :full true })) { :desc "git blame line" })
                    (map "n" "<leader>gd" gitsigns.diffthis { :desc "git diff against index" })
                    (map "n" "<leader>gD" (fn [] (gitsigns.diffthis "@")) { :desc "git diff against last commit" })
                    (map "n" "<leader>ub" gitsigns.toggle_current_line_blame { :desc "Toggle git show blame line" })
                    (map "n" "<leader>uD" gitsigns.toggle_deleted { :desc "Toggle git show deleted" })
                  ))]
        (setup! :gitsigns {
            : on_attach 
        })))
})

(use-pack! {
    :src "https://github.com/folke/persistence.nvim"
    :setup (fn [] (setup! :persistence { :options (vim.opt.sessionoptions:get) }))
    :keys [
        {:mode "n"
         :keys "<leader>qr"
         :act (fn [] (req! :persistence load) 
                     (vim.notify "CWD session loaded" vim.log.levels.INFO))
         :opts { :desc "Load session for current directory" }}
        {:mode "n"
         :keys "<leader>ql"
         :act (fn [] (req! :persistence load { :last true })
                     (vim.notify "Last session loaded" vim.log.levels.INFO))
         :opts { :desc "Load last session" }}
        {:mode "n"
         :keys "<leader>qd"
         :act (fn [] (req! :persistence stop)
                      (vim.notify "Disabled automatically saving session" vim.log.levels.INFO))
         :opts { :desc "Don't automatically save current session" }}
        {:mode "n"
         :keys "<leader>qD"
         :act (fn [] (req! :persistence start)
                     (vim.notify "Automatically saving session" vim.log.levels.INFO))
         :opts { :desc "Automatically save current session" }}
        {:mode "n"
         :keys "<leader>qs"
         :act (fn [] (req! :persistence save)
                     (vim.notify "Saved session" vim.log.levels.INFO))
         :opts { :desc "Save current session" }}
    ]
})


(use-pack! {
    :src "https://github.com/MagicDuck/grug-far.nvim"
    :setup (fn [] (setup! :grug-far { :transient true }))
    :keys [
        {:mode "n" :keys "<leader>msr" :act "<CMD>GrugFar<CR>" :opts { :desc "Replace in files" }}
        {:mode "v" 
         :keys "<leader>msw" 
         :act (fn [] (req! :grug-far with_visual_selection) )
         :opts { :desc "Search selection" }
        }
    ]
})

(init-pack)
