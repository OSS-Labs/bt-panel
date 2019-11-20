#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
setup_path=/www

version=$1

if [ "$version" = '' ];then
	updateApi=https://www.bt.cn/Api/updateLinux
	if [ -f /www/server/panel/plugin/beta/beta_main.py ];then
		updateApi=https://www.bt.cn/Api/updateLinuxBeta
	fi
	version=`/usr/local/curl/bin/curl $updateApi 2>/dev/null|grep -Po '"version":".*?"'|grep -Po '[0-9\.]+'`
fi

if [ "$version" = '' ];then
	echo '版本号获取失败，请手动在第一个参数传入！';
	exit;
fi

wget -T 5 -O panel.zip https://github.com/oss-labs/bt-panel/archive/$version.zip

unzip -o panel.zip -d $setup_path/server/ > /dev/null
mv -f $setup_path/server/bt-panel-$version/* $setup_path/server/panel

rm -rf $setup_path/server/bt-panel-$version

rm -f panel.zip
cd $setup_path/server/panel/
rm -f $setup_path/server/panel/class/*.pyc
python -m compileall $setup_path/server/panel/
python -m compileall $setup_path/server/panel/main.py
python -m compileall $setup_path/server/panel/task.py
python -m compileall $setup_path/server/panel/tools.py
if [ -f "main.py" ];then
	python -m py_compile main.py
fi
if [ -f "task.py" ];then
	python -m py_compile task.py
fi
if [ -f "tools.py" ];then
	python -m py_compile tools.py
fi

rm -f $setup_path/server/panel/data/templates.pl
check_bt=`cat /etc/init.d/bt`
if [ "${check_bt}" = "" ];then
	rm -f /etc/init.d/bt
	wget -O /etc/init.d/bt https://github.com/oss-labs/bt-panel/blob/master/install/bt.init -T 10
	chmod +x /etc/init.d/bt
fi
if [ ! -f "/etc/init.d/bt" ]; then
	wget -O /etc/init.d/bt https://github.com/oss-labs/bt-panel/blob/master/install/bt.init -T 10
	chmod +x /etc/init.d/bt
fi
sleep 1 && service bt restart > /dev/null 2>&1 &
echo "====================================="
echo "已成功升级到[$version]！";
