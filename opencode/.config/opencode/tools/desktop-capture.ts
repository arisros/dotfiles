import { tool } from "@opencode-ai/plugin"
import path from "node:path"

const FRONT_WINDOW_SCRIPT = String.raw`
set text item delimiters to tab
tell application "System Events"
  set p to first application process whose frontmost is true
  set appName to name of p
  set w to front window of p
  set titleName to name of w
  set {xPos, yPos} to position of w
  set {wSize, hSize} to size of w
  return appName & tab & titleName & tab & xPos & tab & yPos & tab & wSize & tab & hSize
end tell
`

const APP_WINDOW_SCRIPT = String.raw`
on run argv
  set targetApp to item 1 of argv
  set targetIndex to item 2 of argv as integer
  set text item delimiters to tab
  tell application "System Events"
    set p to first application process whose name is targetApp
    set w to window targetIndex of p
    set titleName to name of w
    set {xPos, yPos} to position of w
    set {wSize, hSize} to size of w
    return targetApp & tab & titleName & tab & xPos & tab & yPos & tab & wSize & tab & hSize
  end tell
end run
`

function parseBounds(raw: string) {
  const [app, title, x, y, width, height] = raw.trim().split("\t")
  if (!app || !title || !x || !y || !width || !height) {
    throw new Error("Failed to parse window bounds from macOS automation output")
  }

  return {
    app,
    title,
    x: Number(x),
    y: Number(y),
    width: Number(width),
    height: Number(height),
  }
}

export default tool({
  description: "Capture macOS screen or window to PNG",
  args: {
    mode: tool.schema
      .enum(["screen", "frontmost-window", "app-window"])
      .describe("Capture full screen, frontmost window, or a specific app window"),
    appName: tool.schema
      .string()
      .optional()
      .describe("Required for mode='app-window', exact app name, for example 'Ghostty'"),
    windowIndex: tool.schema
      .number()
      .int()
      .min(1)
      .max(50)
      .optional()
      .describe("Window index for mode='app-window' (default: 1)"),
    outputPath: tool.schema
      .string()
      .optional()
      .describe("Optional output path; default is /tmp/opencode-captures/<timestamp>.png"),
    includeShadow: tool.schema
      .boolean()
      .optional()
      .describe("Include window shadow for window captures (default: false)"),
  },
  async execute(args, context) {
    const captureDir = "/tmp/opencode-captures"
    await Bun.$`mkdir -p ${captureDir}`

    const safeName = args.mode.replace(/[^a-z-]/g, "")
    const defaultName = `${new Date().toISOString().replace(/[:.]/g, "-")}-${safeName}.png`
    const resolvedPath = args.outputPath
      ? path.isAbsolute(args.outputPath)
        ? args.outputPath
        : path.join(context.directory, args.outputPath)
      : path.join(captureDir, defaultName)

    if (args.mode === "screen") {
      await Bun.$`screencapture -x ${resolvedPath}`
      return {
        mode: args.mode,
        outputPath: resolvedPath,
      }
    }

    if (args.mode === "app-window" && !args.appName) {
      throw new Error("appName is required when mode is 'app-window'")
    }

    const includeShadow = args.includeShadow ?? false

    const boundsResult =
      args.mode === "frontmost-window"
        ? await Bun.$`osascript -e ${FRONT_WINDOW_SCRIPT}`.text()
        : await Bun.$`osascript -e ${APP_WINDOW_SCRIPT} ${args.appName ?? ""} ${String(args.windowIndex ?? 1)}`.text()

    const bounds = parseBounds(boundsResult)
    const rect = `${bounds.x},${bounds.y},${bounds.width},${bounds.height}`
    if (includeShadow) {
      await Bun.$`screencapture -x -R ${rect} ${resolvedPath}`
    } else {
      await Bun.$`screencapture -x -o -R ${rect} ${resolvedPath}`
    }

    return {
      mode: args.mode,
      app: bounds.app,
      title: bounds.title,
      bounds: {
        x: bounds.x,
        y: bounds.y,
        width: bounds.width,
        height: bounds.height,
      },
      outputPath: resolvedPath,
    }
  },
})
