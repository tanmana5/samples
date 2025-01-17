English|[中文](README_CN.md)

**The following sample provides reference for you to learn the Ascend AI Software Stack and cannot be used for commercial purposes.**

**The sample applies to CANN 20.0 and later versions and supports Atlas 200 DK.**

**This README provides only guidance for running samples in command line mode. For details about how to run samples in MindStudio, see [Running Video Samples in MindStudio_wiki](https://github.com/Huawei-Ascend/samples/wikis/Mindstudio%E8%BF%90%E8%A1%8C%E8%A7%86%E9%A2%91%E6%A0%B7%E4%BE%8B?sort_id=3170138).**

## Sample of Object Detection in a Video

Function: Use the face detection model to detect faces in instant video shot by a Raspberry Pi camera.

Input: Video shot by a camera

Output: Detection result displayed on Presenter

### Prerequisites

Before deploying this sample, ensure that:

- The environment has been prepared according to [Environment Preparation and Dependency Installation](../../../environment).

- The development environment and operating environment of the corresponding product have been installed.

### Preparing Software

1. Obtain the source code package.

   You can use either of the following methods to download the source code:

    - Command line (The download takes a long time, but the procedure is simple.)
        In the development environment, run the following commands as a non-root user to download the source code repository:  
       **cd $HOME**  
       **git clone https://github.com/Huawei-Ascend/samples.git**

    - Compressed package (The download time is short, but the procedure is complex.)
        1. Click **Clone or download** in the upper right corner of the samples repository and click **Download ZIP**.
        2. Upload the .zip package to the home directory of a common user in the development environment, for example, **$HOME/ascend-samples-master.zip**.
        3. In the development environment, run the following commands to decompress the .zip package:  
            **cd $HOME**  
            **unzip ascend-samples-master.zip**

2. Obtain the source network model required by the application.

    Obtain the original network model and its weight file used in the application by referring to the following table and store them in model folder of project directory of a common user in the development environment, for example, **$HOME/samples/cplusplus/level2_simple_inference/2_object_detection/face_detection_camera/model**.
  
    | **Model Name** | **Description** | **How to Obtain** |
    |---|---|---|
    |  face_detection| Image classification inference model. It is a YOLOv3 model based on Caffe.   | Download the original model and weight file by referring to [https://github.com/Huawei-Ascend/modelzoo/tree/master/contrib/TensorFlow/Research/cv/facedetection/ATC_resnet10-SSD_caffe_AE](https://github.com/Huawei-Ascend/modelzoo/tree/master/contrib/TensorFlow/Research/cv/facedetection/ATC_resnet10-SSD_caffe_AE).  |

    ![](https://images.gitee.com/uploads/images/2020/1106/160652_6146f6a4_5395865.gif "icon-note.gif") **Note**

    > - The converted OM model provided by ModelZoo does not match the current sample. Therefore, you need to download the original model and weight file to convert the model by yourself.

3. Convert the original model to a Da Vinci model.

    **Note: Ensure that the environment variables have been configured in [Environment Preparation and Dependency Installation](../../../environment).**

    1. Set the **LD_LIBRARY_PATH** environment variable.

        The **LD_LIBRARY_PATH** environment variable conflicts with the sample when the ATC tool is used. Therefore, you need to set this environment variable in the command line to facilitate modification.

        **export LD_LIBRARY_PATH=\\${install_path}/atc/lib64**  

    2. Run the following command to download the AIPP configuration file and run the ATC command to convert the model:

        **cd $HOME/samples/cplusplus/level2_simple_inference/2_object_detection/face_detection_camera/model**  

        **wget https://c7xcode.obs.cn-north-4.myhuaweicloud.com/models/face_detection_camera/insert_op.cfg**

        **atc --output_type=FP32 --input_shape="data:1,3,300,300" --weight=./face_detection_fp32.caffemodel --input_format=NCHW --output=./face_detection --soc_version=Ascend310 --insert_op_conf=./insert_op.cfg --framework=0 --save_original_model=false --model=./face_detection.prototxt**


### Deploying the Sample

1. Modify Presenter-related configuration files.

    Change **presenter_server_ip** and **presenter_view_ip** in **scripts/param.conf** in the sample directory to the IP addresses that can ping the operating environment in the development environment. 

    1. In the development environment, run the ifconfig command to view available IP addresses.    
    2. In the development environment, change **presenter_server_ip** and **presenter_view_ip** in **scripts/param.conf** to the available IP addresses.

    ![](https://images.gitee.com/uploads/images/2020/1106/160652_6146f6a4_5395865.gif "icon-note.gif") **Note**

    > - 1. If the development environment and operating environment are deployed on separate servers, the configured virtual NIC IP address is used, for example, 192.168.1.223.    
    > - 2. If the development environment and operating environment are deployed on the same server, the fixed IP address of Atlas 200 DK is used, for example, 192.168.1.2.

2. Set the environment variables on which compilation depends in the command line of the development environment.
  
     **export DDK_PATH=$HOME/Ascend/ascend-toolkit/latest/arm64-linux**  
     **export NPU_HOST_LIB=$DDK_PATH/acllib/lib64/stub**

     ![](https://images.gitee.com/uploads/images/2020/1106/160652_6146f6a4_5395865.gif "icon-note.gif") **Note**

     > - If the version is 20.0, change **arm64-linux** in the **DDK_PATH** environment variable to **arm64-linux_gcc7.3.0**.

3. Go to the **face_detection_camera** directory and create a directory for storing build outputs. For example, the directory created in this sample is **build/intermediates/host**.

    **cd $HOME/samples/cplusplus/level2_simple_inference/2_object_detection/face_detection_camera**

    **mkdir -p build/intermediates/host**

4. Go to the **build/intermediates/host** directory and run the cmake command.

      **cd build/intermediates/host**  
      **make clean**  
      **cmake \.\./\.\./\.\./src -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ -DCMAKE_SKIP_RPATH=TRUE**

5. Run the make command to generate an executable file **main** in the **face_detection_camera/out** directory.

    **make**

### Running the Sample

![](https://images.gitee.com/uploads/images/2020/1106/160652_6146f6a4_5395865.gif "icon-note.gif") **Note**

> - In the following information, **xxx.xxx.xxx.xxx** indicates the IP address of the operating environment. The IP address of Atlas 200 DK is 192.168.1.2 when the USB is connected.

1. Run the following command to upload the **face_detection_camera** directory in the development environment to the operating environment, for example, **/home/HwHiAiUser**:

    **If the development environment and operating environment are deployed on the same server, skip this step.**  

    **scp -r $HOME/samples/cplusplus/level2_simple_inference/2_object_detection/face_detection_camera HwHiAiUser@xxx.xxx.xxx.xxx:/home/HwHiAiUser**

2. Start the Presenter Server and log in to the operating environment.

    1. Run the following command in the development environment to start the Presenter Server:  
        **cd $HOME/samples/cplusplus/level2_simple_inference/2_object_detection/face_detection_camera**  
        **bash scripts/run_presenter_server.sh**  
    2. Run the following command to log in to the operating environment:  
        **If the development environment and operating environment are deployed on the same server, skip this step.**  
        **ssh HwHiAiUser@xxx.xxx.xxx.xxx**

3. Run the executable file.

    - If the development environment and operating environment are deployed on the same server, run the following commands to set the operating environment variables and switch the directory:  
      **export LD_LIBRARY_PATH=**  
      **source ~/.bashrc**  
      **cd $HOME/samples/cplusplus/level2_simple_inference/2_object_detection/face_detection_camera/out**

    - If the development environment and operating environment are deployed on separate servers, run the following command to switch the directory:  
      **cd $HOME/face_detection_camera/out**

    Switch to the directory and run the following command to run the sample:

    **./main**

### Checking the Result

1. Open the Presenter Server WebUI.Open the URL that is displayed when the Presenter Server service is started.

2. Wait for Presenter Agent to transmit data to the server. Click Refresh. When there is data, the icon in the Status column for the corresponding channel changes to green.

3. Click the View Name link on the right to view the result.
