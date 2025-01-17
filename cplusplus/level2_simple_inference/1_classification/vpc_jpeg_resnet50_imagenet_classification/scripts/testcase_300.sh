caffe_model="https://obs-model-ascend.obs.cn-east-2.myhuaweicloud.com/resnet50/resnet50.caffemodel"
caffe_prototxt="https://obs-model-ascend.obs.cn-east-2.myhuaweicloud.com/resnet50/resnet50.prototxt"
data_source="https://c7xcode.obs.cn-north-4.myhuaweicloud.com/models/aclsample/"
model_name="resnet50_aipp"
project_name="cplusplus_vpc_jpeg_resnet50_imagenet_classification"

version=$1

script_path="$( cd "$(dirname $BASH_SOURCE)" ; pwd -P)"
project_path=${script_path}/..

declare -i success=0
declare -i inferenceError=1
declare -i verifyResError=2

function downloadData() {
    mkdir -p ${project_path}/data/

    wget -O ${project_path}/data/"persian_cat_1024_1536_283.jpg"  ${data_source}"persian_cat_1024_1536_283.jpg"  --no-check-certificate
    if [ $? -ne 0 ];then
        echo "download persian_cat_1024_1536_283.jpg failed, please check Network."
        return 1
    fi

    wget -O ${project_path}/data/"wood_rabbit_1024_1061_330.jpg"  ${data_source}"wood_rabbit_1024_1061_330.jpg"  --no-check-certificate
    if [ $? -ne 0 ];then
        echo "download wood_rabbit_1024_1061_330.jpg failed, please check Network."
        return 1
    fi

    wget -O ${project_path}/data/"wood_rabbit_1024_1068_nv12.yuv"  ${data_source}"wood_rabbit_1024_1068_nv12.yuv"  --no-check-certificate
    if [ $? -ne 0 ];then
        echo "download wood_rabbit_1024_1068_nv12.yuv failed, please check Network."
        return 1
    fi

    wget -O ${project_path}/data/"dvpp_vpc_8192x8192_nv12.yuv"  ${data_source}"dvpp_vpc_8192x8192_nv12.yuv"  --no-check-certificate
    if [ $? -ne 0 ];then
        echo "download dvpp_vpc_8192x8192_nv12.yuv failed, please check Network."
        return 1
    fi

    return 0
}

function setAtcEnv() {
    # 设置模型转换时需要的环境变量
    if [[ ${version} = "c73" ]] || [[ ${version} = "C73" ]];then
        export install_path=/home/HwHiAiUser/Ascend/ascend-toolkit/latest
        export PATH=/usr/local/python3.7.5/bin:${install_path}/atc/ccec_compiler/bin:${install_path}/atc/bin:$PATH
        export PYTHONPATH=${install_path}/atc/python/site-packages/te:${install_path}/atc/python/site-packages/topi:$PYTHONPATH
        export ASCEND_OPP_PATH=${install_path}/opp
        export LD_LIBRARY_PATH=${install_path}/atc/lib64:${LD_LIBRARY_PATH}
    elif [[ ${version} = "c75" ]] || [[ ${version} = "C75" ]];then
        export install_path=$HOME/Ascend/ascend-toolkit/latest
        export PATH=/usr/local/python3.7.5/bin:${install_path}/atc/ccec_compiler/bin:${install_path}/atc/bin:$PATH
        export ASCEND_OPP_PATH=${install_path}/opp
        export PYTHONPATH=${install_path}/atc/python/site-packages:${install_path}/atc/python/site-packages/auto_tune.egg/auto_tune:${install_path}/atc/python/site-packages/schedule_search.egg:$PYTHONPATH
        export LD_LIBRARY_PATH=${install_path}/atc/lib64:${LD_LIBRARY_PATH}
    fi

    return 0
}

function downloadOriginalModel() {
    wget -O ${project_path}/caffe_model/${caffe_prototxt##*/} ${caffe_prototxt} --no-check-certificate
    if [ $? -ne 0 ];then
        echo "install caffe_prototxt failed, please check Network."
        return 1
    fi

    wget -O ${project_path}/caffe_model/${caffe_model##*/} ${caffe_model} --no-check-certificate
    if [ $? -ne 0 ];then
        echo "install caffe_model failed, please check Network."
        return 1
    fi

    return 0
}

function setBuildEnv() {
    if [[ ${version} = "c73" ]] || [[ ${version} = "C73" ]];then
        export DDK_PATH=/home/HwHiAiUser/Ascend/ascend-toolkit/latest/x86_64-linux_gcc7.3.0
        export NPU_HOST_LIB=${DDK_PATH}/acllib/lib64/stub
    elif [[ ${version} = "c75" ]] || [[ ${version} = "C75" ]];then
        export DDK_PATH=/home/HwHiAiUser/Ascend/ascend-toolkit/latest/x86_64-linux
        export NPU_HOST_LIB=${DDK_PATH}/acllib/lib64/stub
    fi

    return 0
}

function main() {
    if [[ ${version}"x" = "x" ]];then
        echo "ERROR: version is invalid"
        return ${inferenceError}
    fi

    # 下载视频解码输入文件
    downloadData
    if [ $? -ne 0 ];then
        echo "ERROR: download data failed."
        return ${inferenceError}
    fi

    mkdir -p ${HOME}/models/${project_name}
    if [ $? -ne 0 ];then
        echo "ERROR: mkdir models folder failed. please check your project"
        return ${inferenceError}
    fi
    mkdir -p ${project_path}/model/
    if [ $? -ne 0 ];then
        echo "ERROR: mkdir model folder failed. please check your project"
        return ${inferenceError}
    fi
    if [[ $(find ${HOME}/models/${project_name} -name ${model_name}".om")"x" = "x" ]];then 
        # 下载原始模型文件
        downloadOriginalModel
        if [ $? -ne 0 ];then
            echo "ERROR: download original model failed"
            return ${inferenceError}
        fi
    
        # 设置模型转换的环境变量
        setAtcEnv
        if [ $? -ne 0 ];then
            echo "ERROR: set atc environment failed"
            return ${inferenceError}
        fi

        # 转模型
        atc --model=${project_path}/caffe_model/${caffe_prototxt##*/} --weight=${project_path}/caffe_model/${caffe_model##*/} --framework=0 --output=${HOME}/models/${project_name}/${model_name} --soc_version=Ascend310 --insert_op_conf=${project_path}/caffe_model/aipp.cfg
        if [ $? -ne 0 ];then
            echo "ERROR: convert model failed"
            return ${inferenceError}
        fi

        ln -s ${HOME}/models/${project_name}/${model_name}".om" ${project_path}/model/${model_name}".om"
        if [ $? -ne 0 ];then
            echo "ERROR: failed to set model soft connection"
            return ${inferenceError}
        fi
    else 
        ln -s ${HOME}/models/${project_name}/${model_name}".om" ${project_path}/model/${model_name}".om"
        if [ $? -ne 0 ];then
            echo "ERROR: failed to set model soft connection"
            return ${inferenceError}
        fi
    fi

    # 创建目录用于存放编译文件
    mkdir -p ${project_path}/build/intermediates/host
    if [ $? -ne 0 ];then
        echo "ERROR: mkdir build folder failed. please check your project"
        return ${inferenceError}
    fi
    cd ${project_path}/build/intermediates/host

    # 设置代码编译时需要的环境变量
    setBuildEnv
    if [ $? -ne 0 ];then
        echo "ERROR: set build environment failed"
        return ${inferenceError}
    fi

    # 产生Makefile
    cmake ${project_path}/src -DCMAKE_CXX_COMPILER=g++ -DCMAKE_SKIP_RPATH=TRUE
    if [ $? -ne 0 ];then
        echo "ERROR: cmake failed. please check your project"
        return ${inferenceError}
    fi

    make 
    if [ $? -ne 0 ];then
        echo "ERROR: make failed. please check your project"
        return ${inferenceError}
    fi

    cd ${project_path}/out

    # 重新配置程序运行所需的环境变量
    export LD_LIBRARY_PATH=
    export LD_LIBRARY_PATH=/home/HwHiAiUser/Ascend/nnrt/latest/acllib/lib64:$LD_LIBRARY_PATH

    # 运行程序
    ./main 0 > result.txt
    if [ $? -ne 0 ];then
        echo "ERROR: run vpc resize failed. please check your project"
        return ${inferenceError}
    fi

    # 验证结果
    results=$(cat result.txt)
    if [[ $results =~ "ERROR" || $results =~ "fail" || $results =~ "FAIL" || $results =~ "error" ]];then
        echo "run failed"
        return ${verifyResError}
    else
        echo "run success"
        return ${success}
    fi

    # 运行程序
    ./main 1 > result.txt
    if [ $? -ne 0 ];then
        echo "ERROR: run vpc crop failed. please check your project"
        return ${inferenceError}
    fi

    # 验证结果
    results=$(cat result.txt)
    if [[ $results =~ "ERROR" || $results =~ "fail" || $results =~ "FAIL" || $results =~ "error" ]];then
        echo "run failed"
        return ${verifyResError}
    else
        echo "run success"
        return ${success}
    fi

    # 运行程序
    ./main 2 > result.txt
    if [ $? -ne 0 ];then
        echo "ERROR: run vpc crop and paste failed. please check your project"
        return ${inferenceError}
    fi

    # 验证结果
    results=$(cat result.txt)
    if [[ $results =~ "ERROR" || $results =~ "fail" || $results =~ "FAIL" || $results =~ "error" ]];then
        echo "run failed"
        return ${verifyResError}
    else
        echo "run success"
        return ${success}
    fi

    # 运行程序
    ./main 3 > result.txt
    if [ $? -ne 0 ];then
        echo "ERROR: run jpege failed. please check your project"
        return ${inferenceError}
    fi

    # 验证结果
    results=$(cat result.txt)
    if [[ $results =~ "ERROR" || $results =~ "fail" || $results =~ "FAIL" || $results =~ "error" ]];then
        echo "run failed"
        return ${verifyResError}
    else
        echo "run success"
        return ${success}
    fi

    # 运行程序
    ./main 4 > result.txt
    if [ $? -ne 0 ];then
        echo "ERROR: run vpc 8k resize failed. please check your project"
        return ${inferenceError}
    fi

    # 验证结果
    results=$(cat result.txt)
    if [[ $results =~ "ERROR" || $results =~ "fail" || $results =~ "FAIL" || $results =~ "error" ]];then
        echo "run failed"
        return ${verifyResError}
    else
        echo "run success"
        return ${success}
    fi
}
main
