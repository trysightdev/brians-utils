# Build guvcview on raspberry pi 5 - bookworm - arm64
```bash
# Clone the repository
git clone https://git.code.sf.net/p/guvcview/git-master guvcview-git-master
cd guvcview-git-master/

# Install necessary tools and libraries
sudo apt-get update
sudo apt-get install autoconf automake libtool gettext intltool -y
sudo apt-get install libv4l-dev libudev-dev libusb-1.0-0-dev libavcodec-dev libavutil-dev libpng-dev libsdl2-dev libgsl-dev qtbase5-dev -y
sudo apt install build-essential portaudio19-dev -y

# Prepare for building
./bootstrap.sh
./configure --disable-gtk3 --enable-qt5

# Compile and install
make
sudo make install

# Update library paths
sudo ldconfig

# Optionally, verify installation by running guvcview
guvcview

```
