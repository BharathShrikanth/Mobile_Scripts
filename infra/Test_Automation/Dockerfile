# Android Test Automation Image

FROM ubuntu:16.04

# System update
RUN apt-get update
RUN apt install -y openjdk-8-jdk
RUN apt install -y ruby 2.3.1
RUN apt-get -fy install curl ruby-dev make xvfb ruby-dev make curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev python-tk xvfb xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic imagemagick libxml2-dev libxslt-dev libcurl4-openssl-dev libreadline6-dev libssl-dev patch build-essential zlib1g-dev openssh-server libyaml-dev libicu-dev libmysqlclient-dev libidn11-dev x11vnc libdbus-glib-1-2

# Installing Firefox - Version 25.0.1 
RUN mkdir -p /home/Softwares \
    && cd /home/Softwares \
    && wget https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/25.0.1/linux-x86_64/en-US/firefox-25.0.1.tar.bz2 \
    && tar xvfj firefox-25.0.1.tar.bz2
ENV PATH /home/Softwares/firefox:$PATH

# Installing and Setting up display for headless browser tests
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --force-yes expect git wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl

RUN Xvfb :99 -ac &
ENV DISPLAY :99
ENV PATH $DISPLAY:$PATH

# Installing Android SDK and build tools 
RUN cd /opt && wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz \
        && tar xzf android-sdk.tgz

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH $ANDROID_HOME/build-tools/21.0.1:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

RUN echo y | android update sdk --all --force --no-ui --filter platform-tools,build-tools-21,build-tools-21.0.1,build-tools-21.0.2,build-tools-21.1,build-tools-21.1.1,build-tools-21.1.2,build-tools-22,build-tools-22.0.1,android-21,android-22,addon-google_apis_x86-google-21,extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services
