#!/usr/bin/env bash

### Linux install commands 
### The the linux install was too big for the free GitHub runners (as opposed to windows and macos), so
### the linux install is still with the old install method
### Peter van Lunteren, 15 Jan 2025 (latest edit)

# timestamp the start of installation
START_DATE=`date`

# set location var
LOCATION_ECOASSIST_FILES="$HOME/.EcoAssist_files"

# set variables
CONDA_DIR="${LOCATION_ECOASSIST_FILES}/miniforge"
ENV_BASE="${CONDA_DIR}/envs/env-base"
ENV_PYTORCH="${CONDA_DIR}/envs/env-pytorch"
ENV_TENSORFLOW="${CONDA_DIR}/envs/env-tensorflow"
ENV_PYWILDLIFE="${CONDA_DIR}/envs/env-pywildlife"
PIP_BASE="${ENV_BASE}/bin/pip"
PIP_PYTORCH="${ENV_PYTORCH}/bin/pip"
PIP_TENSORFLOW="${ENV_TENSORFLOW}/bin/pip"
PIP_PYWILDLIFE="${ENV_PYWILDLIFE}/bin/pip"

# delete previous installation of EcoAssist if present so that it can update
rm -rf $LOCATION_ECOASSIST_FILES && echo "Removed dir '${LOCATION_ECOASSIST_FILES}'"

# early exit if the folder still exists
if [ -d $LOCATION_ECOASSIST_FILES ]; then
    echo "Error: Folder $LOCATION_ECOASSIST_FILES could not be removed. Exiting script...."
    echo "Copy-paste all text in this console window and send it to peter@addaxdatascience.com for further support."
    exit 1
fi

# make dir and change into
mkdir -p $LOCATION_ECOASSIST_FILES
cd $LOCATION_ECOASSIST_FILES || { echo "Could not change directory to ${LOCATION_ECOASSIST_FILES}. Command could not be run. Copy-paste all text in this console window and send it to peter@addaxdatascience.com for further support."; exit 1; }

# log the start
echo "This installation started at: $START_DATE"

# log the platform
echo "This installation is using platform: $PLATFORM"

# log system information
UNAME_A=`uname -a`
if [ "$PLATFORM" = "Apple Silicon Mac" ] || [ "$PLATFORM" = "Intel Mac" ]; then
  MACHINE_INFO=`system_profiler SPSoftwareDataType SPHardwareDataType SPMemoryDataType SPStorageDataType`
elif [ "$PLATFORM" = "Linux" ]; then
  PATH=$PATH:/usr/sbin
  MACHINE_INFO_1=`lscpu`
  MACHINE_INFO_2=`dmidecode`
  MACHINE_INFO_3=""
  SYSTEM_INFO_DIRECTORY="/sys/devices/virtual/dmi/id/"
  if [ -d "$SYSTEM_INFO_DIRECTORY" ]; then
    echo "$SYSTEM_INFO_DIRECTORY does exist."
    cd $SYSTEM_INFO_DIRECTORY
    for f in *; do
      MACHINE_INFO_3+="
      $f = `cat $f 2>/dev/null || echo "***_Unavailable_***"`"
    done
  fi
  MACHINE_INFO="${MACHINE_INFO_1}
  ${MACHINE_INFO_2}
  ${MACHINE_INFO_3}"
fi
echo "uname -a:" 
echo "$UNAME_A" 
echo "" 
echo "System information:" 
echo "$MACHINE_INFO" 
echo "" 

### create folder structure
mkdir -p "${LOCATION_ECOASSIST_FILES}"
mkdir -p "${LOCATION_ECOASSIST_FILES}/envs"
mkdir -p "${LOCATION_ECOASSIST_FILES}/models"
mkdir -p "${LOCATION_ECOASSIST_FILES}/models/det"
mkdir -p "${LOCATION_ECOASSIST_FILES}/models/cls"
mkdir -p "${LOCATION_ECOASSIST_FILES}/models/det/MegaDetector 5a"
mkdir -p "${LOCATION_ECOASSIST_FILES}/yolov5_versions/yolov5_old"
mkdir -p "${LOCATION_ECOASSIST_FILES}/yolov5_versions/yolov5_new"
echo "Hello world!" >> "${LOCATION_ECOASSIST_FILES}/first-startup.txt"

## clone repositories
git clone --depth 1 https://github.com/PetervanLunteren/EcoAssist.git "${LOCATION_ECOASSIST_FILES}/EcoAssist"
rm -rf "${LOCATION_ECOASSIST_FILES}/EcoAssist/.git"
FILE="$LOCATION_ECOASSIST_FILES/EcoAssist/Linux_open_EcoAssist_shortcut.desktop" # create shortcut file
echo "[Desktop Entry]" > $FILE
echo "Type=Application" >> $FILE
echo "Terminal=true" >> $FILE
echo "Name=EcoAssist" >> $FILE
echo "Icon=logo_small_bg" >> $FILE
echo "Exec=gnome-terminal -e \"bash -c 'bash \$HOME/.EcoAssist_files/EcoAssist/open.command;\$SHELL'\"" >> $FILE
echo "Categories=Application;" >> $FILE
# and give it an icon
SOURCE="$LOCATION_ECOASSIST_FILES/EcoAssist/imgs/logo_small_bg.png"
DEST="$HOME/.icons/logo_small_bg.png"
mkdir -p "$HOME/.icons" # create location if not already present
cp $SOURCE $DEST # copy icon to proper location
FILE="$LOCATION_ECOASSIST_FILES/EcoAssist/Linux_open_EcoAssist_shortcut.desktop"
mv -f $FILE "$HOME/Desktop/Linux_open_EcoAssist_shortcut.desktop" # move file and replace
echo "EcoAssist cloned"

git clone https://github.com/agentmorris/MegaDetector.git "${LOCATION_ECOASSIST_FILES}/MegaDetector" || {
      # if this git repo fails to clone, chances are the conda environments will give problems too
      # so better already set the conda settings to accomodate slow internet speeds
      export CONDA_REMOTE_READ_TIMEOUT_SECS=120
      export CONDA_REMOTE_CONNECTIONS=1
      export CONDA_REMOTE_MAX_RETRIES=20
      # some users experience timeout issues due to the large size of this repository
      # if it fails here, we'll try again with a larger timeout value and less checks during cloning
      echo "First attempt failed. Retrying with extended timeout..."
      GIT_HTTP_POSTBUFFER=524288000 git clone --progress \
          --config transfer.fsckObjects=false \
          --config receive.fsckObjects=false \
          --config fetch.fsckObjects=false \
          https://github.com/agentmorris/MegaDetector.git "${LOCATION_ECOASSIST_FILES}/MegaDetector"
}
git -C "${LOCATION_ECOASSIST_FILES}/MegaDetector" checkout e8a4fc19a2b9ad1892dd9ce65d437252df271576
rm -rf "${LOCATION_ECOASSIST_FILES}/MegaDetector/.git"
mv "${LOCATION_ECOASSIST_FILES}/MegaDetector" "${LOCATION_ECOASSIST_FILES}/cameratraps"
echo "MegaDetector cloned"

git clone https://github.com/ultralytics/yolov5.git "${LOCATION_ECOASSIST_FILES}/yolov5_versions/yolov5_old/yolov5"
git -C "${LOCATION_ECOASSIST_FILES}/yolov5_versions/yolov5_old/yolov5" checkout 868c0e9bbb45b031e7bfd73c6d3983bcce07b9c1
rm -rf "${LOCATION_ECOASSIST_FILES}/yolov5_versions/yolov5_old/yolov5/.git"
echo "yolov5 old version cloned"

git clone https://github.com/ultralytics/yolov5.git "${LOCATION_ECOASSIST_FILES}/yolov5_versions/yolov5_new/yolov5"
git -C "${LOCATION_ECOASSIST_FILES}/yolov5_versions/yolov5_new/yolov5" checkout 3e55763d45f9c5f8217e4dad5ba1e6c1f42e3bf8
rm -rf "${LOCATION_ECOASSIST_FILES}/yolov5_versions/yolov5_new/yolov5/.git"
echo "yolov5 new version cloned"

git clone --branch pyside6 --depth 1 https://github.com/PetervanLunteren/Human-in-the-loop.git "${LOCATION_ECOASSIST_FILES}/Human-in-the-loop"
rm -rf "${LOCATION_ECOASSIST_FILES}/Human-in-the-loop/.git"
echo "Human-in-the-loop cloned"

git clone --depth 1 https://github.com/PetervanLunteren/visualise_detection.git "${LOCATION_ECOASSIST_FILES}/visualise_detection"
rm -rf "${LOCATION_ECOASSIST_FILES}/visualise_detection/.git"
echo "visualise_detection cloned"

# check if curl is installed
if command -v curl &> /dev/null
then
    echo "curl is already installed."
else
    echo "curl is not installed. Trying to installing curl..."
  { 
    sudo apt update
    sudo apt install -y curl
  } || { 
    echo "Curl could not be installed. Copy-paste all text in this console window and send it to peter@addaxdatascience.com for further support."; exit 1;
    }
  echo "curl successfuly installed."
fi

### download megadetector 
curl -L https://github.com/agentmorris/MegaDetector/releases/download/v5.0/md_v5a.0.0.pt -o "${LOCATION_ECOASSIST_FILES}/models/det/MegaDetector 5a/md_v5a.0.0.pt"

# install miniforge
curl --keepalive -L -o "${LOCATION_ECOASSIST_FILES}/Miniforge3.sh" "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash "${LOCATION_ECOASSIST_FILES}/Miniforge3.sh" -b -p "${LOCATION_ECOASSIST_FILES}/miniforge"
rm "${LOCATION_ECOASSIST_FILES}/Miniforge3.sh"

### source conda 
source "${LOCATION_ECOASSIST_FILES}/miniforge/etc/profile.d/conda.sh"
source "${LOCATION_ECOASSIST_FILES}/miniforge/bin/activate"
conda_exe="${LOCATION_ECOASSIST_FILES}/miniforge/bin/conda"

### install mamba
$conda_exe install mamba -n base -c conda-forge -y
conda_exe="${LOCATION_ECOASSIST_FILES}/miniforge/bin/mamba"

### install env-base
$conda_exe env create --file="${LOCATION_ECOASSIST_FILES}/cameratraps/envs/environment-detector.yml" -p "${CONDA_DIR}/envs/env-base" -y
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install RangeSlider
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install gpsphoto
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install exifread
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install piexif
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install openpyxl
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install customtkinter
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install CTkTable
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install folium
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install plotly
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install "gitpython>=3.1.30"
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install "tensorboard>=2.4.1"
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install "thop>=0.1.1"
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install "protobuf<=3.20.1"
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install "setuptools>=65.5.1"
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install PySide6
$conda_exe run -p "${CONDA_DIR}/envs/env-base" pip install "lxml==4.6.3"
"${CONDA_DIR}/envs/env-base/bin/pyside6-rcc" -o "${LOCATION_ECOASSIST_FILES}/Human-in-the-loop/libs/resources.py" "${LOCATION_ECOASSIST_FILES}/Human-in-the-loop/resources.qrc"

# requirements for Human-in-the-loop
echo "We need to install libxcb-cursor-dev (https://packages.debian.org/sid/libxcb-cursor-dev) and libxcb-cursor0 (https://packages.debian.org/sid/libxcb-cursor0). If you don't have root privileges you might be prompted for a password. Press CONTROL+D to skip authentication and not install these packages. EcoAssist will still work fine without it but you might have problems with the Human-in-the-loop software."
{ # first try without sudo
  add-apt-repository universe
  apt-get update
  apt-get install libxcb-cursor-dev
  apt-get install libxcb-cursor0
} || { # otherwise with sudo
  sudo add-apt-repository universe
  sudo apt-get update
  sudo apt-get install libxcb-cursor-dev
  sudo apt-get install libxcb-cursor0
  }

### install env-tensorflow
$conda_exe env create --file="${LOCATION_ECOASSIST_FILES}/EcoAssist/classification_utils/envs/tensorflow-linux-windows.yml" -p "${CONDA_DIR}/envs/env-tensorflow" -y

### install env-pytorch
$conda_exe create -p "${CONDA_DIR}/envs/env-pytorch" python=3.8 -y
$conda_exe run -p "${CONDA_DIR}/envs/env-pytorch" pip install torch==2.0.1 torchvision==0.15.2
$conda_exe run -p "${CONDA_DIR}/envs/env-pytorch" pip install "ultralytics==8.0.191"
$conda_exe run -p "${CONDA_DIR}/envs/env-pytorch" pip install "numpy==1.24.1"
$conda_exe run -p "${CONDA_DIR}/envs/env-pytorch" pip install "humanfriendly==10.0"
$conda_exe run -p "${CONDA_DIR}/envs/env-pytorch" pip install "jsonpickle==3.0.2"
$conda_exe run -p "${CONDA_DIR}/envs/env-pytorch" pip install timm
$conda_exe run -p "${CONDA_DIR}/envs/env-pytorch" pip install dill

### install env-pywildlife
$conda_exe create -p "${CONDA_DIR}/envs/env-pywildlife" python=3.8 -y
$conda_exe run -p "${CONDA_DIR}/envs/env-pywildlife" pip install pytorchwildlife
$conda_exe run -p "${CONDA_DIR}/envs/env-pywildlife" pip install "setuptools<70"
$conda_exe run -p "${CONDA_DIR}/envs/env-pywildlife" pip install jsonpickle

### clean
$conda_exe clean --all --yes --force-pkgs-dirs
$conda_exe clean --all --yes

# timestamp the end of installation
END_DATE=`date`
echo "This installation ended at: $END_DATE"

# message for the user
echo ""
echo "THE INSTALLATION IS DONE! You can close this window now and proceed to open EcoAssist by double clicking the shortcut on your desktop."
echo ""
