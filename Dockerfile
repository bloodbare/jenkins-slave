FROM jenkins/jnlp-slave

USER root

COPY requirements.txt /

RUN apt-get update -y \
    && apt-get install -y apt-transport-https \
    && echo "deb https://packages.cloud.google.com/apt cloud-sdk-jessie main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && curl -sL https://deb.nodesource.com/setup_11.x | bash - \
    && apt-get update \
    && apt-get install -y \
        google-cloud-sdk \
        xdg-utils libxss1 \
        fonts-liberation \
        libappindicator3-1 \
        openjfx \
        jq \
        golang \
        libssl-dev \
        python-openssl \
        jmeter python3 \
        python3-pip \
        python-dev \
        libffi-dev \
        build-essential \
        golang \
        maven \
        python-requests \
        python-pip \
        sudo \
        nodejs \
        kubectl\
    && npm install -g newman \
    && chown -R jenkins /home/jenkins \
    && addgroup --gid 412 docker \
    && adduser jenkins docker \
    && apt-get install -y -f \
    && rm -rf /var/lib/apt/lists/*


RUN curl -L https://github.com/docker/compose/releases/download/1.23.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose


RUN pip3 install -r /requirements.txt


RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` \
    && wget https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip \
    && unzip chromedriver_linux64.zip -d /usr/bin \
    && chmod +x /usr/bin/chromedriver \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb chromedriver_linux64.zip


RUN curl https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz -o /tmp/helm.tgz \
    && tar -zxvf /tmp/helm.tgz -C /tmp/ \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && su - jenkins -c "helm init --client-only"

RUN curl https://downloads.gradle.org/distributions/gradle-4.1-bin.zip -o /tmp/gradle.zip \
    && unzip /tmp/gradle.zip -d /opt/gradle \
    && ln -s /opt/gradle/gradle-4.1/bin/gradle /usr/bin/gradle \
    && curl http://download-keycdn.ej-technologies.com/install4j/install4j_linux_6_1_6.deb -o /tmp/install4j.deb \
    && dpkg -i /tmp/install4j.deb \
    && rm /tmp/install4j.deb /tmp/gradle.zip


RUN curl -L "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v1.4.3/docker-credential-gcr_linux_amd64-1.4.3.tar.gz" \
  | tar xz --to-stdout docker-credential-gcr \
  > /usr/bin/docker-credential-gcr && chmod +x /usr/bin/docker-credential-gcr

RUN curl -L https://storage.googleapis.com/minikube/releases/v0.25.2/minikube-linux-amd64 -o /usr/local/bin/minikube && chmod +x /usr/local/bin/minikube 

COPY sudoers /etc/

USER jenkins
