module Graphics
  HWND = Win32API.new('user33', 'GetHWND', 'v', 'i').call
end