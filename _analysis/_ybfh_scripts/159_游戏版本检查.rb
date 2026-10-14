#==============================================================================
# ■ 游戏版本检查
# By ：VIPArcher [email: VIPArcher@sina.com]
#  -- 本脚本来自 httprm.66rpg.com 使用或转载请保留以上信息。
#==============================================================================
#==============================================================================
# 调用方法:
#     打开网页: VIPArcher.open_url("网址")
#     版本检查: Game_Version.check
#     获取版本: Game_Version.version
#==============================================================================
$VIPArcherScript ||= {};$VIPArcherScript[:version_check] = 20150401
=begin
 脚本用法:
     使用这个大概你得有一点脚本基础？会正则的话最好啦。如果使用git就更方便了
 使用 Lofter 姿势:
     在你的 Lofter 上发布一条新博客，然后把这条博客的地址填到这个脚本的 Ver_Url 里
 博客的内容尽量简短一些，比如可以博客内容：
     
           标题:XXX游戏版本已更新到1.30
           
           内容:写什么都可以，只写"[Version:1.30]"也行
                然后关键的是必须包含这个: [Version:1.30]
           
 然后下面设置中正则写成  Regexp_Text =  /\[Version:([\d\.]+)\]/i
 每次你自己更新游戏就去编辑一次那条博客。
 推荐的使用方式:
     使用github，上传一个写着游戏版本内容的页面或者文件，然后去匹配它。会用git的话，我
 觉得剩下的你都可以自己弄了。噗噗噗。
=end

module VIPArcher
 
  # 链接设置
  # 游戏主页地址
  Home_Url     = 'https://tieba.baidu.com/f?kw=%E9%AD%94%E5%A1%94&fr=wwwt

'
  # 游戏下载页地址
  Download_Url = 'http://zhengguanguan.lofter.com/post/30ad87da_1c6436c24

'
  # 储存游戏版本的页面地址
  Ver_Url      = 'http://zhengguanguan.lofter.com/post/30ad87da_1c6436c24 

'  #远端版本页
 
  # API
  ShellExecuteA          = Win32API.new('shell32', 'ShellExecuteA'         , 'pppppi', 'i')
  URLDownloadToCacheFile = Win32API.new('Urlmon' , 'URLDownloadToCacheFile', 'ippiii', 'i')
  User32_msgbox          = Win32API.new('user32' , 'MessageBoxW'           , 'LppL'  , 'L')
 
  # 方法
  # 打开网页 url
  def self.open_url(url)
    ShellExecuteA.call(0, 'open', url, 0, 0, 1)
  end
  # UTF_8转为宽字符
  def self.utf8_to_wide(str)
    str.unpack("U*").pack("S*")
  end
  # 宽字符转为UTF_8
  def self.wide_to_utf8(str)
    str.unpack("S*").pack("U*")
  end
end

The_Current_Version = "0.6" # 当前游戏版本
module Game_Version
 
  Regexp_Text         = /\[Version:([\d\.]+)\]/i  # 匹配版本的正则
 
  # 用语设置
  # 当前版本提示方式
  Current_Version_Hint = "当前游戏版本为v%s，最新版本为v%s，是否前去下载？\n如果需要关闭更新检查请在游戏设置中调整"
  # 没有新版本
  No_New_Version_Hint  = "当前游戏已经是最新版本，祝您游戏愉快！"
  # 新版本提示
  New_Version_Hint     = "游戏已更新到%s版，是否前往下载更新?"
  #检查失败提示
  Check_Failure_Hint    = "版本检查失败！您可以前往查看最新版本信息"
  class << self
    include VIPArcher
    # 版本检查
    def check
      title = VIPArcher.utf8_to_wide("联网检查游戏的最新版") + "\0\0"
      the_version_hint = sprintf(Current_Version_Hint, The_Current_Version, @version)
      text = VIPArcher.utf8_to_wide(the_version_hint) + "\0\0"
      user = User32_msgbox.call(0, text, title, 32 | 4)
      return unless user == 6; return unless version
      return p No_New_Version_Hint if The_Current_Version == @version
      VIPArcher.open_url(Download_Url)
      p "已在浏览器中打开下载地址，请查看你的浏览器。"
      exit
=begin    
      title = VIPArcher.utf8_to_wide("是否前往贴吧下载更新？") + "\0\0"
      version_hint = sprintf(New_Version_Hint, @version)
      text = VIPArcher.utf8_to_wide(version_hint) + "\0\0"
      if User32_msgbox.call(0, text,title , 64 | 4) == 6
        VIPArcher.open_url(Download_Url)
        exit
        #p "已在浏览器中打开贴吧，请查看你的浏览器。"
      end
=end
    end
    # 获取最新版本信息
    def version
      begin
        URLDownloadToCacheFile.call(0,Ver_Url,buf = "\0" * 1024,1024,0,0)
        a=buf.sub(/\0+$/){}
        if a==""
          p "无法获取版本信息，请检查你的网络是否正常。如果需要关闭更新检查请在游戏设置中调整"
          return The_Current_Version
        end
        if open(buf.sub(/\0+$/){}, 'rb') { |p| p.read } =~ Regexp_Text
          @version = $1
          return @version
        else
          p "无法正确获取版本信息，您可以尝试前往贴吧查看最新版本！"
          VIPArcher.open_url(Home_Url); false
        end
      rescue Errno::ENOENT
        p "#{Check_Failure_Hint}"; false
      end
    end
  end
end
if $game_config.data("versionCheck")==1
if Game_Version.version != The_Current_Version
  Game_Version.check
end
end