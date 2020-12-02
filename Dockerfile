FROM ubuntu:18.04

# Prerequisites
RUN apt-get -y update && apt-get -y install curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget

ENV USER developer
ENV HOME_DIR /home/${USER}
ENV WORKSPACE_DIR ${HOME_DIR}/code

# Set up new user
RUN useradd -ms /bin/bash ${USER}
USER ${USER}
WORKDIR ${HOME_DIR}

# Prepare Android directories and system variables
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT ${HOME_DIR}/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;29.0.2" "patcher;v4" "platform-tools" "platforms;android-29" "sources;android-29"
ENV PATH $PATH:${HOME_DIR}/Android/sdk/platform-tools

# Download Flutter SDK
RUN git clone --branch 1.22.4 https://github.com/flutter/flutter.git
ENV PATH $PATH:${HOME_DIR}/flutter/bin

RUN flutter channel beta \
  && flutter upgrade \
  && flutter config --enable-web

RUN mkdir -p ${WORKSPACE_DIR}
WORKDIR ${WORKSPACE_DIR}

# Run basic check to download Dark SDK
RUN flutter doctor
