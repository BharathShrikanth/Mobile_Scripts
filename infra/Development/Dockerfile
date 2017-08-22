# Android Development Image

FROM ubuntu:14.10

RUN apt-get update

# Download specific Android Studio bundle (all packages).
RUN apt-get install -y curl unzip
RUN curl 'https://dl.google.com/dl/android/studio/ide-zips/2.3.3.0/android-studio-ide-162.4069837-linux.zip' > /tmp/studio.zip && unzip -d /opt /tmp/studio.zip && rm /tmp/studio.zip

# Install X11
RUN apt-get install -y x11-apps

# Install prerequisites
RUN apt-get install -y openjdk-7-jdk git vim ant lib32z1 lib32ncurses5 lib32bz2-1.0 lib32stdc++6

# Clean up
RUN apt-get clean
RUN apt-get purge

# Set up permissions for X11 access.
# Replace 1000 with your user / group id.
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

# Set up USB device debugging (device is ID in the rules files)
ADD 51-android.rules /etc/udev/rules.d
RUN chmod a+r /etc/udev/rules.d/51-android.rules

USER developer
ENV HOME /home/developer
CMD /opt/android-studio/bin/studio.sh