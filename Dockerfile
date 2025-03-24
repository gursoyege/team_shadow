# Make sure to install nvidia-container-toolkit at host
FROM nvcr.io/nvidia/pytorch:23.04-py3

ENV DEBIAN_FRONTEND=noninteractive \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

## If you don't want to continue as root uncomment below
#ARG USERNAME=h2o
#RUN useradd -m ${USERNAME} -s /bin/bash && \
#    echo "${USERNAME}:${USERNAME}" | chpasswd && \
#    adduser ${USERNAME} sudo

#USER ${USERNAME}
#WORKDIR /home/${USERNAME}

#ENV PATH="/home/${USERNAME}/.local/bin:$PATH"

# System Dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    bash \
    libxcursor-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxi-dev \
    mesa-common-dev \
    zip \
    unzip \
    make \
    gcc-8 \
    g++-8 \
    vulkan-tools \
    mesa-vulkan-drivers \
    pigz \
    git \
    git-lfs \
    libegl1 \
    ffmpeg \
    libsm6 \
    libxext6 \
    libxrender-dev \
    wget \
    curl

# Force gcc 8
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8
    
RUN rm /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0 /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0.0.0 \
    /usr/share/glvnd/egl_vendor.d/50_mesa.json

# To vulcan drivers can find nvidia
RUN cat <<'EOF' > /usr/share/vulkan/icd.d/nvidia_icd.json
{
    "file_format_version": "1.0.0",
    "ICD": {
        "library_path": "libGLX_nvidia.so.0",
        "api_version": "1.1.95"
    }
}
EOF

RUN cat <<'EOF' > /usr/share/glvnd/egl_vendor.d/10_nvidia.json
{
    "file_format_version": "1.0.0",
    "ICD": {
        "library_path": "libEGL_nvidia.so.0"
    }
}
EOF

# pip deps
RUN pip install \
    mujoco \
    pytorch_lightning==2.3.3 \
    numpy-stl \
    vtk \
    patchelf \
    termcolor \
    torchgeometry \
    scikit-image \
    numpy==1.23.5 \
    scipy \
    ipdb \
    joblib \
    opencv-python==4.5.5.64 \
    tqdm \
    pyyaml \
    wandb \
    gym \
    lxml \
    scikit-learn \
    chumpy \
    pyvirtualdisplay \
    chardet \
    cchardet \
    imageio-ffmpeg \
    easydict \
    open3d \
    gdown \
    pynput \
    rich \
    hydra-core \
    onnx \
    onnxruntime \
    rl-games \
    roma \ 
    onnxsim \ 
    pycocotools \
    pycuda

WORKDIR /home

ENV HOME=/home

# Isaac Gym
RUN python -m gdown --id 1oH2GzOsf5ylYaKubC4QEHtm4c0-FLld5 -O isaacgym.tar.gz && \
    tar -xzf isaacgym.tar.gz && \
    rm isaacgym.tar.gz && \
    cd isaacgym/python && pip install -e .

# human2humanoid
RUN git clone https://github.com/gursoyege/human2humanoid.git && \
    cd human2humanoid && \
    pip install -e rsl_rl && \
    pip install -e legged_gym && \
    pip install -e phc && \
    pip install git+https://github.com/ZhengyiLuo/smplx.git@master && \
    pip install git+https://github.com/ZhengyiLuo/SMPLSim.git@master

# Force pytorch3d compile at gpu
ENV FORCE_CUDA=1
 
# HybrIK
RUN git clone https://github.com/gursoyege/HybrIK.git && \
    cd HybrIK && \
    pip install -e . && \
    MAX_JOBS=4 pip install git+https://github.com/facebookresearch/pytorch3d.git@V0.7.8  && \
    mkdir -p pretrained_models && \
    mkdir -p model_files && \
    python -m gdown --id 1un9yAGlGjDooPwlnwFpJrbGHRiLaBNzV -O model_files.zip && \
    unzip model_files.zip -d . && \
    rm model_files.zip && \
    python -m gdown --id 1o3z99bebm2XImElc3XEUzTNVhQboGJE9 -O pretrained_models/hybrik_hrnet48_wo3dpw.pth && \
    python -m gdown --id 19ktHbERz0Un5EzJYZBdzdzTrFyd9gLCx -O pretrained_models/hybrik_res34_w3dpw.pth
    
# HybrIK-TensorRT, some files are copied from HybrIK
RUN git clone https://github.com/gursoyege/HybrIK-TensorRT && \
    cp -r HybrIK/pretrained_models HybrIK-TensorRT/ && \
    cp -r HybrIK/model_files HybrIK-TensorRT/model_files/

ENV NVIDIA_VISIBLE_DEVICES=all 
ENV NVIDIA_DRIVER_CAPABILITIES=all

# remove nvidia container workspace
RUN rm -rf /workspace

# Even I am root, some scripts need sudo command, I set sudo to use no pass
RUN echo "root ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopass && \
    chmod 0440 /etc/sudoers.d/nopass 
    
# I default to oh-my-zsh with a different theme than my usual terminal otherwise I forget that I'm in a container and the chaos begins...
RUN git clone --depth=1 https://github.com/ohmybash/oh-my-bash.git ~/.oh-my-bash && \
    echo 'export OSH_THEME="agnoster"' >> ~/.bashrc && \
    echo 'export OSH=$HOME/.oh-my-bash' >> ~/.bashrc && \
    echo 'source $OSH/oh-my-bash.sh' >> ~/.bashrc


