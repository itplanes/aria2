#!/bin/bash
#####		一键安装aria2 + yaaw	#####
#####		Author:xiaoz.me			#####
#####		Update:2017-12-07		#####

#获取服务器IP
osip=$(curl http://https.tn/ip/myip.php?type=onlyip)

#安装函数
function centos(){
	yum -y install epel-release
	yum -y install aria2
}

#来不及了，后面再适配Debian吧
function debian(){
	apt-get install aria2
}

#创建目录与配置
function setting(){
	mkdir -p /data/aria2
	mkdir -p /data/aria2/download
	touch /data/aria2/aria2.session
	cp aria2.conf caddy.conf aria2.sh /data/aria2
	
	echo "-------------------------------"
	read -p "设置用户名：" user
	read -p "设置密码：" pass
	read -p "设置Aria2授权令牌（字母或数字组合，不要包含特殊字符）：" rpc
	echo "-------------------------------"
	sed -i "s/rpc-secret=/rpc-secret=${rpc}/g" /data/aria2/aria2.conf
	#下载yaaw
	wget -P /data/aria2 https://github.com/binux/yaaw/archive/master.zip
	cd /data/aria2
	unzip master.zip
	mv yaaw-master/* ./
	
	#下载caddy server
	wget http://soft.xiaoz.org/linux/caddy.filemanager -O caddy && mv caddy /usr/bin/
	chmod +x /usr/bin/caddy
	#修改配置
	#sed -i "s/localhost/$1/g" /data/aria2/caddy.conf
	sed -i "s/username/${user}/g" /data/aria2/caddy.conf
	sed -i "s/password/${pass}/g" /data/aria2/caddy.conf
	#放行端口
	chk_firewall
	#启动服务
	cd /data/aria2
	nohup aria2c --conf-path=/data/aria2/aria2.conf > /data/aria2/aria2.log 2>&1 &
	nohup caddy -conf="/data/aria2/caddy.conf" > /data/aria2/caddy.log 2>&1 &
	echo "-------------------------------"
	echo "#####		安装完成，请牢记以下信息。	#####"
	echo "访问地址：http://${osip}:6080"
	echo "用户名：${user}"
	echo "密码：${pass}"
	echo "RPC地址：http://token:${rpc}@${osip}:6800/jsonrpc"
	echo "-------------------------------"
	echo "需要帮助请访问：https://www.xiaoz.me/archives/9694"
	echo "-------------------------------"
	#一点点清理工作
	rm -rf /data/aria2/*.zip
	rm -rf /data/aria2/*.tar.gz
	rm -rf /data/aria2/*.txt
	rm -rf /data/aria2/*.md
	rm -rf /data/aria2/yaaw-*
	exit
}

#自动放行端口
function chk_firewall() {
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport 6080 -j ACCEPT
		iptables -I INPUT -p tcp --dport 6800 -j ACCEPT
		service iptables save
		service iptables restart
	else
		firewall-cmd --zone=public --add-port=6080/tcp --permanent
		firewall-cmd --zone=public --add-port=6800/tcp --permanent
		firewall-cmd --reload
	fi
}

echo '#####		欢迎使用一键安装Aria2脚本^_^	#####'
echo '----------------------------------'
echo '请选择系统:'
echo "1) CentOS X64"
echo "2) Debian or Ubuntu X64"
echo "q) 退出"
echo '----------------------------------'
read -p ":" num
echo '----------------------------------'

case $num in
	1)
		#安装
		centos
		#设置
		setting $osip
		#放行端口
	;;
	2)
		echo "老哥，暂时还不支持Debian系统，先等等吧。"
		exit;
	;;
	3)
		echo '还没写呢'
		exit;
	;;
	q)
		exit
	;;
	*)
		echo '错误的参数'
		exit;
	;;
esac