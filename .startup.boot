{
  preload = {
    "/packages/lzwfs/startup.lua",
  },
  delay = 1.5,
  menu = {
    {
      prompt = "CraftOS 1.9",
    },
    {
      prompt = "Opus",
      args = {
        "/sys/boot/opus.lua",
      },
    },
    {
      prompt = "Opus Shell",
      args = {
        "/sys/boot/opus.lua",
        "/sys/apps/shell.lua",
      },
    },
    {
      prompt = "Opus Kiosk",
      args = {
        "/sys/boot/kiosk.lua",
      },
    },
    {
      prompt = "Opus TLCO",
      args = {
        "/sys/boot/tlco.lua",
      },
    },
  },
}