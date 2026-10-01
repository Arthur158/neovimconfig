local dap = require("dap")
local dapui = require("dapui")

local delve_host = "127.0.0.1"
local delve_port = 2345

local last_nebo_root

local function is_nebo_root(root)
  return root
    and vim.fn.filereadable(root .. "/bazel") == 1
    and vim.fn.isdirectory(root .. "/vpc") == 1
    and vim.fn.isdirectory(root .. "/nebazel") == 1
end

local function find_nebo_root()
  local candidates = {}
  local buffer_name = vim.api.nvim_buf_get_name(0)
  if buffer_name ~= "" then
    table.insert(candidates, vim.fs.dirname(vim.fs.normalize(buffer_name)))
  end
  table.insert(candidates, vim.fn.getcwd())

  for _, start in ipairs(candidates) do
    local root = vim.fs.root(start, { ".git", "MODULE.bazel", "WORKSPACE", "WORKSPACE.bazel" })
    if is_nebo_root(root) then
      last_nebo_root = root
      return root
    end
  end

  if is_nebo_root(last_nebo_root) then
    return last_nebo_root
  end

  return nil
end

local function substitute_paths(nebo_root)
  return {
    {
      from = nebo_root .. "/bazel-nebo/external/rules_go++go_sdk+go_sdk/src/",
      to = "GOROOT/src/",
    },
    {
      from = nebo_root .. "/bazel-nebo/external/",
      to = "external/",
    },
    {
      from = nebo_root .. "/bazel-nebo/bazel-out/",
      to = "bazel-out/",
    },
    {
      from = nebo_root .. "/",
      to = "",
    },
  }
end

local function find_go_test_target(nebo_root, source_file)
  if source_file == "" or vim.fn.filereadable(source_file) ~= 1 then
    return nil, "the current buffer is not a file"
  end

  local build_files = vim.fs.find({ "BUILD", "BUILD.bazel" }, {
    upward = true,
    path = vim.fs.dirname(source_file),
    stop = nebo_root,
    limit = 1,
  })
  local build_file = build_files[1]
  if not build_file then
    return nil, "no BUILD or BUILD.bazel file was found above the current file"
  end

  local contents = table.concat(vim.fn.readfile(build_file), "\n")
  local source_name = vim.fs.basename(source_file)
  for block in contents:gmatch("go_test%s*(%b())") do
    local name = block:match('name%s*=%s*"([^"]+)"')
    local srcs = block:match("srcs%s*=%s*(%b[])")
    if name and srcs and srcs:find('"' .. source_name .. '"', 1, true) then
      local package_dir = vim.fs.dirname(build_file):sub(#nebo_root + 2)
      if package_dir == "." or package_dir == "" then
        return "//:" .. name
      end
      return "//" .. package_dir .. ":" .. name
    end
  end

  return nil, source_name .. " is not listed in a go_test rule in " .. build_file
end

-- Bazel starts Delve. Neovim connects directly to that existing DAP server.
dap.adapters.bazel_go = {
  type = "server",
  host = delve_host,
  port = delve_port,
  id = "go",
  options = {
    initialize_timeout_sec = 20,
    disconnect_timeout_sec = 10,
  },
}

local function make_bazel_attach(nebo_root)
  return {
    name = "Attach to Bazel Go test (" .. vim.fs.basename(nebo_root) .. ")",
    type = "bazel_go",
    request = "attach",
    mode = "remote",
    host = delve_host,
    port = delve_port,
    showLog = true,
    substitutePath = substitute_paths(nebo_root),
  }
end

dap.configurations.go = dap.configurations.go or {}
table.insert(
  dap.configurations.go,
  setmetatable({
    name = "Attach to running Bazel Go test",
    type = "bazel_go",
    request = "attach",
  }, {
    __call = function()
      local nebo_root = find_nebo_root()
      if not nebo_root then
        vim.notify(
          "Could not find a Nebo repository from the current buffer or working directory",
          vim.log.levels.ERROR,
          { title = "Bazel debugger" }
        )
        return {
          name = "Attach to running Bazel Go test",
          type = "bazel_go",
          request = "attach",
          substitutePath = dap.ABORT,
        }
      end
      return make_bazel_attach(nebo_root)
    end,
  })
)

dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
  controls = {
    enabled = true,
    element = "repl",
  },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.35 },
        { id = "stacks", size = 0.30 },
        { id = "watches", size = 0.20 },
        { id = "breakpoints", size = 0.15 },
      },
      position = "left",
      size = 48,
    },
    {
      elements = {
        { id = "repl", size = 0.55 },
        { id = "console", size = 0.45 },
      },
      position = "bottom",
      size = 14,
    },
  },
  floating = {
    border = "rounded",
  },
})

require("nvim-dap-virtual-text").setup({
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,
  highlight_new_as_changed = true,
  show_stop_reason = true,
  commented = true,
  only_first_definition = true,
  all_references = false,
  virt_text_pos = "eol",
})

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })
vim.fn.sign_define("DapBreakpointRejected", { text = "×", texthl = "DiagnosticError" })

dap.listeners.before.attach.dapui = function()
  dapui.open()
end
dap.listeners.before.launch.dapui = function()
  dapui.open()
end

-- Keep the UI open after a failure so scopes, output, and the last stack remain
-- visible. Close it explicitly with <leader>du.

local function map(lhs, rhs, description, mode)
  vim.keymap.set(mode or "n", lhs, rhs, { silent = true, desc = "Debug: " .. description })
end

map("<F5>", dap.continue, "continue/start")
map("<F9>", dap.toggle_breakpoint, "toggle breakpoint")
map("<F10>", dap.step_over, "step over")
map("<F11>", dap.step_into, "step into")
map("<F12>", dap.step_out, "step out")
map("<leader>db", dap.toggle_breakpoint, "toggle breakpoint")
map("<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, "conditional breakpoint")
map("<leader>dl", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, "log point")
map("<leader>dc", dap.run_to_cursor, "run to cursor")
map("<leader>dr", dap.repl.open, "open REPL")
map("<leader>du", dapui.toggle, "toggle UI")
map("<leader>dt", dap.terminate, "terminate")
map("<leader>dx", dap.disconnect, "disconnect")
map("<leader>dh", require("dap.ui.widgets").hover, "hover value", { "n", "v" })
map("<leader>de", dapui.eval, "evaluate expression", { "n", "v" })

local function attach_when_ready(nebo_root)
  if dap.session() then
    vim.notify("A debug session is already active", vim.log.levels.WARN)
    return
  end
  dap.run(make_bazel_attach(nebo_root))
end

local function test_name_at_cursor()
  local word = vim.fn.expand("<cword>")
  if word:match("^Test[%w_]+$") then
    return word
  end

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_line, false)
  for index = #lines, 1, -1 do
    local name = lines[index]:match("^%s*func%s+(Test[%w_]+)%s*%(")
    if name then
      return name
    end
  end

  return nil
end

local function start_dataplane_test(test_name)
  local nebo_root = find_nebo_root()
  if not nebo_root then
    vim.notify(
      "Could not find a Nebo repository from the current buffer or working directory",
      vim.log.levels.ERROR,
      { title = "Bazel debugger" }
    )
    return
  end

  local source_file = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  local bazel_target, target_error = find_go_test_target(nebo_root, source_file)
  if not bazel_target then
    vim.notify(target_error, vim.log.levels.ERROR, { title = "Bazel debugger" })
    return
  end

  if test_name == nil or test_name == "" then
    test_name = test_name_at_cursor() or vim.fn.input("Go test name: ")
  end

  if not test_name:match("^Test[%w_]+$") then
    vim.notify("Expected a Go test name such as TestDataplaneECMPConntrack", vim.log.levels.ERROR)
    return
  end

  -- Testcontainers otherwise turns Docker discovery failures into an opaque Go
  -- panic which DAP renders as a numeric interface address. Fail here with the
  -- real Docker CLI error instead.
  local docker_check = vim.system({ "docker", "info" }, { text = true }):wait()
  if docker_check.code ~= 0 then
    local reason = docker_check.stderr
    if reason == nil or reason == "" then
      reason = docker_check.stdout
    end
    vim.notify(
      "Docker is not available to this Neovim process:\n" .. (reason or "unknown docker info failure"),
      vim.log.levels.ERROR,
      { title = "Bazel debugger" }
    )
    return
  end

  vim.cmd("botright 14split")
  vim.cmd("enew")
  local terminal_buffer = vim.api.nvim_get_current_buf()
  local uv = vim.uv or vim.loop
  vim.api.nvim_buf_set_name(terminal_buffer, "bazel-debug-" .. test_name .. "-" .. uv.hrtime())

  local attached = false
  local function inspect_output(_, data)
    if attached or not data then
      return
    end
    for _, line in ipairs(data) do
      if line:find("API server listening", 1, true) then
        attached = true
        vim.schedule(function()
          attach_when_ready(nebo_root)
        end)
      end
    end
  end

  local command = {
    nebo_root .. "/bazel",
    "run",
    "-c",
    "dbg",
    "--run_under=//nebazel/bzl/tools/dlv exec --headless --api-version=2 --log --log-output=dap,debugger --listen="
      .. delve_host
      .. ":"
      .. delve_port,
    bazel_target,
    "--",
    "-test.run=^" .. test_name .. "$",
    "-test.v",
    "-test.parallel=1",
    "-test.timeout=0",
  }

  vim.fn.termopen(command, {
    cwd = nebo_root,
    env = {
      DOCKER_HOST = vim.env.DOCKER_HOST or "unix:///var/run/docker.sock",
      TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = vim.env.TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE
        or "/var/run/docker.sock",
    },
    on_stdout = inspect_output,
    on_stderr = inspect_output,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 and not attached then
        vim.schedule(function()
          vim.notify("Bazel debug launch exited with code " .. exit_code, vim.log.levels.ERROR)
        end)
      end
    end,
  })
  vim.notify(
    "Debugging " .. bazel_target .. " from " .. nebo_root,
    vim.log.levels.INFO,
    { title = "Bazel debugger" }
  )
  vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("BazelDebugDataplane", function(options)
  start_dataplane_test(options.args)
end, {
  nargs = "?",
  desc = "Build the current Go test target with Bazel and debug it with Delve",
})

vim.api.nvim_create_user_command("BazelDebugGoTest", function(options)
  start_dataplane_test(options.args)
end, {
  nargs = "?",
  desc = "Build the current Go test target with Bazel and debug it with Delve",
})

map("<leader>dd", function()
  start_dataplane_test()
end, "Bazel Go test")
