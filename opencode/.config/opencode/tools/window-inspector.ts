import { tool } from "@opencode-ai/plugin"

type WindowInfo = {
  app: string
  title: string
  index: number
  x: number
  y: number
  width: number
  height: number
  frontmost: boolean
}

function parseWindowRows(raw: string): WindowInfo[] {
  const lines = raw
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean)

  return lines
    .map((line) => {
      const [app, title, index, x, y, width, height, frontmost] = line.split("\t")
      if (!app || !title || !index || !x || !y || !width || !height || !frontmost) {
        return null
      }
      return {
        app,
        title,
        index: Number(index),
        x: Number(x),
        y: Number(y),
        width: Number(width),
        height: Number(height),
        frontmost: frontmost === "true",
      }
    })
    .filter((row): row is WindowInfo => row !== null)
}

const APPLE_SCRIPT = String.raw`
set text item delimiters to tab
tell application "System Events"
  set outputRows to {}
  set appList to application processes whose background only is false
  repeat with p in appList
    set appName to name of p
    set appFrontmost to frontmost of p
    try
      set winList to windows of p
      set winCount to count of winList
      if winCount > 0 then
        repeat with i from 1 to winCount
          set w to window i of p
          set t to name of w
          set {xPos, yPos} to position of w
          set {wSize, hSize} to size of w
          set end of outputRows to appName & tab & t & tab & i & tab & xPos & tab & yPos & tab & wSize & tab & hSize & tab & appFrontmost
        end repeat
      end if
    end try
  end repeat
end tell
set text item delimiters to linefeed
return outputRows as text
`

export default tool({
  description: "List open macOS app windows with titles and bounds",
  args: {
    app: tool.schema
      .string()
      .optional()
      .describe("Optional app name filter, for example 'Ghostty'"),
    limit: tool.schema
      .number()
      .int()
      .min(1)
      .max(200)
      .optional()
      .describe("Maximum number of windows to return (default: 50)"),
    frontmostOnly: tool.schema
      .boolean()
      .optional()
      .describe("Return only the frontmost app windows (default: false)"),
  },
  async execute(args) {
    const result = await Bun.$`osascript -e ${APPLE_SCRIPT}`.text()
    const appFilter = args.app?.toLowerCase()
    const limit = args.limit ?? 50
    const frontmostOnly = args.frontmostOnly ?? false

    let windows = parseWindowRows(result)
    if (appFilter) {
      windows = windows.filter((window) => window.app.toLowerCase().includes(appFilter))
    }
    if (frontmostOnly) {
      windows = windows.filter((window) => window.frontmost)
    }

    const sorted = windows.sort((a, b) => {
      if (a.frontmost !== b.frontmost) {
        return a.frontmost ? -1 : 1
      }
      if (a.app !== b.app) {
        return a.app.localeCompare(b.app)
      }
      return a.index - b.index
    })

    return {
      count: sorted.length,
      windows: sorted.slice(0, limit),
      note:
        "If this returns empty, grant Accessibility permission to your terminal/OpenCode process in macOS System Settings.",
    }
  },
})
