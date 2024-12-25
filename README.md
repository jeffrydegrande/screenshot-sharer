Screenshot-uploader is a shell script used for uploading
screenshots to my personal server.

It does the following steps:

- Take a screenshot of the current screen or a selected area and write to stdout. Possible programs to use are `maim`, `scrot` or `slop`.
  OPTIONAL: abstract and use alternatives for wayland such as `grim` and `slurp`.
- Use satty to annotate the screenshot.
- The result is uploaded to a server.
- The URL is copied to the clipboard.
