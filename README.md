# elasticsearch5.6.8
elasticsearch-5.6.8 一键安装脚本脚本

1.配置文件为安装目录下/config/elasticsearch.yaml文件

2.内存配置文件为安装目录下/config/jvm.options (默认为1g,更改后重启生效)

3.通过更改elasticsearch_install_path.txt文件中的路径指定elasticsearch安装的目录路径,默认为/data/software

4.数据目录路径为安装目录下的data路径

5.日志目录路径为安装目录下的logs路径

6.elasticsearch管理脚本/etc/init.d/elasticsearch-5.6.8  start|stop|restart

7.一键安装脚本chmod +x elasticsearch_install.sh && ./elasticsearch_install.sh

8.若需要更改安装elasticsearch的版本,修改elasticsearch_install.sh脚本中verison="5.6.8" 为verison="5.需要安装的版本号"

elasticsearch管理

elasticsearch启动: /etc/init.d/elasticsearch-5.6.8  start

elasticsearch关闭: /etc/init.d/elasticsearch-5.6.8  stop

elasticsearch重启: /etc/init.d/elasticsearch-5.6.8  restart
