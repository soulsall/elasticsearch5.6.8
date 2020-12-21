#! /bin/bash
installdir=$(cd `dirname $0`; pwd)
cd $installdir

function install_java()
{
  yum -y install java-1.8.0-openjdk-1.8.0.275.b01-0.el7_9.x86_64
  #java_path=`ls -l /etc/alternatives/java |awk {'print $11'}|cut -c 1-60`
  java_path="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.275.b01-0.el7_9.x86_64"
  java_env=`cat /etc/profile|grep -v grep |grep java`
  if [[ "$java_env" != "" ]]
  then
      echo '已设置环境变量'
  else
      echo "JAVA_HOME=$java_path" >>/etc/profile
      echo "CLASSPATH=." >>/etc/profile
      echo "PATH=$PATH:$JAVA_HOME/bin" >>/etc/profile
      echo "export PATH JAVA_HOME CLASSPATH" >>/etc/profile
      source /etc/profile
  fi
  echo "java install complete"
}

function install_elasticsearch()
{   yum -y install unzip
    #安装的elasticsearch版本号
    verison="5.6.8"
    elastic_url="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$verison.zip"
    analysis_url="https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v$verison/elasticsearch-analysis-ik-$verison.zip"
    cd ${installdir} 
    es_package="elasticsearch-$verison.zip"
    analysis_package="elasticsearch-analysis-ik-$verison.zip"
    if [ ! -f "$es_package" ];then
       echo "beginnging download package of $es_package"
       /usr/bin/wget $elastic_url
    fi
    echo "$es_package is exits"
    if [ ! -f "$analysis_package" ];then
       echo "beginnging download package of $analysis_package"
       /usr/bin/wget $analysis_url
    fi
    echo "$analysis_package is exits"
    es_install_dir=$(cat elasticsearch_install_path.txt|grep -v '#')
    mkdir -p $es_install_dir
    unzip $es_package -d $es_install_dir
    unzip $analysis_package
    mv elasticsearch $es_install_dir/elasticsearch-$verison/plugins/analysis-ik
    mkdir -p $es_install_dir/elasticsearch-$verison/{data,logs}
    yes |cp -i $installdir/elasticsearch.yml $es_install_dir/elasticsearch-$verison/config/
    sed -i -e "s#\/data\/software#$es_install_dir#" $es_install_dir/elasticsearch-$verison/config/elasticsearch.yml
    #默认设置es启动内存为1g
    sed -i "1,30s#\-Xms2g#\-Xms1g#" $installdir/elasticsearch.yml $es_install_dir/elasticsearch-$verison/config/jvm.options
    sed -i "1,30s#\-Xmx2g#\-Xmx1g#" $installdir/elasticsearch.yml $es_install_dir/elasticsearch-$verison/config/jvm.options
    groupadd elasticsearch
    useradd elasticsearch -g elasticsearch 
    chown -R elasticsearch:elasticsearch $es_install_dir/elasticsearch-$verison
    yes|cp -aR elasticsearch-5.6.8 /etc/init.d/ && chmod +x /etc/init.d/elasticsearch-5.6.8
    sed -i -e "s#\/data\/software#$es_install_dir#" /etc/init.d/elasticsearch-5.6.8
}


function set_system()
{
   sed -i -e 's/65535/65536/g' /etc/security/limits.conf
   soft_nofile=`cat /etc/security/limits.conf |grep -v grep|grep -v '#'|grep 'soft nofile'`
   if [[ "$soft_nofile" != "" ]];then
      echo ''
   else
      echo "* soft nofile 65536" >>/etc/security/limits.conf
   fi
   hard_nofile=`cat /etc/security/limits.conf |grep -v grep|grep -v '#'|grep 'hard nofile'`
   if [[ "$hard_nofile" != "" ]];then
      echo ''
   else
      echo "* hard nofile 65536" >>/etc/security/limits.conf
   fi
   soft_nproc=`cat /etc/security/limits.conf |grep -v grep|grep -v '#'|grep 'soft nproc'`
   if [[ "$soft_nproc" != "" ]];then
      echo ''
   else
      echo "* soft nproc 2048" >>/etc/security/limits.conf
   fi
   hard_nproc=`cat /etc/security/limits.conf |grep -v grep|grep -v '#'|grep 'hard nproc'`
   if [[ "$hard_nproc" != "" ]];then
      echo ''
   else
      echo "* hard nproc 4096" >>/etc/security/limits.conf
   fi
   elasticsearch_soft=`cat /etc/security/limits.conf |grep -v grep|grep -v '#'|grep 'elasticsearch soft'`
   if [[ "$elasticsearch_soft" != "" ]];then
      echo ''
   else
      echo "elasticsearch soft memlock unlimited" >>/etc/security/limits.conf
   fi
   elasticsearch_hard=`cat /etc/security/limits.conf |grep -v grep|grep -v '#'|grep 'elasticsearch hard'`
   if [[ "$elasticsearch_hard" != "" ]];then
      echo ''
   else
      echo "elasticsearch hard memlock unlimited" >>/etc/security/limits.conf
   fi
   max_map_count=`cat /etc/sysctl.conf|grep -v grep |grep -v '#'|grep 'vm.max_map_count'`
   if [[ "$max_map_count" != "" ]];then
      sed -i -e 's/vm.max_map_count/#vm.max_map_count/g' /etc/sysctl.conf
      echo "vm.max_map_count = 262144" >>/etc/sysctl.conf
   else
      echo "vm.max_map_count = 262144" >>/etc/sysctl.conf
   fi
   file_max=`cat /etc/sysctl.conf|grep -v grep |grep -v '#'|grep 'fs.file-max'`
   if [[ "$file_max" != "" ]];then
      sed -i -e 's/fs.file-max/#fs.file-max/g' /etc/sysctl.conf
      echo "fs.file-max = 655360" >>/etc/sysctl.conf
   else
      echo "fs.file-max = 655360" >>/etc/sysctl.conf
   fi
   sysctl -p 
   echo "elasticsearch-5.6.8 install complete"
   echo "You can execute  /etc/init.d/elasticsearch-5.6.8 start  to run the elasticsearch service"
}

install_java
install_elasticsearch
set_system
