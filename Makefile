
.ONESHELL:

################
# Load modules #
################
load_modules_lighthouse:
	module load tmux/3.3a
	module load python3.9-anaconda/2021.11
	module load R/4.2.0
	module load Rgeospatial/4.2.0-2022-08-18
	module load cuda/11.6.2
	module load cudnn/11.6-v8.4.1
	module save


###############################
# Set up directory structures #
###############################

opt_directories:
	mkdir -p ${HOME}/opt
	mkdir -p ${HOME}/opt/bin
	echo "Set up paths to install programs in the ${HOME}/opt"
	echo "" >> ${HOME}/.bash_profile
	echo "# env_bootstrap updated variables:" >> ${HOME}/.bash_profile
	echo "# See https://github.com/maomlab/env_bootsrap" >> ${HOME}/.bash_profile
	echo "export PATH=${HOME}/opt/bin:${HOME}/.local/bin:${HOME}/bin:${PATH}" >> ${HOME}/.bash_profile
	echo "export LIBDIR=${HOME}/opt/lib" >> ${HOME}/.bash_profile
	echo "export LD_LIBRARY_PATH=${HOME}/opt/:${HOME}/lib64:$LD_LIBRARY_PATH" >> ${HOME}/.bash_profile

####################
# Networking tools #
####################

# GIT Requires ssh > 7.2
# https://github.blog/2021-09-01-improving-git-protocol-security-github/
# check with ssh -V
openssh:
	cd ${HOME}/opt
	wget openssh-9.1p1.tar.gz
	tar xzvf openssh-9.1p.tar.gz
	rm -rf openssh-9.1p.tar.gz
	cd openssh-9.1p
	./configure --prefix=${HOME}/opt
	make -j10; make install
	cd ${HOME}/opt

${HOME}/.ssh/id_rsa_maomlab.pub:
	ssh-keygen -t ed25519 -f ${HOME}/.ssh/id_rsa_maomlab -q -N ""

${HOME}/.ssh/id_rsa_momeara.pub:
	ssh-keygen -t ed25519 -f ${HOME}/.ssh/id_rsa_momeara -q -N ""

${HOME}/.ssh/id_ed25519.pub:
	ssh-keygen -t ed25519 -f ${HOME}/.ssh -q -N ""

github_register_sshkeys: ${HOME}/.ssh/id_rsa_maomlab
	@echo "Login as maomlab to github and pload this key:\n"
	@cat ${HOME}/.ssh/id_rsa_maomlab
	@echo "https://github.com/settings/ssh/new"

# setup ssh routing for multiple acounts
${HOME}/.ssh/config:
	cp .ssh/config ${HOME}/.ssh/config

#######################
# Install build tools #
#######################

# Autoconf is linux framework for installing software using 'make'
${HOME}/opt/bin/make:
	cd ${HOME}/opt
	curl -O -L https://ftp.gnu.org/gnu/m4/m4-latest.tar.gz
	tar -xzvf m4-latest.tar.gz
	rm -rf m4-latest.tar.gz
	cd m4-*
	./configure --prefix=${HOME}/opt
	make -j10; make install 
	cd ${HOME}/opt
	curl -O  -L https://ftp.gnu.org/gnu/autoconf/autoconf-latest.tar.gz
	tar -xzvf autoconf-latest.tar.gz 
	rm -rf autoconf-latest.tar.gz
	cd autoconf-*
	./configure --prefix=${HOME}/opt
	make -j10; make install
	cd ${HOME}/opt
	curl -O  -L https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.gz
	tar -xzvf automake-1.16.5.tar.gz
	rm -rf automake-1.16.5.tar.gz
	cd automake-1.16.5
	./configure --prefix=$HOME/opt
	make -j10; make install


# cmake is like make but is fancier
${HOME}/opt/bin/cmake:
	cd ${HOME}/opt
	curl -O  -L https://github.com/Kitware/CMake/releases/download/v3.24.3/cmake-3.24.3.tar.gz
	tar -xzvf cmake-3.24.3.tar.gz 
	rm -rf cmake-3.24.3.tar.gz
	cd cmake-3.24.3
	./configure --prefix=${HOME}/opt
	make -j4; make install

###########################
# Install linux CLI tools #
###########################

# ncurses is a library for manipulating text in the terminal used e.g. by htop
# http://www.linuxfromscratch.org/lfs/view/development/chapter06/ncurses.html
${HOME}/opt/bin/ncurses:
	cd ${HOME}/opt
	curl -O  -L https://ftp.gnu.org/gnu/ncurses/ncurses-6.2.tar.gz
	tar -xzvf ncurses-6.2.tar.gz
	rm -rf ncurses-6.2.tar.gz
	cd ncurses-6.2
	./configure --prefix=${HOME}/opt --with-shared --without-ada --without-normal --with-termlib
	make -j10
	make install
	./configure --prefix=${HOME}/opt --enable-widec --with-shared --without-ada --without-normal --with-termlib
	make -j10
	make install

# htop is a good tool for monitoring cpu/memory etc resource utilization
${HOME}/opt/bin/htop: ${HOME}/opt/bin/ncurses
	cd ${HOME}/opt
	git clone https://github.com/htop-dev/htop
	cd htop
	./autogen.sh
	./configure --prefix=${HOME}/opt/
	make -j10
	make install

#libevent
install_libevent:
	cd ${HOME}/opt
	curl -O -L https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
	tar xzvf libevent-2.1.12-stable.tar.gz
	rm libevent-2.1.12-stable.tar.gz
	cd libevent-2.1.12-stable
	./configure --prefix=${HOME}/opt
	make -j10
	make install

# needs libevent?
${HOME}/opt/bin/tmux:
	cd ${HOME}/opt
	curl -O -L https://github.com/tmux/tmux/releases/download/3.1b/tmux-3.1b.tar.gz
	tar xzvf tmux-3.1b.tar.gz
	rm tmux-3.1b.tar.gz
	cd tmux-3.1b
	PKG_CONFIG_PATH=${HOME}/opt/lib/pkgconfig ./configure --prefix=$HOME/opt
	make -j10
	make install

install_jansson:
	cd ${HOME}/opt
	curl -O -L https://digip.org/jansson/releases/jansson-2.13.1.tar.gz
	tar -xzvf jansson-2.13.1.tar.gz
	rm -rf jansson-2.13.1.tar.gz
	cd jansson-2.13.1
	./configure --prefix=${HOME}/opt
	make
	make install

# depends on jansson?
${HOME}/opt/bin/emacs:
	cd ${HOME}/opt
	curl -O -L http://ftp.wayne.edu/gnu/emacs/emacs-28.2.tar.gz
	tar xzvf emacs-28.2.tar.gz
	rm -rf emacs-28.2.gz
	cd emacs-28.2
	./configure --prefix=${HOME}/opt --with-gif=ifavailable --with-x-toolkit=no --with-xpm=ifavailable --with-gnutls=ifavailable --without-rsvg --without-jpeg --with-tiff=ifavailable
	make -j10
	make install

setup_emacs:
	mkdir -p ${HOME}/.emacs.d
	ln -s $(pwd)/.emacs.d/* ${HOME}/.emacs.d/
	emacs --script ${HOME}/.emacs.d/install.el




############################
# Setup python environment #
############################

# module load python3.7-anaconda # better to just use miniconda, so the conda package resolve is faster
${HOME}/opt/bin/conda:
	cd ${HOME}/opt
	curl -O  -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
	bash Miniconda3-latest-Linux-x86_64.sh -b -p ${HOME}/opt/miniconda3
	rm -rf Miniconda3-latest-Linux-x86_64.sh
	source ${HOME}/.bash_profile
	echo "Using this conda: $(which conda) should be ${HOME}/opt/miniconda3/bin/cond"
	conda update conda --all

${HOME}/opt/bin/mamba:
	conda install mamba -n base -c conda-forge

create_main_python_env:
	module restore
	conda create --name main --yes
	conda init

# Setup accessing virtualenv from greatlakes jupyter notebook
# Start jupyter notebook from the OnDemand portal
# From jupyter notebook select Kernel → Change kernel → main
setup_jupyter:
	/sw/arcts/centos7/python3.7-anaconda/2019.07/bin/pip install --user ipykernel
	/sw/arcts/centos7/python3.7-anaconda/2019.07/bin/python -m ipykernel install --user --name=main


install_pytorch:
	conda activate main
	conda install pytorch torchvision cudatoolkit=10.1 -c pytorch

#Login to GPU node interactively
check_pytorch_gpu:
	echo $(nvidia-smi)
	echo $(nvcc --version)
	python -c "import torch; \
	torch.cuda.is_available(); \
	torch.version.cuda; \
	torch.backends.cudnn.enabled; \
	torch._C._cuda_isDriverSufficient(); \
	torch.cuda.device_count(); \
	torch.cuda._check_driver(); \
	torch.cuda.get_device_name(0)"


#######################################
# Install molecular modeling software #
#######################################

# rosetta is software for protein structure prediction and design
install_rosetta:
	mkdir -p ${HOME}/opt/rosetta 
	cd ${HOME}/opt/rosetta
	git clone --recurse-submodules git@github.com:RosettaCommons/main.git
	cd main
	./scons.py rosetta_scripts mode=release
	./scons.py rosetta_scripts mode=release -j10





.PHONY: opt_directories install_autoconf install_cmake setup_emacs install_rosetta

