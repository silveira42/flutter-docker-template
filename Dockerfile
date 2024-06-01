FROM ubuntu:20.04

RUN echo 'root:Docker!' | chpasswd

RUN apt update

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Sao_Paulo apt-get -y install tzdata

# Prerequisites
RUN apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget clang cmake ninja-build pkg-config libgtk-3-dev

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Prepare Android directories and system variables
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;29.0.2" "platform-tools" "platforms;android-29" "sources;android-29" "cmdline-tools;latest"
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"

# We need java 8 to run the ./skdmanager --licenses command, but to run flutter
# we need java 11. Deal with it. Cuz I gave up.
USER root
RUN apt install -y openjdk-11-jdk
USER developer

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/developer/flutter/bin"

# Run basic check to download Dark SDK
RUN flutter doctor

# flutter create <project>
# cd <project>
# flutter run