FROM ubuntu:20.04

LABEL maintainer "hosein1398@gmail.com"


ENV SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip" \
    ANDROID_HOME="/usr/local/android-sdk" \
    ANDROID_VERSION=30 \
    ANDROID_BUILD_TOOLS_VERSION=30.0.2 \
    TZ=Europe/Kiev
 
#config timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt install -y python3-pip python3-dev ssh python3-boto3
RUN pip3  install ansible==2.4.3.0

# install dependencies   
RUN apt-get update \
    && yes | apt-get install --no-install-recommends openjdk-8-jdk \
    && yes | apt-get install --no-install-recommends unzip \ 
    && yes | apt-get install --no-install-recommends curl \
    && curl -o gradle.zip "https://downloads.gradle-dn.com/distributions/gradle-7.0.2-bin.zip" \
    && curl "http://www.nano-editor.org/dist/v2.4/nano-2.4.2.tar.gz" > nano-2.4.2.tar.gz \
    && mkdir /opt/gradle \
    && unzip -d /opt/gradle gradle.zip \
    && rm gradle.zip \
    && rm -rf /var/lib/apt/lists/*



# setups
RUN mkdir "$ANDROID_HOME" .android \
    && mkdir "$ANDROID_HOME/cmdline-tools" \
    && cd "$ANDROID_HOME/cmdline-tools" \
    && curl -o sdk.zip $SDK_URL \
    && unzip sdk.zip \
    && rm sdk.zip \
    && mv "cmdline-tools" "latest" \
    && $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    && yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses \ 
    && $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --update \
    && $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools"
    
# setup ENV's
ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre" 
ENV GRADLE_USER_HOME="/opt/gradle/gradle-7.0.2"
ENV PATH=$PATH:"$GRADLE_USER_HOME/bin"

RUN apt-get clean