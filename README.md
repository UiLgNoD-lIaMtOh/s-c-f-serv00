# s-c-f-serv00
sing-box + cloudflare + freebsd 支持在 serv00 上搭建 vless(cloudflare) + vmess(cloudflare) + trojan(cloudflare) 3 个节点
这个脚本会占用 3 个 tcp 端口，如果有其他需求你可以自行爆改本脚本  
![Watchers](https://img.shields.io/github/watchers/UiLgNoD-lIaMtOh/s-c-f-serv00) ![Stars](https://img.shields.io/github/stars/UiLgNoD-lIaMtOh/s-c-f-serv00) ![Forks](https://img.shields.io/github/forks/UiLgNoD-lIaMtOh/s-c-f-serv00) ![Vistors](https://visitor-badge.laobi.icu/badge?page_id=UiLgNoD-lIaMtOh.s-c-f-serv00) ![LICENSE](https://img.shields.io/badge/license-CC%20BY--SA%204.0-green.svg)
<a href="https://star-history.com/#UiLgNoD-lIaMtOh/s-c-f-serv00&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=UiLgNoD-lIaMtOh/s-c-f-serv00&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=UiLgNoD-lIaMtOh/s-c-f-serv00&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=UiLgNoD-lIaMtOh/s-c-f-serv00&type=Date" />
  </picture>
</a>  
# 下载本脚本到 serv00 服务器
    # -1.登录 serv00 服务器并执行命令下载脚本到 serv00 服务器
    rm -fv ${HOME}/s-c-f-serv00.sh
    wget -t 3 -T 10 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c \
                          "https://raw.githubusercontent.com/UiLgNoD-lIaMtOh/s-c-f-serv00/master/s-c-f-serv00.sh" \
                          -O ${HOME}/s-c-f-serv00.sh
  ![image](assets/00.jpeg)

# serv00 开放端口，搭建 ARGO cloudflare tunnel 固定
    # 0.前提开放 serv00 vmess 端口比如 9246 9247 9248 并打开文件管理打开脚本进行编辑替换端口
  ![image](assets/01.jpeg)
  ![image](assets/02.jpeg)
  ![image](assets/03.jpeg)
  ![image](assets/04.jpeg)
  ![image](assets/05.jpeg)

    # 1.前提有个域名 cloudns 可以免费注册一个二级域名，比如得到 fine.dns-dynamic.net
  ![image](assets/06.jpeg)
  ![image](assets/07.jpeg)
  ![image](assets/08.jpeg)

    # 2.将 fine.dns-dynamic.net 托管到 cloudflare 并将 cloudflare 的两个 dns 添加到 cloudns dns 记录中，并删除 cloudns 其他 NS
  ![image](assets/09.jpeg)
  ![image](assets/10.jpeg)
  ![image](assets/11.jpeg)
  ![image](assets/12.jpeg)
  ![image](assets/13.jpeg)
  ![image](assets/14.jpeg)
  ![image](assets/15.jpeg)
  ![image](assets/16.jpeg)
  ![image](assets/17.jpeg)
  ![image](assets/18.jpeg)
  ![image](assets/19.jpeg)
  ![image](assets/20.jpeg)
  ![image](assets/21.jpeg)
  ![image](assets/22.jpeg)
  ![image](assets/23.jpeg)
  ![image](assets/24.jpeg)
  ![image](assets/25.jpeg)
  ![image](assets/26.jpeg)

  ![image](assets/27.jpeg)
    
    # 3.进入 cloudflare network tunnel 添加一个 tunnel 得到 token 并保留 ey开头后面的字符替换到脚本 
  ![image](assets/28.jpeg)
  ![image](assets/29.jpeg)
  ![image](assets/30.jpeg)
  ![image](assets/31.jpeg)
  ![image](assets/32.jpeg)
  ![image](assets/33.jpeg)
  ![image](assets/34.jpeg)
  ![image](assets/35.jpeg)
  ![image](assets/36.jpeg)
  ![image](assets/37.jpeg)
  ![image](assets/38.jpeg)

    # 4.在 tunnel 中添加一个自定义域名比如 serv00-one.fine.dns-dynamic.net 添加server比如 http://localhost:9246 9246 就是 serv00 开放端口
  ![image](assets/39.jpeg)
  ![image](assets/40.jpeg)
  ![image](assets/41.jpeg)
  ![image](assets/42.jpeg)

    # 5.执行脚本，得到订阅信息和客户端文件，并且可以在 serv00 panel 里下载支持 mihomo nekobox 或者 sing-box 的配置文件
    chmod -v u+x ${HOME}/s-c-f-serv00.sh
    bash ${HOME}/s-c-f-serv00.sh
  ![image](assets/43.jpeg)
  ![image](assets/44.jpeg)

# serv00 保活，防止3个月回收
    # 6.serv00 服务器保活，防止3个月回收

    # serv00 保活脚本
    cat <<UiLgNoD-lIaMtOh | tee ${HOME}/auto_ssh.sh
    #!/bin/bash
    sshpass -p 'ssh密码' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -tt $(whoami)@$(hostname) "uname -a" &
    UiLgNoD-lIaMtOh

    # 执行测试
    chmod -v u+x ${HOME}/auto_ssh.sh ; bash ${HOME}/auto_ssh.sh

    # 查看当前 crontab
    echo '当前 crontab'
    crontab -l
    
    # 写入 crontab 
    cat <<UiLgNoD-lIaMtOh | tee ${HOME}/crontab >/dev/null
    $(crontab -l | sed '/auto_ssh.sh/d')
    @reboot cd ${HOME} ; bash auto_ssh.sh >/dev/null 2>&1
    UiLgNoD-lIaMtOh
    crontab ${HOME}/crontab
    rm -fv ${HOME}/crontab
    
    # 检查写入之后的 crontab
    echo '写入之后的 crontab'
    crontab -l

# 效果
    # 嗯还好，总比没有强，优选IP之后效果会好一些
  ![image](assets/45.jpeg)

# 注意
    ！！！！！！！！！！！！注意！！！！！！！！！！！！！！！
    # 有时候？忽然连不上了
    # 执行以下命令查看进程是否启动？
    # sing-box-freebsd 进程
    ps | grep -v grep | grep sing-box-freebsd
    # cloudflared-freebsd 进程
    ps | grep -v grep | grep cloudflared-freebsd
    
    # 查看一下日志是否有可用信息？
    # sing-box-freebsd 日志
    tail -f -n 200 ${HOME}/s-c-f-serv00-*/sing-box.log
    # cloudflared-freebsd 日志
    tail -f -n 200 ${HOME}/s-c-f-serv00-*/cloudflared.log
    
    # 如果一切正常有可能 serv00 服务器重新启动了导致 uuid 自动改变了
    # 可以执行以下命令查看重启后新生成的配置文件信息
    cat ${HOME}/s-c-f-serv00-*/result.txt
    
    # 当然也有可能重启后也可能根本没有启动，那就手动执行脚本吧？
    bash s-c-f-serv00.sh
    
    # 什么执行脚本都不行连不上？啊，那替换优选IP试试？
    
    # 什么什么还是不行吗？啊？那那你看看边缘证书绿了没有啊？
    
    # 啊？什么什么还是不行？啊好烦啊，唉，我尽力了。。。
    ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

# 声明
本项目仅作学习交流使用，用于查找资料，学习知识，不做任何违法行为。所有资源均来自互联网，仅供大家交流学习使用，出现违法问题概不负责。

# 感谢
serv00 Revolutionary Free Hosting: [https://www.serv00.com/offer](https://www.serv00.com/offer)  
cloudns domain for free: [https://www.cloudns.net/](https://www.cloudns.net/)  
cloudflare dashboard for free: [https://dash.cloudflare.com/](https://dash.cloudflare.com/)  
cloudflared: [https://github.com/cloudflare/cloudflared](https://github.com/cloudflare/cloudflared)
sing-box: [https://github.com/SagerNet/sing-box](https://github.com/SagerNet/sing-box)
~yuri@FreeBSD.org sing-box for freebsd:[https://www.freshports.org/net/sing-box](https://www.freshports.org/net/sing-box)~  
~Unofficial FreeBSD cloudflared builds : [https://cloudflared.bowring.uk/](https://cloudflared.bowring.uk/)~  
Saika's Blog serv00自动续期：[https://saika.us.kg/2024/01/27/serv00_logs/#%E8%87%AA%E5%8A%A8%E7%BB%AD%E6%9C%9F](https://saika.us.kg/2024/01/27/serv00_logs/#%E8%87%AA%E5%8A%A8%E7%BB%AD%E6%9C%9F)  
