#!/usr/bin/env bash
# 起始时间
REPORT_DATE="$(TZ=':Asia/Shanghai' date +'%Y-%m-%d %T')"
REPORT_DATE_S="$(TZ=':Asia/Shanghai' date +%s)"

# 传入端口号，赋值给 PORT 请换成自己的
# vless port
V_PORT_1='9246'
# vmess port
VM_PORT_2='9247'
# trojan port
T_PORT_3='9248'

# ARGO 隧道 token ，请换成自己的
ARGO_AUTH='eyJhIjoiZDkyYTUyMDAxZDNiNWM4N2ExYzFmYzc2ZGFjZTFlMTYiLCJ0IjoiODU0MDEzNTctZGIyNy00NDExLWEwNmYtYjVkMTU5YThmODlmIiwicyI6IlpUZGlabVpoT1RndFlUYzBNaTAwTXpnMUxXSmtaRFV0TkRKa09HRmtZMkUyTlRNNCJ9'

# 从 cloudflared-freebsd 日志中获得遂穿域名，请换成自己的
# vless 域名
CLOUDFLARED_DOMAIN_V_1='serv00-one.fine.dns-dynamic.net'
# vmess 域名
CLOUDFLARED_DOMAIN_VM_2='serv00-two.fine.dns-dynamic.net'
# trojan 域名
CLOUDFLARED_DOMAIN_T_3='serv00-three.fine.dns-dynamic.net'

# 优选域名
# 可以提前本地测速自定义修改优选域名或IP可能会起到加速作用
# vless
V_WEBSITE=cloudflare.182682.xyz
# vmess
VM_WEBSITE=cloudflare.182682.xyz
# trojan
T_WEBSITE=cloudflare.182682.xyz

# 优选域名或IP端口
# vless
CLOUDFLARED_PORT_V=443
# vmess
CLOUDFLARED_PORT_VM=443
# trojan
CLOUDFLARED_PORT_T=443

echo 本脚本会占用3个tcp端口，如果有需求，可以自己爆改

# Enables the ability to run your own software
devil binexec on
# Set Devil and shell language to English
devil lang set english
# Get a list of all available IP addresses owned by Serv00.com
devil vhost list public
# Display the list of reserved ports
devil port list

# 创建进入自定义目录
rm -rfv ${HOME}/s-c-f-serv00-*
mkdir -pv ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/ ; cd ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/

# 生成服务器配置 启动进程 生成客户端配置
makeAndrun() {
    # sing-box-freebsd 服务器配置所需变量
    # 配置所需变量
    # 协议
    V_PROTOCOL=vless
    VM_PROTOCOL=vmess
    T_PROTOCOL=trojan
    # 入站名
    V_PROTOCOL_IN_TAG_1=$V_PROTOCOL-in-1
    VM_PROTOCOL_IN_TAG_2=$VM_PROTOCOL-in-2
    T_PROTOCOL_IN_TAG_3=$T_PROTOCOL-in-3
    # sing-box-freebsd 生成 uuid
    V_UUID_1="$(${HOME}/s-c-f-serv00-${REPORT_DATE_S}/sing-box-freebsd generate uuid)"
    VM_UUID_2="$(${HOME}/s-c-f-serv00-${REPORT_DATE_S}/sing-box-freebsd generate uuid)"
    T_UUID_3="$(${HOME}/s-c-f-serv00-${REPORT_DATE_S}/sing-box-freebsd generate uuid)"
    # V2Ray传输层类型
    VV_TYPE=ws
    VMV_TYPE=ws
    T_TYPE=ws
    # sing-box-freebsd 生成 12 位 vmess hex 路径
    V_PATH_1="$(${HOME}/s-c-f-serv00-${REPORT_DATE_S}/sing-box-freebsd generate rand --hex 6)"
    VM_PATH_2="$(${HOME}/s-c-f-serv00-${REPORT_DATE_S}/sing-box-freebsd generate rand --hex 6)"
    T_PATH_3="$(${HOME}/s-c-f-serv00-${REPORT_DATE_S}/sing-box-freebsd generate rand --hex 6)"

    # 写入服务器端 sing-box-freebsd 配置文件
    cat <<UiLgNoD-lIaMtOh | tee ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/config.json >/dev/null
{
  "log": {
    "disabled": false,
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "sniff": true,
      "sniff_override_destination": true,
      "type": "$V_PROTOCOL",
      "tag": "$V_PROTOCOL_IN_TAG_1",
      "listen": "::",
      "listen_port": $V_PORT_1,
      "users": [
        {
          "uuid": "$V_UUID_1",
          "flow": ""
        }
      ],
      "transport": {
        "type": "$VV_TYPE",
        "path": "$V_PATH_1",
        "max_early_data": 2560,
        "early_data_header_name": "Sec-WebSocket-Protocol"
      }
    },
    {
      "sniff": true,
      "sniff_override_destination": true,
      "type": "$VM_PROTOCOL",
      "tag": "$VM_PROTOCOL_IN_TAG_2",
      "listen": "::",
      "listen_port": $VM_PORT_2,
      "users": [
        {
          "uuid": "$VM_UUID_2",
          "alterId": 0
        }
      ],
      "transport": {
        "type": "$VMV_TYPE",
        "path": "$VM_PATH_2",
        "max_early_data": 2560,
        "early_data_header_name": "Sec-WebSocket-Protocol"
      }
    },
    {
      "sniff": true,
      "sniff_override_destination": true,
      "type": "$T_PROTOCOL",
      "tag": "$T_PROTOCOL_IN_TAG_3",
      "listen": "::",
      "listen_port": $T_PORT_3,
      "users": [
        {
          "password": "$T_UUID_3"
        }
      ],
      "transport": {
        "type": "$T_TYPE",
        "path": "$T_PATH_3",
        "max_early_data": 2560,
        "early_data_header_name": "Sec-WebSocket-Protocol"
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ]
}
UiLgNoD-lIaMtOh

    # 启动 sing-box-freebsd 服务
    nohup ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/sing-box-freebsd run -c ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/config.json > ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/sing-box.log 2>&1 & disown
    # 后台启用 cloudflared-freebsd 获得隧穿日志并脱离 shell 终端寿命
    nohup ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/cloudflared-freebsd tunnel --edge-ip-version auto --protocol http2 run --token $ARGO_AUTH > ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/cloudflared.log 2>&1 & disown

    # 睡 5 秒，让 cloudflared-freebsd 充分运行
    sleep 5

    # sing-box-freebsd 客户端配置所需变量
    # 出站代理名
    SB_ALL_PROTOCOL_OUT_TAG=proxy
    # 出站类型
    SB_ALL_PROTOCOL_OUT_TYPE=selector
    # 组
    SB_ALL_PROTOCOL_OUT_GROUP_TAG=sing-box-freebsd

    # vless 出站名
    SB_V_PROTOCOL_OUT_TAG_1=$V_PROTOCOL-out-1
    # vmess 出站名
    SB_VM_PROTOCOL_OUT_TAG_2=$VM_PROTOCOL-out-2
    # trojan 出站名
    SB_T_PROTOCOL_OUT_TAG_3=$T_PROTOCOL-out-3

    # 浏览器
    BROWSER=chrome

    # 节点链接
    VLESS_LINK_1="vless://$V_UUID_1@$V_WEBSITE:$CLOUDFLARED_PORT_V?encryption=none&security=tls&sni=$CLOUDFLARED_DOMAIN_V_1&fp=$BROWSER&type=$VV_TYPE&host=$CLOUDFLARED_DOMAIN_V_1&path=%2F$V_PATH_1%3Fed%3D2506#$SB_V_PROTOCOL_OUT_TAG_1"
    VMESS_LINK_2='vmess://'$(echo '{"add":"'$VM_WEBSITE'","aid":"0","alpn":"","fp":"'$BROWSER'","host":"'$CLOUDFLARED_DOMAIN_VM_2'","id":"'$VM_UUID_2'","net":"'$VMV_TYPE'","path":"/'$VM_PATH_2'?ed\u003d2560","port":"'$CLOUDFLARED_PORT_VM'","ps":"'$SB_VM_PROTOCOL_OUT_TAG_2'","scy":"auto","sni":"'$CLOUDFLARED_DOMAIN_VM_2'","tls":"tls","type":"","v":"2"}' | base64 -w 0)
    TROJAN_LINK_3="trojan://$T_UUID_3@$T_WEBSITE:$CLOUDFLARED_PORT_T?security=tls&sni=$CLOUDFLARED_DOMAIN_T_3&fp=$BROWSER&type=ws&host=$CLOUDFLARED_DOMAIN_T_3&path=%2F$T_PATH_3%3Fed%3D2560#$SB_T_PROTOCOL_OUT_TAG_3"

    # 写入 nekobox 客户端配置到 client-nekobox-config.yaml 文件
    cat <<UiLgNoD-lIaMtOh | tee ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/client-nekobox-config.yaml >/dev/null
port: 7891
socks-port: 7892
mixed-port: 7893
external-controller: :7894
redir-port: 7895
tproxy-port: 7896
allow-lan: true
mode: rule
log-level: debug
dns:
  enable: false # set true to enable dns (default is false)
  listen: 127.0.0.1:7053
  nameserver:
     - 119.29.29.29
     - 114.114.114.114
  fallback: # concurrent request with nameserver, fallback used when GEOIP country isn't CN
     - https://1.1.1.1/dns-query
     - tls://1.0.0.1:853
proxies:
  - {"name": "$SB_V_PROTOCOL_OUT_TAG_1","type": "$V_PROTOCOL","server": "$V_WEBSITE","port": $CLOUDFLARED_PORT_V,"uuid": "$V_UUID_1","udp": true,"tls": true,"client-fingerprint": "$BROWSER","skip-cert-verify": true,"servername": "$CLOUDFLARED_DOMAIN_V_1","network": "$VV_TYPE","ws-opts": {"path": "/$V_PATH_1?ed=2560","headers": {"Host": "$CLOUDFLARED_DOMAIN_V_1"}}}
  - {"name": "$SB_VM_PROTOCOL_OUT_TAG_2","type": "$VM_PROTOCOL","server": "$VM_WEBSITE","port": $CLOUDFLARED_PORT_VM,"uuid": "$VM_UUID_2","alterId": 0,"cipher": "auto","udp": true,"tls": true,"client-fingerprint": "$BROWSER","skip-cert-verify": true,"servername": "$CLOUDFLARED_DOMAIN_VM_2","network": "$VMV_TYPE","ws-opts": {"path": "/$VM_PATH_2?ed=2560","headers": {"Host": "$CLOUDFLARED_DOMAIN_VM_2"}}}
  - {"name": "$SB_T_PROTOCOL_OUT_TAG_3","type": "$T_PROTOCOL","server": "$T_WEBSITE","port": $CLOUDFLARED_PORT_T,"password": "$T_UUID_3","sni": "$CLOUDFLARED_DOMAIN_T_3","udp": true,"tls": true,"client-fingerprint": "$BROWSER","skip-cert-verify": true,"servername": "$CLOUDFLARED_DOMAIN_T_3","network": "$T_TYPE","ws-opts": {"path": "/$T_PATH_3?ed=2560"}}
proxy-groups:
  - name: Auto-Fast
    type: "url-test"
    url: "http://www.gstatic.cn/generate_204"
    interval: 120
    tolerance: 40
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG_1"
        - "$SB_VM_PROTOCOL_OUT_TAG_2"
        - "$SB_T_PROTOCOL_OUT_TAG_3"
  - name: Auto-Edge
    type: "url-test"
    url: "http://www.gstatic.cn/generate_204"
    interval: 600
    tolerance: 50
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG_1"
        - "$SB_VM_PROTOCOL_OUT_TAG_2"
        - "$SB_T_PROTOCOL_OUT_TAG_3"
  - name: Auto-Failover
    type: "url-test"
    url: "http://www.gstatic.cn/generate_204"
    interval: 300
    tolerance: 30
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG_1"
        - "$SB_VM_PROTOCOL_OUT_TAG_2"
        - "$SB_T_PROTOCOL_OUT_TAG_3"
  - name: Express
    type: "fallback"
    url: "http://www.gstatic.cn/generate_204"
    interval: 300
    tolerance: 40
    proxies:
        - Auto-Edge
        - Auto-Fast
        - Auto-Failover
  - name: Auto
    type: "fallback"
    url: "http://www.gstatic.cn/generate_204"
    interval: 600
    proxies:
        - Auto-Fast
        - Auto-Edge
        - Auto-Failover
  - name: Proxy
    type: "select"
    proxies:
        - "Auto"
        - "$SB_V_PROTOCOL_OUT_TAG_1"
        - "$SB_VM_PROTOCOL_OUT_TAG_2"
        - "$SB_T_PROTOCOL_OUT_TAG_3"
  - name: Video
    type: "select"
    interval: 900
    url: "http://www.gstatic.cn/generate_204"
    proxies:
        - Express
        - "$SB_V_PROTOCOL_OUT_TAG_1"
        - "$SB_VM_PROTOCOL_OUT_TAG_2"
        - "$SB_T_PROTOCOL_OUT_TAG_3"
  - name: Netflix
    type: "select"
    url: "http://www.gstatic.cn/generate_204"
    interval: 1200
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG_1"
        - "$SB_VM_PROTOCOL_OUT_TAG_2"
        - "$SB_T_PROTOCOL_OUT_TAG_3"
        - Auto-Edge
        - DIRECT
  - name: Scholar
    type: "fallback"
    url: "http://www.gstatic.cn/generate_204"
    interval: 300
    tolerance: 40
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG_1"
        - "$SB_VM_PROTOCOL_OUT_TAG_2"
        - "$SB_T_PROTOCOL_OUT_TAG_3"
        - Proxy
        - DIRECT
  - name: Steam
    type: "select"
    proxies:
        - "$SB_V_PROTOCOL_OUT_TAG_1"
        - "$SB_VM_PROTOCOL_OUT_TAG_2"
        - "$SB_T_PROTOCOL_OUT_TAG_3"
        - Auto-Edge
        - DIRECT

rules:
#user rules

#EMAIL port
- DST-PORT,25,DIRECT
- DST-PORT,26,DIRECT
- DST-PORT,465,DIRECT
- DST-PORT,587,DIRECT
- DST-PORT,2525,DIRECT

# BT
- DST-PORT,6881,DIRECT
- DST-PORT,6882,DIRECT
- DST-PORT,6883,DIRECT
- DST-PORT,6884,DIRECT
- DST-PORT,6885,DIRECT
- DST-PORT,6886,DIRECT
- DST-PORT,6887,DIRECT
- DST-PORT,6888,DIRECT
- DST-PORT,6889,DIRECT

# check first
- DOMAIN-SUFFIX,qq.com,DIRECT
- DOMAIN-SUFFIX,taobao.com,DIRECT
- DOMAIN-SUFFIX,baidu.com,DIRECT
- DOMAIN-SUFFIX,weibo.com,DIRECT
- DOMAIN-SUFFIX,jd.com,DIRECT
- DOMAIN-SUFFIX,tmall.com,DIRECT
- DOMAIN-SUFFIX,360.cn,DIRECT
- DOMAIN-SUFFIX,zhihu.com,DIRECT
- DOMAIN-SUFFIX,com.cn,DIRECT

# allowed safe trackers
- DOMAIN,graph.instagram.com,DIRECT
- DOMAIN,www.googleadservices.com,DIRECT
- DOMAIN,control.kochava.com,DIRECT
- DOMAIN,www.google-analytics.com,DIRECT
- DOMAIN,ssl.google-analytics.com,DIRECT
- DOMAIN,nexus.officeapps.live.com,DIRECT
- DOMAIN,googleads.g.doubleclick.net,DIRECT
- DOMAIN,e.crashlytics.com,DIRECT
- DOMAIN,ib.adnxs.com,DIRECT
- DOMAIN,safebrowsing.googleapis.com,DIRECT
- DOMAIN-SUFFIX,googlesyndication.com,DIRECT
- DOMAIN-SUFFIX,googletagmanager.com,DIRECT
- DOMAIN-SUFFIX,googletagservices.com,DIRECT

#specific geo services
- DOMAIN-SUFFIX,paypal.com,Proxy
- DOMAIN-SUFFIX,stripe.com,Proxy
- DOMAIN-SUFFIX,bing.com,Proxy

##tiktok
- DOMAIN-SUFFIX,byteoversea.com,Proxy
- DOMAIN-SUFFIX,muscdn.com,Proxy
- DOMAIN-SUFFIX,musical.ly,Proxy
- DOMAIN-SUFFIX,tik-tokapi.com,Proxy
- DOMAIN-SUFFIX,tiktokcdn.com,Proxy
- DOMAIN-SUFFIX,tiktok.com,Proxy
- DOMAIN-SUFFIX,tiktokv.com,Proxy

#specific scholar services
- DOMAIN-KEYWORD,scholar,Scholar
- DOMAIN-KEYWORD,openai,Scholar
- DOMAIN-SUFFIX,openai.com,Scholar
- DOMAIN-SUFFIX,chatgpt.com,Scholar
- DOMAIN-SUFFIX,oaistatic.com,Scholar
- DOMAIN-SUFFIX,oaiusercontent.com,Scholar
- DOMAIN-SUFFIX,ai.com,Scholar

- DOMAIN-SUFFIX,hotmail.com,Proxy
- DOMAIN-SUFFIX,slack.com,Proxy
- DOMAIN-SUFFIX,live.com,Proxy
- DOMAIN-SUFFIX,figma.com,Proxy
- DOMAIN-SUFFIX,firefox.com,Proxy
- DOMAIN-SUFFIX,notion.com,Proxy
- DOMAIN-SUFFIX,x.com,Proxy
- DOMAIN-SUFFIX,reddit.com,Proxy
- DOMAIN-SUFFIX,office.com,Proxy
- DOMAIN-SUFFIX,twimg.com,Proxy
- DOMAIN-SUFFIX,pinterest.com,Proxy
- DOMAIN-SUFFIX,auth0.com,Proxy
- DOMAIN,openaiapi-site.azureedge.net,Proxy
- DOMAIN-SUFFIX,rxiv.org,Proxy
- DOMAIN-SUFFIX,acrjournals.org,Proxy
- DOMAIN-SUFFIX,cademic.eb.com,Proxy
- DOMAIN-SUFFIX,caric.co.jp,Proxy
- DOMAIN-SUFFIX,clweb.org,Proxy
- DOMAIN-SUFFIX,cm.org,Proxy
- DOMAIN-SUFFIX,cs.org,Proxy
- DOMAIN-SUFFIX,gu.org,Proxy
- DOMAIN-SUFFIX,iaa.org,Proxy
- DOMAIN-SUFFIX,imsciences.org,Proxy
- DOMAIN-SUFFIX,ms.org,Proxy
- DOMAIN-SUFFIX,natomy.tv,Proxy
- DOMAIN-SUFFIX,nalytictech.com,Proxy
- DOMAIN-SUFFIX,nnualreviews.org,Proxy
- DOMAIN-SUFFIX,ps.org,Proxy
- DOMAIN-SUFFIX,rabidopsis.org,Proxy
- DOMAIN-SUFFIX,rtstor.org,Proxy
- DOMAIN-SUFFIX,scelibrary.org,Proxy
- DOMAIN-SUFFIX,sha.org,Proxy
- DOMAIN-SUFFIX,sm.org,Proxy
- DOMAIN-SUFFIX,sme.org,Proxy
- DOMAIN-SUFFIX,sminternational.org,Proxy
- DOMAIN-SUFFIX,sn-online.org,Proxy
- DOMAIN-SUFFIX,spbjournals.org,Proxy
- DOMAIN-SUFFIX,spenpublishing.com,Proxy
- DOMAIN-SUFFIX,stm.org,Proxy
- DOMAIN-SUFFIX,siam.org,Proxy

#github
- DOMAIN-KEYWORD,github,Proxy
- DOMAIN-SUFFIX,atom.io,Proxy
- DOMAIN-SUFFIX,dependabot.com,Proxy
- DOMAIN-SUFFIX,ghcr.io,Proxy
- DOMAIN-SUFFIX,git.io,Proxy
- DOMAIN-SUFFIX,myoctocat.com,Proxy
- DOMAIN-SUFFIX,npm.community,Proxy
- DOMAIN-SUFFIX,npmjs.com,Proxy
- DOMAIN-SUFFIX,npmjs.org,Proxy
- DOMAIN-SUFFIX,opensource.guide,Proxy
- DOMAIN-SUFFIX,rawgit.com,Proxy
- DOMAIN-SUFFIX,repo.new,Proxy

#discord
- DOMAIN-KEYWORD,discord,Proxy
- DOMAIN-SUFFIX,airhorn.solutions,Proxy
- DOMAIN-SUFFIX,airhornbot.com,Proxy
- DOMAIN-SUFFIX,bigbeans.solutions,Proxy
- DOMAIN-SUFFIX,dis.gd,Proxy

#dev
- DOMAIN-SUFFIX,gstatic.com,Proxy
- DOMAIN-SUFFIX,google.com,Proxy
- DOMAIN-SUFFIX,figma.com,Proxy
- DOMAIN-SUFFIX,v2ex.com,Proxy
- DOMAIN-KEYWORD,gitlab,Proxy
- DOMAIN-KEYWORD,github,Proxy
- DOMAIN-KEYWORD,npm,Proxy
- DOMAIN-KEYWORD,stackoverflow.com,Proxy
- DOMAIN-SUFFIX,techcrunch.com,Proxy
- DOMAIN-SUFFIX,go-lang.com,Proxy
- DOMAIN-SUFFIX,go-lang.net,Proxy
- DOMAIN-SUFFIX,go-lang.org,Proxy
- DOMAIN-SUFFIX,go.dev,Proxy
- DOMAIN-SUFFIX,godoc.org,Proxy
- DOMAIN-SUFFIX,golang.com,Proxy
- DOMAIN-SUFFIX,golang.net,Proxy
- DOMAIN-SUFFIX,golang.org,Proxy
- DOMAIN-SUFFIX,trello.com,Proxy
- DOMAIN-SUFFIX,techsmith.com,Proxy
- DOMAIN-SUFFIX,thepiratebay.org,Proxy

# > IQIYI
- DOMAIN-KEYWORD,qiyi,DIRECT
- DOMAIN-SUFFIX,qy.net,DIRECT
- DOMAIN-SUFFIX,letv.com,DIRECT
- DOMAIN-SUFFIX,71.am,DIRECT
- DOMAIN-SUFFIX,71edge.com,DIRECT
- DOMAIN-SUFFIX,iqiyi.com,DIRECT
- DOMAIN-SUFFIX,iqiyipic.com,DIRECT
- DOMAIN-SUFFIX,ppsimg.com,DIRECT
- DOMAIN-SUFFIX,qiyi.com,DIRECT
- DOMAIN-SUFFIX,qiyipic.com,DIRECT
- DOMAIN-SUFFIX,qy.net,DIRECT

# > NeteaseMusic
- DOMAIN-SUFFIX,163yun.com,DIRECT
- DOMAIN-SUFFIX,music.126.net,DIRECT
- DOMAIN-SUFFIX,music.163.com,DIRECT

# China CDN
- DOMAIN-SUFFIX,tnkjmec.com,DIRECT
- DOMAIN-SUFFIX,clngaa.com,DIRECT
- DOMAIN-SUFFIX,ksyna.com,DIRECT
- DOMAIN-SUFFIX,bscstorage.net,DIRECT
- DOMAIN-SUFFIX,eccdnx.com,DIRECT
- DOMAIN-SUFFIX,pinyuncloud.com,DIRECT
- DOMAIN-SUFFIX,8686c.com,DIRECT
- DOMAIN-SUFFIX,pphimalayanrt.com,DIRECT
- DOMAIN-SUFFIX,qbox.me,DIRECT
- DOMAIN-SUFFIX,qiniu.com,DIRECT
- DOMAIN-SUFFIX,qiniudn.com,DIRECT
- DOMAIN-SUFFIX,qiniup.com,DIRECT
- DOMAIN-SUFFIX,qnsdk.com,DIRECT
- DOMAIN-SUFFIX,qnssl.com,DIRECT
- DOMAIN-SUFFIX,qiniucdn.com,DIRECT
- DOMAIN-SUFFIX,qiniudns.com,DIRECT
- DOMAIN-SUFFIX,sandai.net,DIRECT

# > ByteDance
- DOMAIN-KEYWORD,toutiao,DIRECT
- DOMAIN-SUFFIX,bdxiguastatic.com,DIRECT
- DOMAIN-SUFFIX,bdurl.net,DIRECT
- DOMAIN-SUFFIX,douyinstatic.com,DIRECT
- DOMAIN-SUFFIX,douyin.com,DIRECT
- DOMAIN-SUFFIX,douyinpic.com,DIRECT
- DOMAIN-SUFFIX,douyinvod.com,DIRECT
- DOMAIN-SUFFIX,huoshan.com,DIRECT
- DOMAIN-SUFFIX,huoshanstatic.com,DIRECT
- DOMAIN-SUFFIX,huoshanzhibo.com,DIRECT
- DOMAIN-SUFFIX,ixigua.com,DIRECT
- DOMAIN-SUFFIX,ixiguavideo.com,DIRECT
- DOMAIN-SUFFIX,ixgvideo.com,DIRECT
- DOMAIN-SUFFIX,bdxiguaimg.com,DIRECT
- DOMAIN-SUFFIX,pstatp.com,DIRECT
- DOMAIN-SUFFIX,snssdk.com,DIRECT
- DOMAIN-SUFFIX,zijiecdn.com,DIRECT
- DOMAIN-SUFFIX,zijiecdn.net,DIRECT
- DOMAIN-SUFFIX,zjbyte.cn,DIRECT
- DOMAIN-SUFFIX,zjcdn.com,DIRECT
- DOMAIN-SUFFIX,bytedance.com,DIRECT
- DOMAIN-SUFFIX,bytedance.net,DIRECT
- DOMAIN-SUFFIX,bytedns.net,DIRECT
- DOMAIN-SUFFIX,byteimg.com,DIRECT
- DOMAIN-SUFFIX,feiliao.com,DIRECT
- DOMAIN-SUFFIX,gifshow.com,DIRECT
- DOMAIN-SUFFIX,huoshan.com,DIRECT
- DOMAIN-SUFFIX,iesdouyin.com,DIRECT
- DOMAIN-SUFFIX,ixigua.com,DIRECT
- DOMAIN-SUFFIX,kspkg.com,DIRECT
- DOMAIN-SUFFIX,pstatp.com,DIRECT
- DOMAIN-SUFFIX,snssdk.com,DIRECT
- DOMAIN-SUFFIX,wukong.com,DIRECT
- DOMAIN-SUFFIX,zijieimg.com,DIRECT
- DOMAIN-SUFFIX,zjbyte.com,DIRECT
- DOMAIN-SUFFIX,zjcdn.com,DIRECT

# > Bilibili
- DOMAIN-KEYWORD,bili,DIRECT
- DOMAIN-SUFFIX,acg.tv,DIRECT
- DOMAIN-SUFFIX,acgvideo.com,DIRECT
- DOMAIN-SUFFIX,b23.tv,DIRECT
- DOMAIN-SUFFIX,hdslb.com,DIRECT
- DOMAIN-SUFFIX,im9.com,DIRECT

# > Blizzard
- DOMAIN-SUFFIX,blizzard.com,DIRECT
- DOMAIN-SUFFIX,battle.net,DIRECT
- DOMAIN,blzddist1-a.akamaihd.net,DIRECT

# DIRECT
- DOMAIN-SUFFIX,digicert.com,DIRECT
- DOMAIN-SUFFIX,code.visualstudio.com,DIRECT

# CCTV
- DOMAIN-SUFFIX,cctv.com,DIRECT
- DOMAIN-SUFFIX,cctvpic.com,DIRECT
- DOMAIN-SUFFIX,livechina.com,DIRECT

# DiDi
- DOMAIN-SUFFIX,didialift.com,DIRECT
- DOMAIN-SUFFIX,didiglobal.com,DIRECT
- DOMAIN-SUFFIX,udache.com,DIRECT

# Douyu 斗鱼
- DOMAIN-SUFFIX,douyu.com,DIRECT
- DOMAIN-SUFFIX,douyu.tv,DIRECT
- DOMAIN-SUFFIX,douyuscdn.com,DIRECT
- DOMAIN-SUFFIX,douyutv.com,DIRECT

# HuaWei
- DOMAIN-SUFFIX,dbankcdn.com,DIRECT
- DOMAIN-SUFFIX,hc-cdn.com,DIRECT
- DOMAIN-SUFFIX,hicloud.com,DIRECT
- DOMAIN-SUFFIX,huawei.com,DIRECT
- DOMAIN-SUFFIX,huaweicloud.com,DIRECT
- DOMAIN-SUFFIX,huaweishop.net,DIRECT
- DOMAIN-SUFFIX,hwccpc.com,DIRECT
- DOMAIN-SUFFIX,vmall.com,DIRECT
- DOMAIN-SUFFIX,vmallres.com,DIRECT

# Iflytek
- DOMAIN-SUFFIX,iflyink.com,DIRECT
- DOMAIN-SUFFIX,iflyrec.com,DIRECT
- DOMAIN-SUFFIX,iflytek.com,DIRECT

- DOMAIN,dig.bdurl.net,DIRECT
- DOMAIN,pagead2.googlesyndication.com,DIRECT


# DIRECTEND

# STEAM CDN
- DOMAIN,csgo.wmsj.cn,Steam
- DOMAIN,dl.steam.clngaa.com,Steam
- DOMAIN,dl.steam.ksyna.com,Steam
- DOMAIN,dota2.wmsj.cn,Steam
- DOMAIN,st.dl.bscstorage.net,Steam
- DOMAIN,st.dl.eccdnx.com,Steam
- DOMAIN,st.dl.pinyuncloud.com,Steam
- DOMAIN,steampipe.steamcontent.tnkjmec.com,Steam
- DOMAIN,steampowered.com.8686c.com,Steam
- DOMAIN,steamstatic.com.8686c.com,Steam
- DOMAIN,wmsjsteam.com,Steam
- DOMAIN-SUFFIX,cm.steampowered.com,Steam
- DOMAIN-SUFFIX,steamchina.com,Steam
- DOMAIN-SUFFIX,steamcontent.com,Steam
- DOMAIN-SUFFIX,steamusercontent.com,Steam
- DOMAIN-SUFFIX,fanatical.com,Steam
- DOMAIN-SUFFIX,humblebundle.com,Steam
- DOMAIN-SUFFIX,steamcommunity.com,Steam
- DOMAIN-SUFFIX,steampowered.com,Steam
- DOMAIN-SUFFIX,steamstatic.com,Steam
- DOMAIN-SUFFIX,steam-chat.com,Steam
- DOMAIN-SUFFIX,steamusercontent.com,Steam
- DOMAIN-SUFFIX,valvesoftware.com,Steam
- DOMAIN-KEYWORD,steamuserimages,Steam
- DOMAIN-KEYWORD,steamcontent,Steam
- DOMAIN,steambroadcast.akamaized.net,Steam
- DOMAIN,steamcdn-a.akamaihd.net,Steam
- DOMAIN,steamcommunity-a.akamaihd.net,Steam
- DOMAIN,steampipe.akamaized.net,Steam
- DOMAIN,steamstore-a.akamaihd.net,Steam
- DOMAIN,steamusercontent-a.akamaihd.net,Steam
- DOMAIN,steamuserimages-a.akamaihd.net,Steam
- DOMAIN-SUFFIX,fanatical.com,Steam
- DOMAIN-SUFFIX,humblebundle.com,Steam
- DOMAIN-SUFFIX,playartifact.com,Steam
- DOMAIN-SUFFIX,steam-chat.com,Steam
- DOMAIN-SUFFIX,steamcommunity.com,Steam
- DOMAIN-SUFFIX,steamgames.com,Steam
- DOMAIN-SUFFIX,steampowered.com,Steam
- DOMAIN-SUFFIX,steamserver.net,Steam
- DOMAIN-SUFFIX,steamstat.us,Steam
- DOMAIN-SUFFIX,steamstatic.com,Steam
- DOMAIN-SUFFIX,underlords.com,Steam
- DOMAIN-SUFFIX,valvesoftware.com,Steam

# Epic
- DOMAIN-SUFFIX,epicgames.com,Steam
- DOMAIN-SUFFIX,helpshift.com,Steam
- DOMAIN-SUFFIX,paragon.com,Steam
- DOMAIN-SUFFIX,unrealengine.com,Steam
- DOMAIN-SUFFIX,ol.epicgames.com,Steam

# > Epicgames
- DOMAIN-KEYWORD,epicgames,Steam
- DOMAIN-SUFFIX,helpshift.com,Steam

# debug
- DOMAIN,ip.sb,Proxy
- DOMAIN,myip.ipip.net,Video
- DOMAIN,ifconfig.me,Netflix

# hot fix
- DOMAIN,services.googleapis.cn,Proxy
- DOMAIN,googleapis.cn,Proxy
- DOMAIN-SUFFIX,ping.pe,Proxy
- DOMAIN-SUFFIX,f2pool.com,Proxy
- DOMAIN-SUFFIX,static.wikia.nocookie.net,Proxy
- DOMAIN-SUFFIX,cc98.org,DIRECT

# common site
- DOMAIN,services.googleapis.cn,Proxy
- DOMAIN,google.com,Proxy
- DOMAIN-SUFFIX,google.cn,Proxy
- DOMAIN-SUFFIX,googleapis.cn,Proxy
- DOMAIN-KEYWORD,facebook,Proxy
- DOMAIN-SUFFIX,fb.me,Proxy
- DOMAIN-KEYWORD,gmail,Proxy
- DOMAIN-KEYWORD,twitter,Proxy
- DOMAIN-KEYWORD,instagram,Proxy
- DOMAIN-SUFFIX,twimg.com,Proxy
- DOMAIN-KEYWORD,blogspot,Proxy
- DOMAIN-KEYWORD,whatsapp,Proxy
- DOMAIN-KEYWORD,glados,Proxy
- DOMAIN-KEYWORD,wikipedia,Proxy
- DOMAIN-SUFFIX,google.com,Proxy
- DOMAIN-SUFFIX,facebook.com,Proxy
- DOMAIN-SUFFIX,yahoo.com,Proxy
- DOMAIN-SUFFIX,amazon.com,Proxy
- DOMAIN-SUFFIX,vk.com,Proxy
- DOMAIN-SUFFIX,reddit.com,Proxy
- DOMAIN-SUFFIX,live.com,Proxy
- DOMAIN-SUFFIX,zoom.us,Proxy
- DOMAIN-SUFFIX,wikipedia.org,Proxy
- DOMAIN-SUFFIX,myshopify.com,Proxy
- DOMAIN-SUFFIX,instagram.com,Proxy
- DOMAIN-SUFFIX,okezone.com,Proxy
- DOMAIN-SUFFIX,office.com,Proxy
- DOMAIN-SUFFIX,ebay.com,Proxy
- DOMAIN-SUFFIX,bongacams.com,Proxy
- DOMAIN-SUFFIX,blogspot.com,Proxy
- DOMAIN-SUFFIX,yahoo.co.jp,Proxy
- DOMAIN-SUFFIX,babytree.com,Proxy
- DOMAIN-SUFFIX,amazon.co.jp,Proxy
- DOMAIN-SUFFIX,adobe.com,Proxy
- DOMAIN-SUFFIX,livejasmin.com,Proxy
- DOMAIN-SUFFIX,stackoverflow.com,Proxy
- DOMAIN-SUFFIX,dropbox.com,Proxy
- DOMAIN-SUFFIX,msn.com,Proxy
- DOMAIN-SUFFIX,yandex.ru,Proxy
- DOMAIN-SUFFIX,linkedin.com,Proxy
- DOMAIN-SUFFIX,twitter.com,Proxy
- DOMAIN-SUFFIX,imgur.com,Proxy
- DOMAIN-SUFFIX,amazonaws.com,Proxy
- DOMAIN-SUFFIX,imdb.com,Proxy
- DOMAIN-SUFFIX,whatsapp.com,Proxy
- DOMAIN-SUFFIX,google.co.jp,Proxy
- DOMAIN-SUFFIX,wordpress.com,Proxy
- DOMAIN-SUFFIX,nytimes.com,Proxy
- DOMAIN-SUFFIX,spotify.com,Proxy

# Proxy CDN
- DOMAIN-SUFFIX,s3.amazonaws.com,Video
- DOMAIN-KEYWORD,akam,Video

# Video
- DOMAIN-KEYWORD,youtube,Video
- DOMAIN,lybmc.com,DIRECT
- DOMAIN,dayi.com,Video
- DOMAIN-SUFFIX,phncdn.com,Video
- DOMAIN-SUFFIX,phprcdn.com,Video
- DOMAIN-SUFFIX,youtu.be,Video
- DOMAIN-SUFFIX,ytimg.com,Video
- DOMAIN-KEYWORD,twitch,Video
- DOMAIN-SUFFIX,googlevideo.com,Video
- DOMAIN-SUFFIX,googleusercontent.com,Video

#Netflix
- DOMAIN-KEYWORD,netflix,Netflix
- DOMAIN-SUFFIX,netflix.com,Netflix
- DOMAIN-SUFFIX,netflix.net,Netflix
- DOMAIN-SUFFIX,nflxext.com,Netflix
- DOMAIN-SUFFIX,nflximg.com,Netflix
- DOMAIN-SUFFIX,nflximg.net,Netflix
- DOMAIN-SUFFIX,nflxso.net,Netflix
- DOMAIN-KEYWORD,dualstack.apiproxy-,Netflix
- DOMAIN-KEYWORD,dualstack.ichnaea-web-,Netflix
- DOMAIN-SUFFIX,netflix.com.edgesuite.net,Netflix
- DOMAIN-SUFFIX,us-west-2.amazonaws.com,Netflix
- DOMAIN-KEYWORD,apiproxy-device-prod-nlb-,Netflix
- DOMAIN-KEYWORD,ichnaea-web-,Netflix
- DOMAIN,netflix.com.edgesuite.net,Netflix
- DOMAIN-SUFFIX,netflix.com,Netflix
- DOMAIN-SUFFIX,netflix.net,Netflix
- DOMAIN-SUFFIX,nflxext.com,Netflix
- DOMAIN-SUFFIX,nflximg.com,Netflix
- DOMAIN-SUFFIX,nflximg.net,Netflix
- DOMAIN-SUFFIX,nflxso.net,Netflix
- DOMAIN-SUFFIX,nflxvideo.net,Netflix

# > Fox+
- DOMAIN-KEYWORD,foxplus,Netflix
- DOMAIN-SUFFIX,config.fox.com,Netflix
- DOMAIN-SUFFIX,emome.net,Netflix
- DOMAIN-SUFFIX,fox.com,Netflix
- DOMAIN-SUFFIX,foxdcg.com,Netflix
- DOMAIN-SUFFIX,foxnow.com,Netflix
- DOMAIN-SUFFIX,foxplus.com,Netflix
- DOMAIN-SUFFIX,foxplay.com,Netflix
- DOMAIN-SUFFIX,ipinfo.io,Netflix
- DOMAIN-SUFFIX,mstage.io,Netflix
- DOMAIN-SUFFIX,now.com,Netflix
- DOMAIN-SUFFIX,theplatform.com,Netflix
- DOMAIN-SUFFIX,urlload.net,Netflix

# > HBO && HBO Go
- DOMAIN-SUFFIX,hbo.com,Netflix
- DOMAIN-SUFFIX,hboasia.com,Netflix
- DOMAIN-SUFFIX,hbogo.com,Netflix
- DOMAIN-SUFFIX,hbogoasia.hk,Netflix

# > Hulu
- DOMAIN-SUFFIX,hulu.com,Netflix
- DOMAIN-SUFFIX,huluim.com,Netflix
- DOMAIN-SUFFIX,hulustream.com,Netflix

#Fast.com
- DOMAIN-SUFFIX,fast.com,Netflix
- DOMAIN-SUFFIX,oca.nflxvideo.net,Netflix
- DOMAIN-SUFFIX,nflxvideo.net,Netflix

- DOMAIN,cdn.registerdisney.go.com,Netflix
- DOMAIN-SUFFIX,adobedtm.com,Netflix
- DOMAIN-SUFFIX,bam.nr-data.net,Netflix
- DOMAIN-SUFFIX,bamgrid.com,Netflix
- DOMAIN-SUFFIX,braze.com,Netflix
- DOMAIN-SUFFIX,cdn.optimizely.com,Netflix
- DOMAIN-SUFFIX,cdn.registerdisney.go.com,Netflix
- DOMAIN-SUFFIX,cws.conviva.com,Netflix
- DOMAIN-SUFFIX,d9.flashtalking.com,Netflix
- DOMAIN-SUFFIX,disney-plus.net,Netflix
- DOMAIN-SUFFIX,disney-portal.my.onetrust.com,Netflix
- DOMAIN-SUFFIX,disney.demdex.net,Netflix
- DOMAIN-SUFFIX,disney.my.sentry.io,Netflix
- DOMAIN-SUFFIX,disneyplus.bn5x.net,Netflix
- DOMAIN-SUFFIX,disneyplus.com,Netflix
- DOMAIN-SUFFIX,disneyplus.com.ssl.sc.omtrdc.net,Netflix
- DOMAIN-SUFFIX,disneystreaming.com,Netflix
- DOMAIN-SUFFIX,dssott.com,Netflix
- DOMAIN-SUFFIX,execute-api.us-east-1.amazonaws.com,Netflix
- DOMAIN-SUFFIX,js-agent.newrelic.com,Netflix

# > ABC
- DOMAIN-SUFFIX,edgedatg.com,Video
- DOMAIN-SUFFIX,go.com,Video

# > AbemaTV
- DOMAIN,linear-abematv.akamaized.net,Video
- DOMAIN-SUFFIX,abema.io,Video
- DOMAIN-SUFFIX,abema.tv,Video
- DOMAIN-SUFFIX,akamaized.net,Video
- DOMAIN-SUFFIX,ameba.jp,Video
- DOMAIN-SUFFIX,hayabusa.io,Video

# > Amazon Prime Video
- DOMAIN-SUFFIX,aiv-cdn.net,Video
- DOMAIN-SUFFIX,amazonaws.com,Video
- DOMAIN-SUFFIX,amazonvideo.com,Video
- DOMAIN-SUFFIX,llnwd.net,Video

# > Bahamut
- DOMAIN-SUFFIX,bahamut.com.tw,Netflix
- DOMAIN-SUFFIX,gamer.com.tw,Netflix
- DOMAIN-SUFFIX,hinet.net,Netflix

# > BBC
- DOMAIN-KEYWORD,bbcfmt,Video
- DOMAIN-KEYWORD,co.uk,Video
- DOMAIN-KEYWORD,uk-live,Video
- DOMAIN-SUFFIX,bbc.co,Video
- DOMAIN-SUFFIX,bbc.co.uk,Video
- DOMAIN-SUFFIX,bbc.com,Video
- DOMAIN-SUFFIX,bbci.co,Video
- DOMAIN-SUFFIX,bbci.co.uk,Video

# > CHOCO TV
- DOMAIN-SUFFIX,chocotv.com.tw,Video


# > Imkan
- DOMAIN-SUFFIX,imkan.tv,Video

# > JOOX
- DOMAIN-SUFFIX,joox.com,Video

# > MytvSUPER
- DOMAIN-KEYWORD,nowtv100,Video
- DOMAIN-KEYWORD,rthklive,Video
- DOMAIN-SUFFIX,mytvsuper.com,Video
- DOMAIN-SUFFIX,tvb.com,Video

# > Pandora
- DOMAIN-SUFFIX,pandora.com,Video

# > Sky GO
- DOMAIN-SUFFIX,sky.com,Video
- DOMAIN-SUFFIX,skygo.co.nz,Video

# > Spotify
- DOMAIN-KEYWORD,spotify,Video
- DOMAIN-SUFFIX,scdn.co,Video
- DOMAIN-SUFFIX,spoti.fi,Video

# > viuTV
- DOMAIN-SUFFIX,viu.tv,Video

# > Youtube
- DOMAIN-KEYWORD,youtube,Video
- DOMAIN-SUFFIX,googlevideo.com,Video
- DOMAIN-SUFFIX,gvt2.com,Video
- DOMAIN-SUFFIX,youtu.be,Video
- DOMAIN-SUFFIX,youtu.be,Video
- DOMAIN-SUFFIX,yt.be,Video
- DOMAIN-SUFFIX,ytimg.com,Video
- DOMAIN-KEYWORD,pornhub,Video
- DOMAIN-KEYWORD,porn,Video
- DOMAIN-KEYWORD,phncdn,Video
- DOMAIN-SUFFIX,vimeo.com,Video
- DOMAIN-SUFFIX,vimeocdn.com,Video

# > Google
- DOMAIN-KEYWORD,google,Proxy
- DOMAIN-SUFFIX,abc.xyz,Proxy
- DOMAIN-SUFFIX,android.com,Proxy
- DOMAIN-SUFFIX,androidify.com,Proxy
- DOMAIN-SUFFIX,dialogflow.com,Proxy
- DOMAIN-SUFFIX,autodraw.com,Proxy
- DOMAIN-SUFFIX,capitalg.com,Proxy
- DOMAIN-SUFFIX,certificate-transparency.org,Proxy
- DOMAIN-SUFFIX,chrome.com,Proxy
- DOMAIN-SUFFIX,chromeexperiments.com,Proxy
- DOMAIN-SUFFIX,chromestatus.com,Proxy
- DOMAIN-SUFFIX,chromium.org,Proxy
- DOMAIN-SUFFIX,creativelab5.com,Proxy
- DOMAIN-SUFFIX,debug.com,Proxy
- DOMAIN-SUFFIX,deepmind.com,Proxy
- DOMAIN-SUFFIX,firebaseio.com,Proxy
- DOMAIN-SUFFIX,getmdl.io,Proxy
- DOMAIN-SUFFIX,ggpht.com,Proxy
- DOMAIN-SUFFIX,gmail.com,Proxy
- DOMAIN-SUFFIX,gmodules.com,Proxy
- DOMAIN-SUFFIX,godoc.org,Proxy
- DOMAIN-SUFFIX,golang.org,Proxy
- DOMAIN-SUFFIX,gv.com,Proxy
- DOMAIN-SUFFIX,gwtproject.org,Proxy
- DOMAIN-SUFFIX,itasoftware.com,Proxy
- DOMAIN-SUFFIX,madewithcode.com,Proxy
- DOMAIN-SUFFIX,material.io,Proxy
- DOMAIN-SUFFIX,polymer-project.org,Proxy
- DOMAIN-SUFFIX,admin.recaptcha.net,Proxy
- DOMAIN-SUFFIX,recaptcha.net,Proxy
- DOMAIN-SUFFIX,shattered.io,Proxy
- DOMAIN-SUFFIX,synergyse.com,Proxy
- DOMAIN-SUFFIX,tensorflow.org,Proxy
- DOMAIN-SUFFIX,tiltbrush.com,Proxy
- DOMAIN-SUFFIX,waveprotocol.org,Proxy
- DOMAIN-SUFFIX,waymo.com,Proxy
- DOMAIN-SUFFIX,webmproject.org,Proxy
- DOMAIN-SUFFIX,webrtc.org,Proxy
- DOMAIN-SUFFIX,whatbrowser.org,Proxy
- DOMAIN-SUFFIX,widevine.com,Proxy
- DOMAIN-SUFFIX,x.company,Proxy
- DOMAIN-SUFFIX,contest.com,Proxy
- DOMAIN-SUFFIX,graph.org,Proxy
- DOMAIN-SUFFIX,quiz.directory,Proxy
- DOMAIN-SUFFIX,t.me,Proxy
- DOMAIN-SUFFIX,tdesktop.com,Proxy
- DOMAIN-SUFFIX,telega.one,Proxy
- DOMAIN-SUFFIX,telegra.ph,Proxy
- DOMAIN-SUFFIX,telegram.dog,Proxy
- DOMAIN-SUFFIX,telegram.me,Proxy
- DOMAIN-SUFFIX,telegram.org,Proxy
- DOMAIN-SUFFIX,telegram.space,Proxy
- DOMAIN-SUFFIX,telesco.pe,Proxy
- DOMAIN-SUFFIX,tg.dev,Proxy
- DOMAIN-SUFFIX,tx.me,Proxy
- DOMAIN-SUFFIX,usercontent.dev,Proxy

# apple
- DOMAIN,hls.itunes.apple.com,DIRECT
- DOMAIN,itunes.apple.com,DIRECT
- DOMAIN,www.apple.com,DIRECT
- DOMAIN-SUFFIX,apple.com,DIRECT
- DOMAIN-SUFFIX,icloud.com,DIRECT
- DOMAIN-SUFFIX,icloud-content.com,DIRECT
- DOMAIN-SUFFIX,mzstatic.com,DIRECT
- DOMAIN-SUFFIX,aaplimg.com,DIRECT
- DOMAIN-SUFFIX,cdn-apple.com,DIRECT

# microsoft
- DOMAIN-SUFFIX,live.com,DIRECT
- DOMAIN-SUFFIX,live.net,DIRECT
- DOMAIN-SUFFIX,office.com,DIRECT
- DOMAIN-SUFFIX,office.net,DIRECT
- DOMAIN-SUFFIX,sharepoint.com,DIRECT
- DOMAIN-SUFFIX,office365.com,DIRECT
- DOMAIN-SUFFIX,officeppe.net,DIRECT
- DOMAIN-SUFFIX,skype.com,DIRECT
- DOMAIN-SUFFIX,onedrive.com,DIRECT
- DOMAIN-SUFFIX,msocsp.com,DIRECT
- DOMAIN-SUFFIX,msauthimages.net,DIRECT
- DOMAIN-SUFFIX,msauth.net,DIRECT
- DOMAIN-SUFFIX,msn.com,DIRECT
- DOMAIN-SUFFIX,onenote.com,DIRECT
- DOMAIN-SUFFIX,onenote.net,DIRECT
- DOMAIN-SUFFIX,1drv.com,DIRECT
- DOMAIN-SUFFIX,microsoft.com,DIRECT
- DOMAIN-SUFFIX,microsoftonline.com,DIRECT

- DOMAIN-SUFFIX,miui.com,DIRECT
- DOMAIN-SUFFIX,miwifi.com,DIRECT
- DOMAIN-SUFFIX,mob.com,DIRECT
- DOMAIN-SUFFIX,netease.com,DIRECT
- DOMAIN-SUFFIX,office.com,DIRECT
- DOMAIN-SUFFIX,office365.com,DIRECT
- DOMAIN-KEYWORD,officecdn,DIRECT
- DOMAIN-SUFFIX,oschina.net,DIRECT
- DOMAIN-SUFFIX,ppsimg.com,DIRECT
- DOMAIN-SUFFIX,pstatp.com,DIRECT
- DOMAIN-SUFFIX,qcloud.com,DIRECT
- DOMAIN-SUFFIX,qdaily.com,DIRECT
- DOMAIN-SUFFIX,qdmm.com,DIRECT
- DOMAIN-SUFFIX,qhimg.com,DIRECT
- DOMAIN-SUFFIX,qhres.com,DIRECT
- DOMAIN-SUFFIX,qidian.com,DIRECT
- DOMAIN-SUFFIX,qihucdn.com,DIRECT
- DOMAIN-SUFFIX,qiniu.com,DIRECT
- DOMAIN-SUFFIX,qiniucdn.com,DIRECT
- DOMAIN-SUFFIX,qiyipic.com,DIRECT
- DOMAIN-SUFFIX,qq.com,DIRECT
- DOMAIN-SUFFIX,qqurl.com,DIRECT
- DOMAIN-SUFFIX,rarbg.to,DIRECT
- DOMAIN-SUFFIX,ruguoapp.com,DIRECT
- DOMAIN-SUFFIX,segmentfault.com,DIRECT
- DOMAIN-SUFFIX,sinaapp.com,DIRECT
- DOMAIN-SUFFIX,smzdm.com,DIRECT
- DOMAIN-SUFFIX,sogou.com,DIRECT
- DOMAIN-SUFFIX,sogoucdn.com,DIRECT
- DOMAIN-SUFFIX,sohu.com,DIRECT
- DOMAIN-SUFFIX,soku.com,DIRECT
- DOMAIN-SUFFIX,speedtest.net,DIRECT
- DOMAIN-SUFFIX,sspai.com,DIRECT
- DOMAIN-SUFFIX,suning.com,DIRECT
- DOMAIN-SUFFIX,taobao.com,DIRECT
- DOMAIN-SUFFIX,tenpay.com,DIRECT
- DOMAIN-SUFFIX,tmall.com,DIRECT
- DOMAIN-SUFFIX,tudou.com,DIRECT
- DOMAIN-SUFFIX,umetrip.com,DIRECT
- DOMAIN-SUFFIX,upaiyun.com,DIRECT
- DOMAIN-SUFFIX,upyun.com,DIRECT
- DOMAIN-SUFFIX,veryzhun.com,DIRECT
- DOMAIN-SUFFIX,weather.com,DIRECT
- DOMAIN-SUFFIX,weibo.com,DIRECT
- DOMAIN-SUFFIX,xiami.com,DIRECT
- DOMAIN-SUFFIX,xiami.net,DIRECT
- DOMAIN-SUFFIX,xiaomicp.com,DIRECT
- DOMAIN-SUFFIX,ximalaya.com,DIRECT
- DOMAIN-SUFFIX,xmcdn.com,DIRECT
- DOMAIN-SUFFIX,xunlei.com,DIRECT
- DOMAIN-SUFFIX,xycdn.com,DIRECT
- DOMAIN-SUFFIX,yhd.com,DIRECT
- DOMAIN-SUFFIX,yihaodianimg.com,DIRECT
- DOMAIN-SUFFIX,yinxiang.com,DIRECT
- DOMAIN-SUFFIX,ykimg.com,DIRECT
- DOMAIN-SUFFIX,youdao.com,DIRECT
- DOMAIN-SUFFIX,youku.com,DIRECT
- DOMAIN-SUFFIX,zealer.com,DIRECT
- DOMAIN-SUFFIX,zhihu.com,DIRECT
- DOMAIN-SUFFIX,zhimg.com,DIRECT
- DOMAIN-SUFFIX,zimuzu.tv,DIRECT

# China
- DOMAIN-SUFFIX,apcdns.net,DIRECT
- DOMAIN-SUFFIX,cdntip.com,DIRECT
- DOMAIN-SUFFIX,cdntips.com,DIRECT
- DOMAIN-SUFFIX,foxmail.com,DIRECT
- DOMAIN-SUFFIX,gtimg.com,DIRECT
- DOMAIN-SUFFIX,idqqimg.com,DIRECT
- DOMAIN-SUFFIX,imqq.com,DIRECT
- DOMAIN-SUFFIX,myapp.com,DIRECT
- DOMAIN-SUFFIX,myqcloud.com,DIRECT
- DOMAIN-SUFFIX,qcloud.com,DIRECT
- DOMAIN-SUFFIX,qcloudimg.com,DIRECT
- DOMAIN-SUFFIX,qq.com,DIRECT
- DOMAIN-SUFFIX,qqmail.com,DIRECT
- DOMAIN-SUFFIX,qzone.com,DIRECT
- DOMAIN-SUFFIX,servicewechat.com,DIRECT
- DOMAIN-SUFFIX,smtcdns.com,DIRECT
- DOMAIN-SUFFIX,smtcdns.net,DIRECT
- DOMAIN-SUFFIX,tencent.com,DIRECT
- DOMAIN-SUFFIX,tencent.com.hk,DIRECT
- DOMAIN-SUFFIX,tencent-cloud.com,DIRECT
- DOMAIN-SUFFIX,tencent-cloud.net,DIRECT
- DOMAIN-SUFFIX,tencentcs.com,DIRECT
- DOMAIN-SUFFIX,tencentmusic.com,DIRECT
- DOMAIN-SUFFIX,tencentyun.com,DIRECT
- DOMAIN-SUFFIX,tenpay.com,DIRECT
- DOMAIN-SUFFIX,wechat.com,DIRECT
- DOMAIN-SUFFIX,wegame.com,DIRECT
- DOMAIN-SUFFIX,weiyun.com,DIRECT
- DOMAIN-SUFFIX,25pp.com,DIRECT
- DOMAIN-SUFFIX,56che.com,DIRECT
- DOMAIN-SUFFIX,95095.com,DIRECT
- DOMAIN-SUFFIX,aliapp.org,DIRECT
- DOMAIN-SUFFIX,alibaba-inc.com,DIRECT
- DOMAIN-SUFFIX,alibaba.com,DIRECT
- DOMAIN-SUFFIX,alibabacapital.com,DIRECT
- DOMAIN-SUFFIX,alibabacorp.com,DIRECT
- DOMAIN-SUFFIX,alibabadoctor.com,DIRECT
- DOMAIN-SUFFIX,alibabafuturehotel.com,DIRECT
- DOMAIN-SUFFIX,alibabagroup.com,DIRECT
- DOMAIN-SUFFIX,alibabaplanet.com,DIRECT
- DOMAIN-SUFFIX,alibabaued.com,DIRECT
- DOMAIN-SUFFIX,alibabausercontent.com,DIRECT
- DOMAIN-SUFFIX,alifanyi.com,DIRECT
- DOMAIN-SUFFIX,alihealth.hk,DIRECT
- DOMAIN-SUFFIX,aliimg.com,DIRECT
- DOMAIN-SUFFIX,alikmd.com,DIRECT
- DOMAIN-SUFFIX,alimama.com,DIRECT
- DOMAIN-SUFFIX,alimebot.com,DIRECT
- DOMAIN-SUFFIX,alimei.com,DIRECT
- DOMAIN-SUFFIX,alipay.com,DIRECT
- DOMAIN-SUFFIX,alipaydns.com,DIRECT
- DOMAIN-SUFFIX,alipayobjects.com,DIRECT
- DOMAIN-SUFFIX,aliplus.com,DIRECT
- DOMAIN-SUFFIX,aliresearch.com,DIRECT
- DOMAIN-SUFFIX,alisoft.com,DIRECT
- DOMAIN-SUFFIX,alisports.com,DIRECT
- DOMAIN-SUFFIX,alitianji.com,DIRECT
- DOMAIN-SUFFIX,aliunicorn.com,DIRECT
- DOMAIN-SUFFIX,aliway.com,DIRECT
- DOMAIN-SUFFIX,aliwork.com,DIRECT
- DOMAIN-SUFFIX,alixiaomi.com,DIRECT
- DOMAIN-SUFFIX,alizhaopin.com,DIRECT
- DOMAIN-SUFFIX,asczwa.com,DIRECT
- DOMAIN-SUFFIX,asczxcefsv.com,DIRECT
- DOMAIN-SUFFIX,atatech.org,DIRECT
- DOMAIN-SUFFIX,b2byao.com,DIRECT
- DOMAIN-SUFFIX,bazai.com,DIRECT
- DOMAIN-SUFFIX,bcvbw.com,DIRECT
- DOMAIN-SUFFIX,cheng.xin,DIRECT
- DOMAIN-SUFFIX,dayu.com,DIRECT
- DOMAIN-SUFFIX,dongting.com,DIRECT
- DOMAIN-SUFFIX,dratio.com,DIRECT
- DOMAIN-SUFFIX,emas-poc.com,DIRECT
- DOMAIN-SUFFIX,ialicdn.com,DIRECT
- DOMAIN-SUFFIX,kanbox.com,DIRECT
- DOMAIN-SUFFIX,lazada.com,DIRECT
- DOMAIN-SUFFIX,liangxinyao.com,DIRECT
- DOMAIN-SUFFIX,maitix.com,DIRECT
- DOMAIN-SUFFIX,1688.com,DIRECT
- DOMAIN-SUFFIX,etao.com,DIRECT
- DOMAIN-SUFFIX,juhuasuan.com,DIRECT
- DOMAIN-SUFFIX,lingshoujia.com,DIRECT
- DOMAIN-SUFFIX,pailitao.com,DIRECT
- DOMAIN-SUFFIX,taobao.com,DIRECT
- DOMAIN-SUFFIX,taobao.org,DIRECT
- DOMAIN-SUFFIX,taobaocdn.com,DIRECT
- DOMAIN-SUFFIX,taobizhong.com,DIRECT
- DOMAIN-SUFFIX,taopiaopiao.com,DIRECT
- DOMAIN-SUFFIX,tbcache.com,DIRECT
- DOMAIN-SUFFIX,tburl.in,DIRECT
- DOMAIN-SUFFIX,tmall.com,DIRECT
- DOMAIN-SUFFIX,tmall.ru,DIRECT
- DOMAIN-SUFFIX,tmalltv.com,DIRECT
- DOMAIN-SUFFIX,tmjl.ai,DIRECT
- DOMAIN-SUFFIX,alitrip.com,DIRECT
- DOMAIN-SUFFIX,feizhu.com,DIRECT
- DOMAIN-SUFFIX,fliggy.com,DIRECT


# DNS
- DOMAIN,dns.google,Proxy
- IP-CIDR,1.1.1.1/32,Proxy,no-resolve
- IP-CIDR,1.0.0.1/32,Proxy,no-resolve
- IP-CIDR,8.8.8.8/32,Proxy,no-resolve
- IP-CIDR,119.29.29.29/32,DIRECT,no-resolve
- IP-CIDR,114.114.114.114/32,DIRECT,no-resolve

# LAN
- IP-CIDR,127.0.0.0/8,DIRECT,no-resolve
- IP-CIDR,10.0.0.0/8,DIRECT,no-resolve
- IP-CIDR,17.0.0.0/8,DIRECT,no-resolve
- IP-CIDR,100.64.0.0/10,DIRECT,no-resolve
- IP-CIDR,172.16.0.0/12,DIRECT,no-resolve
- IP-CIDR,192.168.0.0/16,DIRECT,no-resolve

# RULE VERSION
- DOMAIN,2020020202.version.clash.im,REJECT

- DOMAIN-SUFFIX,cn,DIRECT
- GEOIP,CN,DIRECT

# Final
- MATCH,Proxy
UiLgNoD-lIaMtOh

    # 写入 sing-box-freebsd 客户端配置到 client-sing-box-config.json 文件
    cat <<UiLgNoD-lIaMtOh | tee ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/client-sing-box-config.json >/dev/null
{
  "log": {
    "level": "debug",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "proxyDns",
        "address": "tls://8.8.8.8",
        "detour": "Proxy"
      },
      {
        "tag": "local",
        "address": "tls://223.5.5.5",
        "detour": "direct"
      },
      {
        "tag": "localDns",
        "address": "https://223.5.5.5/dns-query",
        "address_resolver": "local",
        "detour": "direct"
      },
      {
        "tag": "block",
        "address": "rcode://success"
      }
    ],
    "rules": [
      {
        "rule_set": "geosite-category-ads-all",
        "server": "block"
      },
      {
        "outbound": "any",
        "server": "localDns",
        "disable_cache": true
      },
      {
        "rule_set": "geosite-cn",
        "server": "localDns"
      },
      {
        "clash_mode": "direct",
        "server": "localDns"
      },
      {
        "clash_mode": "global",
        "server": "proxyDns"
      },
      {
        "rule_set": "geosite-geolocation-!cn",
        "server": "proxyDns"
      }
    ],
    "final": "localDns"
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "mtu": 9000,
      "auto_route": true,
      "stack": "mixed",
      "sniff": true,
      "sniff_override_destination": true,
      "domain_strategy": "prefer_ipv4",
      "inet4_address": "172.19.0.1/30"
    },
    {
      "type": "http",
      "tag": "http-in",
      "listen": "::",
      "listen_port": 7897,
      "sniff": true,
      "sniff_override_destination": true,
      "domain_strategy": "prefer_ipv4"
    },
    {
      "type": "socks",
      "tag": "socks-in",
      "listen": "::",
      "listen_port": 7898,
      "sniff": true,
      "sniff_override_destination": true,
      "domain_strategy": "prefer_ipv4"
    },
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "::",
      "listen_port": 7899,
      "sniff": true,
      "sniff_override_destination": true,
      "domain_strategy": "prefer_ipv4"
    }
  ],
  "outbounds": [
    {
      "type": "selector",
      "tag": "Proxy",
      "outbounds": [
        "auto",
        "$SB_ALL_PROTOCOL_OUT_GROUP_TAG",
        "direct"
      ]
    },
    {
      "type": "selector",
      "tag": "OpenAI",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Google",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Telegram",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Twitter",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Facebook",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "BiliBili",
      "outbounds": [
        "direct",
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Bahamut",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Spotify",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "TikTok",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Netflix",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Disney+",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Apple",
      "outbounds": [
        "direct",
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Microsoft",
      "outbounds": [
        "direct",
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Games",
      "outbounds": [
        "direct",
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Streaming",
      "outbounds": [
        "auto"
      ]
    },
    {
      "type": "selector",
      "tag": "Global",
      "outbounds": [
        "auto",
        "direct"
      ]
    },
    {
      "type": "selector",
      "tag": "China",
      "outbounds": [
        "direct"
      ]
    },
    {
      "type": "selector",
      "tag": "AdBlock",
      "outbounds": [
        "block"
      ]
    },
    {
      "type": "urltest",
      "tag": "auto",
      "outbounds": [
        "$SB_V_PROTOCOL_OUT_TAG_1",
        "$SB_VM_PROTOCOL_OUT_TAG_2",
        "$SB_T_PROTOCOL_OUT_TAG_3"
      ],
      "url": "http://www.gstatic.com/generate_204",
      "interval": "10m0s",
      "tolerance": 50
    },
    {
      "type": "selector",
      "tag": "$SB_ALL_PROTOCOL_OUT_GROUP_TAG",
      "outbounds": [
        "$SB_V_PROTOCOL_OUT_TAG_1",
        "$SB_VM_PROTOCOL_OUT_TAG_2",
        "$SB_T_PROTOCOL_OUT_TAG_3"
      ]
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    },
    {
      "type": "block",
      "tag": "block"
    },
    {
      "type": "$V_PROTOCOL",
      "tag": "$SB_V_PROTOCOL_OUT_TAG_1",
      "server": "$V_WEBSITE",
      "server_port": $CLOUDFLARED_PORT_V,
      "uuid": "$V_UUID_1",
      "packet_encoding": "xudp",
      "tls": {
        "enabled": true,
        "server_name": "$CLOUDFLARED_DOMAIN_V_1",
        "utls": {
          "enabled": true,
          "fingerprint": "$BROWSER"
        }
      },
      "transport": {
        "headers": {
          "Host": [
            "$CLOUDFLARED_DOMAIN_V_1"
          ]
        },
        "path": "$V_PATH_1",
        "type": "$VV_TYPE",
        "max_early_data": 2560,
        "early_data_header_name": "Sec-WebSocket-Protocol"
      }
    },
    {
      "type": "$VM_PROTOCOL",
      "tag": "$SB_VM_PROTOCOL_OUT_TAG_2",
      "server": "$VM_WEBSITE",
      "server_port": $CLOUDFLARED_PORT_VM,
      "security": "auto",
      "uuid": "$VM_UUID_2",
      "packet_encoding": "xudp",
      "tls": {
        "enabled": true,
        "server_name": "$CLOUDFLARED_DOMAIN_VM_2",
        "insecure": true,
        "utls": {
          "enabled": true,
          "fingerprint": "$BROWSER"
        }
      },
      "transport": {
        "headers": {
          "Host": [
            "$CLOUDFLARED_DOMAIN_VM_2"
          ]
        },
        "path": "$VM_PATH_2",
        "type": "$VMV_TYPE",
        "max_early_data": 2560,
        "early_data_header_name": "Sec-WebSocket-Protocol"
      }
    },
    {
      "type": "$T_PROTOCOL",
      "tag": "$SB_T_PROTOCOL_OUT_TAG_3",
      "server": "$T_WEBSITE",
      "server_port": $CLOUDFLARED_PORT_VM,
      "password": "$T_UUID_3",
      "network": "udp",
      "tls": {
        "enabled": true,
        "server_name": "$CLOUDFLARED_DOMAIN_T_3",
        "insecure": true,
        "utls": {
          "enabled": true,
          "fingerprint": "$BROWSER"
        }
      },
      "transport": {
        "headers": {
          "Host": [
            "$CLOUDFLARED_DOMAIN_T_3"
          ]
        },
        "path": "$T_PATH_3",
        "type": "$VMV_TYPE",
        "max_early_data": 2560,
        "early_data_header_name": "Sec-WebSocket-Protocol"
      }
    }
  ],
  "route": {
    "rules": [
      {
        "type": "logical",
        "mode": "or",
        "rules": [
          {
            "port": 53
          },
          {
            "protocol": "dns"
          }
        ],
        "outbound": "dns-out"
      },
      {
        "rule_set": "geosite-category-ads-all",
        "outbound": "AdBlock"
      },
      {
        "clash_mode": "direct",
        "outbound": "direct"
      },
      {
        "clash_mode": "global",
        "outbound": "Proxy"
      },
      {
        "domain": [
          "clash.razord.top",
          "yacd.metacubex.one",
          "yacd.haishan.me",
          "d.metacubex.one"
        ],
        "outbound": "direct"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      },
      {
        "rule_set": "geosite-openai",
        "outbound": "OpenAI"
      },
      {
        "rule_set": [
          "geosite-youtube",
          "geoip-google",
          "geosite-google",
          "geosite-github"
        ],
        "outbound": "Google"
      },
      {
        "rule_set": [
          "geoip-telegram",
          "geosite-telegram"
        ],
        "outbound": "Telegram"
      },
      {
        "rule_set": [
          "geoip-twitter",
          "geosite-twitter"
        ],
        "outbound": "Twitter"
      },
      {
        "rule_set": [
          "geoip-facebook",
          "geosite-facebook"
        ],
        "outbound": "Facebook"
      },
      {
        "rule_set": "geosite-bilibili",
        "outbound": "BiliBili"
      },
      {
        "rule_set": "geosite-bahamut",
        "outbound": "Bahamut"
      },
      {
        "rule_set": "geosite-spotify",
        "outbound": "Spotify"
      },
      {
        "rule_set": "geosite-tiktok",
        "outbound": "TikTok"
      },
      {
        "rule_set": [
          "geoip-netflix",
          "geosite-netflix"
        ],
        "outbound": "Netflix"
      },
      {
        "rule_set": "geosite-disney",
        "outbound": "Disney+"
      },
      {
        "rule_set": [
          "geoip-apple",
          "geosite-apple",
          "geosite-amazon"
        ],
        "outbound": "Apple"
      },
      {
        "rule_set": "geosite-microsoft",
        "outbound": "Microsoft"
      },
      {
        "rule_set": [
          "geosite-category-games",
          "geosite-dmm"
        ],
        "outbound": "Games"
      },
      {
        "rule_set": [
          "geosite-hbo",
          "geosite-primevideo"
        ],
        "outbound": "Streaming"
      },
      {
        "rule_set": "geosite-geolocation-!cn",
        "outbound": "Global"
      },
      {
        "rule_set": [
          "geoip-cn",
          "geosite-cn"
        ],
        "outbound": "China"
      }
    ],
    "rule_set": [
      {
        "type": "remote",
        "tag": "geosite-category-ads-all",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-category-ads-all.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-openai",
        "format": "source",
        "url": "https://testingcf.jsdelivr.net/gh/Toperlock/sing-box-geosite@main/rule/OpenAI.json",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-youtube",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-youtube.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-google",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/google.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-google",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-google.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-github",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-github.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-telegram",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/telegram.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-telegram",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-telegram.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-twitter",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/twitter.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-twitter",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-twitter.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-facebook",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/facebook.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-facebook",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-facebook.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-bilibili",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-bilibili.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-bahamut",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-bahamut.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-spotify",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-spotify.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-tiktok",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-tiktok.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-netflix",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/netflix.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-netflix",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-netflix.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-disney",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-disney.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-apple",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo-lite/geoip/apple.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-apple",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-apple.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-amazon",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-amazon.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-microsoft",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-microsoft.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-category-games",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-category-games.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-dmm",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-dmm.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-hbo",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-hbo.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-primevideo",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-primevideo.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-geolocation-!cn",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-geolocation-!cn.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geoip-cn",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@sing/geo/geoip/cn.srs",
        "download_detour": "direct"
      },
      {
        "type": "remote",
        "tag": "geosite-cn",
        "format": "binary",
        "url": "https://testingcf.jsdelivr.net/gh/SagerNet/sing-geosite@rule-set/geosite-cn.srs",
        "download_detour": "direct"
      }
    ],
    "final": "Proxy",
    "auto_detect_interface": true
  },
  "experimental": {
    "cache_file": {
      "enabled": true
    },
    "clash_api": {
      "external_controller": ":7900",
      "external_ui": "ui",
      "external_ui_download_url": "https://mirror.ghproxy.com/https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip",
      "external_ui_download_detour": "direct",
      "default_mode": "rule"
    }
  }
}
UiLgNoD-lIaMtOh

    # 本机 DOMAIN
    HOSTNAME_DOMAIN="$(hostname)"
    USERNAME="$(whoami)"

    # 起始时间+6h
    #F_DATE="$(date -d '${REPORT_DATE}' --date='6 hour' +'%Y-%m-%d %T')"
    # 脚本结束时间
    F_DATE="$(TZ=':Asia/Shanghai' date +'%Y-%m-%d %T')"
    F_DATE_S="$(TZ=':Asia/Shanghai' date +%s)"
    # 写入 crontab 自动化，应对服务器自动重启
    # 查看当前 crontab
    echo '当前 crontab'
    crontab -l

    cat <<UiLgNoD-lIaMtOh | tee ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/crontab >/dev/null
@reboot cd ${HOME} ; bash s-c-f-serv00.sh
$(crontab -l | sed '/s-c-f-serv00.sh/d')
UiLgNoD-lIaMtOh
    crontab ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/crontab
    rm -fv ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/crontab

    # 检查写入之后的 crontab
    echo '写入之后的 crontab'
    crontab -l
    # 写入 result.txt 字符画
    cat <<'UiLgNoD-lIaMtOh' | tee ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/result.txt >/dev/null
# ---------------------------------

.   .o|         ,   .     ,--.    |    |     ,-.-.|    ,---.|    
|   |.|    ,---.|\  |,---.|   |   |    |,---.| | ||--- |   ||---.
|   |||    |   || \ ||   ||   |---|    |,---|| | ||    |   ||   |
`---'``---'`---|`  `'`---'`--'    `---'``---^` ' '`---'`---'`   '
           `---'                                                 
                                                                 
                ,---.                        ,--.,--.            
,---.   ,---.   |__.    ,---.,---.,---..    ,|  ||  |            
`---.---|    ---|    ---`---.|---'|     \  / |  ||  |            
`---'   `---'   `       `---'`---'`      `'  `--'`--'            

# --------------------------------

UiLgNoD-lIaMtOh
    # 写入 result.txt
    cat <<UiLgNoD-lIaMtOh | tee -a ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/result.txt >/dev/null
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

# 自定义客户端配置中的优选域名或IP和端口可能会起到加速作用
# 当前客户端配置中的的优选域名为 $VM_WEBSITE 优选域名或IP端口为 $CLOUDFLARED_PORT_VM

# VLESS 订阅1:
# $HOSTNAME_DOMAIN:$V_PORT_1 -> $CLOUDFLARED_DOMAIN_V_1:$CLOUDFLARED_PORT_V
$VLESS_LINK_1

# VMESS 订阅2:
# $HOSTNAME_DOMAIN:$VM_PORT_2 -> $CLOUDFLARED_DOMAIN_VM_2:$CLOUDFLARED_PORT_VM
$VMESS_LINK_2

# TROJAN 订阅3:
# $HOSTNAME_DOMAIN:$T_PORT_3 -> $CLOUDFLARED_DOMAIN_T_3:$CLOUDFLARED_PORT_T
$TROJAN_LINK_3

# 执行完成，如果可以请通过 scp 获取客户端配置到本地
# 本地sing-box客户端配置文件位置 ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/client-sing-box-config.json
# 用于 sing-box 客户端配置文件拉取到本地 . 的命令如下
scp -P 22 $USERNAME@$HOSTNAME_DOMAIN:${HOME}/s-c-f-serv00-${REPORT_DATE_S}/client-sing-box-config.json .

# 本地 mihomo 或 nekobox 等客户端配置文件配置文件位置 ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/client-nekobox-config.yaml
# 用于 mihomo 或 nekobox 等客户端配置文件拉取到本地 . 的命令如下
scp -P 22 $USERNAME@$HOSTNAME_DOMAIN:${HOME}/s-c-f-serv00-${REPORT_DATE_S}/client-nekobox-config.yaml .

# 本脚本执行耗时:
"$REPORT_DATE ---> $F_DATE" "Total:$[ $F_DATE_S - $REPORT_DATE_S ] seconds"

UiLgNoD-lIaMtOh
}

# 下载 sing-box-freebsd cloudflared-freebsd 配置并启用
downloadFile() {
    # 本地 go 构建 sing-box
    URI="SagerNet/sing-box"
    GITHUB_URI="https://github.com/${URI}"
    TAG_URI="/${URI}/releases/tag/"

    # 尝试获取网页内容，最多重试5次
    for i in {1..5}; do
        PAGE_CONTENT=$(curl -sL ${GITHUB_URI}/releases)
        if [ -n "${PAGE_CONTENT}" ]; then
            break
        fi
        echo "尝试获取网页内容失败，重试第 $i 次..."
        sleep 2
    done

    # 确保成功获取到网页内容
    if [ -z "${PAGE_CONTENT}" ]; then
        echo "无法获取网页内容，请稍后再试。"
        exit 1
    fi

    # 提取最新版本号
    VERSION=$(echo "${PAGE_CONTENT}" | grep -o "href=\"${TAG_URI}[^\"]*" | head -n 1 | sed "s;href=\"${TAG_URI};;" | sed 's/\"//g')
    echo ${VERSION}

    # 下载并编译
    FILENAME=$(basename ${GITHUB_URI})
    wget -t 3 -T 10 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${GITHUB_URI}/archive/refs/tags/${VERSION}.tar.gz" -O ${FILENAME}.tar.gz
    tar zxf ${FILENAME}.tar.gz
    cd ${FILENAME}-${VERSION#v}
    go build ./cmd/${FILENAME}
    mv -fv ./${FILENAME} ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/${FILENAME}-freebsd
    chmod -v u+x ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/${FILENAME}-freebsd
    cd -
    rm -rf ${FILENAME}.tar.gz ${FILENAME}-${VERSION#v}

    # 本地 go 构建 cloudflared-freebsd
    URI="cloudflare/cloudflared"
    GITHUB_URI="https://github.com/${URI}"
    TAG_URI="/${URI}/releases/tag/"

    # 尝试获取网页内容，最多重试5次
    for i in {1..5}; do
        PAGE_CONTENT=$(curl -sL ${GITHUB_URI}/releases)
        if [ -n "${PAGE_CONTENT}" ]; then
            break
        fi
        echo "尝试获取网页内容失败，重试第 $i 次..."
        sleep 2
    done

    # 确保成功获取到网页内容
    if [ -z "${PAGE_CONTENT}" ]; then
        echo "无法获取网页内容，请稍后再试。"
        exit 1
    fi

    # 提取最新版本号
    VERSION=$(echo "${PAGE_CONTENT}" | grep -o "href=\"${TAG_URI}[^\"]*" | head -n 1 | sed "s;href=\"${TAG_URI};;" | sed 's/\"//g')
    echo ${VERSION}

    # 下载并编译
    FILENAME=$(basename ${GITHUB_URI})
    wget -t 3 -T 10 --verbose --show-progress=on --progress=bar --no-check-certificate --hsts-file=/tmp/wget-hsts -c "${GITHUB_URI}/archive/refs/tags/${VERSION}.tar.gz" -O ${FILENAME}.tar.gz
    tar zxf ${FILENAME}.tar.gz
    cd ${FILENAME}-${VERSION}
    go build ./cmd/${FILENAME}
    mv -fv ./${FILENAME} ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/${FILENAME}-freebsd
    chmod -v u+x ${HOME}/s-c-f-serv00-${REPORT_DATE_S}/${FILENAME}-freebsd
    cd -
    rm -rf ${FILENAME}.tar.gz ${FILENAME}-${VERSION}
}

killMe() {
    kill -9 $(ps | grep -v grep | grep sing-box-freebsd | awk '{print $1}')
    kill -9 $(ps | grep -v grep | grep cloudflared-freebsd | awk '{print $1}')
}

# 神秘的分割线
echo "=========================================="
# 执行函数
killMe
downloadFile
makeAndrun
# 神秘的分隔符
echo "=========================================="
cat result.txt
# 删除脚本自身
#rm -fv s-c-f-serv00.sh
