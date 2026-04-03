local map = vim.keymap.set
local vscode = require("vscode")

vim.notify = vscode.notify

local command_index

local function commands()
  if command_index then return command_index end

  command_index = {}
  local available = vscode.eval("return await vscode.commands.getCommands(true)")
  if type(available) == "table" then
    for _, command in ipairs(available) do
      command_index[command] = true
    end
  end

  return command_index
end

local function execute(command_names, opts)
  local names = type(command_names) == "table" and command_names or { command_names }

  for _, command in ipairs(names) do
    if commands()[command] then
      vscode.action(command, opts)
      return
    end
  end

  vim.notify(("VS Code command unavailable: %s"):format(table.concat(names, ", ")), vim.log.levels.WARN, {
    title = "VSCode Neovim",
  })
end

local function map_action(mode, lhs, command_names, desc, opts)
  map(mode, lhs, function() execute(command_names, opts) end, { silent = true, desc = desc })
end

local function open_timeline()
  execute({ "workbench.action.openTimeline", "timeline.focus", "workbench.view.timeline" })
end

local function grep_word()
  local word = vim.fn.expand("<cword>")
  local args = word ~= "" and { query = word } or {}
  execute("workbench.action.findInFiles", { args = args })
end

local function git_blame()
  execute({ "gitlens.toggleLineBlame", "gitlens.toggleFileBlame", "workbench.action.openTimeline", "timeline.focus" })
end

local function git_history()
  execute({ "gitlens.openLineHistory", "gitlens.openFileHistory", "workbench.action.openTimeline", "timeline.focus" })
end

local function debug_eval()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    execute({ "editor.debug.action.selectionToRepl", "editor.debug.action.showDebugHover" })
    return
  end

  execute({ "editor.debug.action.showDebugHover", "editor.debug.action.selectionToRepl" })
end

local function nmap(lhs, rhs, desc)
  map("n", lhs, rhs, { silent = true, desc = desc })
end

local function nxmap(lhs, rhs, desc)
  map({ "n", "x" }, lhs, rhs, { silent = true, desc = desc })
end

nmap("<leader>u", open_timeline, "Local history")
map_action("n", "<leader>?", "workbench.action.openGlobalKeybindings", "Show keymaps")

map_action("n", "<leader>sf", "workbench.action.quickOpen", "Find files")
map_action("n", "<leader>sg", "workbench.action.findInFiles", "Live grep")
nmap("<leader>sw", grep_word, "Grep word under cursor")
map_action("n", "<leader>s/", { "actions.find", "editor.actions.findWithArgs" }, "Search in buffer")
map_action("n", "<leader>ss", "workbench.action.showAllSymbols", "Workspace symbols")
map_action("n", "<leader>sd", "workbench.action.gotoSymbol", "Document symbols")
map_action("n", "<leader>sb", { "workbench.action.showAllEditorsByMostRecentlyUsed", "workbench.action.showAllEditors" }, "Buffers")
map_action("n", "<leader>sr", { "workbench.action.openRecent", "workbench.action.quickOpenPreviousRecentlyUsedEditor" }, "Recent files")
map_action("n", "<leader>sh", "workbench.action.showCommands", "Commands")
map_action("n", "<leader>sk", "workbench.action.openGlobalKeybindings", "Keymaps")
map_action("n", "<leader>se", { "workbench.actions.view.problems", "problems.action.toggleProblems" }, "Diagnostics")
nmap("<leader>sc", git_history, "Git history")
map_action("n", "<leader>sB", { "git.checkout", "workbench.view.scm" }, "Git branches")
map_action("n", "<leader>st", "workbench.view.scm", "Git status")
map_action("n", "<leader>sR", { "workbench.action.openRecent", "workbench.action.quickOpenPreviousRecentlyUsedEditor" }, "Recent history")

map_action("n", "gd", "editor.action.revealDefinition", "LSP: Go to definition")
map_action("n", "gD", { "editor.action.goToTypeDefinition", "editor.action.peekDefinition" }, "LSP: Go to type definition")
map_action("n", "gr", { "editor.action.goToReferences", "editor.action.referenceSearch.trigger" }, "LSP: Show usages")
map_action("n", "gi", "editor.action.goToImplementation", "LSP: Go to implementation")
nmap("<leader>rn", vim.lsp.buf.rename, "LSP: Rename symbol")
map_action("n", "<leader>f", "editor.action.formatDocument", "LSP: Format buffer")
map_action("x", "<leader>f", "editor.action.formatSelection", "LSP: Format selection")
nxmap("<leader>re", vim.lsp.buf.code_action, "LSP: Code action")

map_action("n", "<leader>xx", { "workbench.actions.view.problems", "problems.action.toggleProblems" }, "Diagnostics")
map_action("n", "<leader>xX", { "workbench.actions.view.problems", "problems.action.toggleProblems" }, "Buffer diagnostics")
map_action("n", "<leader>cs", "workbench.action.gotoSymbol", "Symbols")
map_action("n", "<leader>cl", { "editor.action.goToReferences", "editor.action.referenceSearch.trigger" }, "LSP: References")
map_action("n", "<leader>xL", { "workbench.actions.view.problems", "problems.action.toggleProblems" }, "Location list")
map_action("n", "<leader>xQ", { "workbench.actions.view.problems", "problems.action.toggleProblems" }, "Quickfix list")

map_action("n", "]h", "workbench.action.editor.nextChange", "Git: Next hunk")
map_action("n", "[h", "workbench.action.editor.previousChange", "Git: Previous hunk")
map_action("n", "<leader>hs", { "git.stageChange", "git.stageSelectedRanges" }, "Git: Stage hunk")
map_action("x", "<leader>hs", "git.stageSelectedRanges", "Git: Stage selection")
map_action("n", "<leader>hu", { "git.unstageChange", "git.unstageSelectedRanges" }, "Git: Undo stage hunk")
map_action("x", "<leader>hu", "git.unstageSelectedRanges", "Git: Undo stage selection")
map_action("n", "<leader>hr", { "git.revertChange", "git.revertSelectedRanges" }, "Git: Reset hunk")
map_action("x", "<leader>hr", "git.revertSelectedRanges", "Git: Reset selection")
map_action("n", "<leader>hS", { "git.stageFile", "git.stage" }, "Git: Stage buffer")
map_action("n", "<leader>hR", { "git.revertChange", "git.openChange" }, "Git: Reset buffer")
nmap("<leader>hb", git_blame, "Git: Blame line")
nmap("<leader>hB", git_blame, "Git: Blame file")
map_action("n", "<leader>hd", "git.openChange", "Git: Diff this")
nmap("<leader>hl", git_history, "Git: Line history")
map_action("n", "<leader>hp", "git.openChange", "Git: Preview hunk")
map_action("n", "<leader>gg", "workbench.view.scm", "Open source control")
nmap("<leader>gl", git_history, "Git history")

map_action("n", "<F5>", "workbench.action.debug.continue", "Debug: Continue")
map_action("n", "<F9>", "editor.debug.action.toggleBreakpoint", "Debug: Toggle breakpoint")
map_action("n", "<F10>", "workbench.action.debug.stepOver", "Debug: Step over")
map_action("n", "<F11>", "workbench.action.debug.stepInto", "Debug: Step into")
map_action("n", "<S-F11>", "workbench.action.debug.stepOut", "Debug: Step out")
map_action("n", "<leader>db", "editor.debug.action.toggleBreakpoint", "Debug: Toggle breakpoint")
map_action("n", "<leader>dB", { "editor.debug.action.editBreakpoint", "editor.debug.action.toggleBreakpoint" }, "Debug: Conditional breakpoint")
map_action("n", "<leader>dl", { "editor.debug.action.addLogPoint", "editor.debug.action.editBreakpoint" }, "Debug: Log point")
map_action("n", "<leader>dr", "debug.openRepl", "Debug: REPL")
map_action("n", "<leader>du", "workbench.view.debug", "Debug: Toggle UI")
map_action("n", "<leader>dt", "workbench.action.debug.stop", "Debug: Terminate")
nxmap("<leader>dk", debug_eval, "Debug: Eval under cursor")

map_action("n", "<leader>gt", "go.test.package", "Go: Run tests")
map_action("n", "<leader>gf", "go.test.cursor", "Go: Test function")
map_action("n", "<leader>gc", "go.test.coverage", "Go: Coverage")
map_action("n", "<leader>ga", "go.toggle.test.file", "Go: Toggle test/impl")
map_action("n", "<leader>ge", "editor.action.codeAction", "Go: Insert if err")
map_action("n", "<leader>gim", "go.impl.cursor", "Go: Implement interface")
map_action("n", "<leader>gat", "go.add.tags", "Go: Add struct tags")
map_action("n", "<leader>grt", "go.remove.tags", "Go: Remove struct tags")
map_action("n", "<leader>gfs", "editor.action.codeAction", "Go: Fill struct")

map_action("n", "<leader>Fr", "dart.startDebugging", "Flutter: Run")
map_action("n", "<leader>Fh", "flutter.hotReload", "Flutter: Hot reload")
map_action("n", "<leader>FR", "flutter.hotRestart", "Flutter: Hot restart")
map_action("n", "<leader>Fd", "flutter.selectDevice", "Flutter: Devices")
map_action("n", "<leader>Fo", { "dart.openDevToolsInspector", "workbench.action.gotoSymbol" }, "Flutter: Outline")
map_action("n", "<leader>Fq", "workbench.action.debug.stop", "Flutter: Quit")
map_action("n", "<leader>Fl", "dart.restartAnalysisServer", "Flutter: LSP restart")

map_action("n", "<C-h>", "workbench.action.focusLeftGroup", "Focus left group")
map_action("n", "<C-j>", "workbench.action.focusBelowGroup", "Focus lower group")
map_action("n", "<C-k>", "workbench.action.focusAboveGroup", "Focus upper group")
map_action("n", "<C-l>", "workbench.action.focusRightGroup", "Focus right group")
map_action("n", "<C-\\>", "workbench.action.focusPreviousGroup", "Focus previous group")
