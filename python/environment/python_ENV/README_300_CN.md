中文|[English](README_300_EN.md)

# 安装Python3运行环境<a name="ZH-CN_TOPIC_0228768065"></a>
$\color{red}{以下命令在运行环境上执行}$

1.  安装pip3  
    **sudo apt-get install python3-pip**      
2.  安装pillow 的依赖    
    **sudo apt-get install libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk**

3.  安装python库  
     **python3.6 -m pip install --upgrade pip --user -i https://mirrors.huaweicloud.com/repository/pypi/simple**   
     **python3.6 -m pip install Cython numpy pillow tornado==5.1.0 protobuf --user -i https://mirrors.huaweicloud.com/repository/pypi/simple**   
    >![输入图片说明](https://images.gitee.com/uploads/images/2020/1130/162342_1d7d35d7_7401379.png "屏幕截图.png") **说明：**  
    >  **若apt-get安装依赖出现类似报错（dpkg: error processing package *** (--configure)） ，请参考[FAQ](https://bbs.huaweicloud.com/forum/thread-74123-1-1.html)来解决。**  
    >  **若Python包安装失败，可以试用其他源 https://bbs.huaweicloud.com/forum/thread-97632-1-1.html 或不加-i 参数使用默认pip源**


4.  安装python3-opencv  
    **sudo apt-get install python3-opencv**

5.  安装ffmpeg  
    Python样例中的atlas_util库会调用ffmpeg的so文件。 
 
    创建文件夹，用于存放编译后的文件  
    **mkdir -p /home/HwHiAiUser/ascend_ddk/x86**

    下载ffmpeg  
    **cd $HOME**  
    **wget http://www.ffmpeg.org/releases/ffmpeg-4.1.3.tar.gz**  
    **tar -zxvf ffmpeg-4.1.3.tar.gz**  
    **cd ffmpeg-4.1.3**

    安装ffmpeg   
    **./configure --enable-shared --enable-pic --enable-static --disable-x86asm --prefix=/home/HwHiAiUser/ascend_ddk/x86**  
    **make -j8**      
    **make install**

    将ffmpeg添加到系统环境变量中，使得其他程序能够找到ffmpeg环境  
    **su root**  
    **vim /etc/ld.so.conf.d/ffmpeg.conf**  
    在末尾添加一行   
    **/home/HwHiAiUser/ascend_ddk/x86/lib**  
    使配置生效    
    **ldconfig**  

    配置profile系统文件    
    **vim /etc/profile**    
    在末尾添加一行  
    **export PATH=$PATH:/home/HwHiAiUser/ascend_ddk/x86/bin**    
    使配置文件生效    
    **source /etc/profile**    
    使opencv能找到ffmpeg   
    **cp /home/HwHiAiUser/ascend_ddk/x86/lib/pkgconfig/\* /usr/share/pkgconfig**    
    退出root用户   
    **exit**
