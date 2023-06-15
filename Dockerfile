FROM amazonlinux:2

RUN yum install -y tar gzip zip unzip jq yum-utils && \
  yum clean all && \
  rm -rf /var/cache/yum /var/lib/yum/history

RUN mkdir -p /lambda && \
  curl https://lambci.s3.amazonaws.com/fs/base-2.tgz | tar -xz -C /lambda && \
  echo 'installroot=/lambda' >> /etc/yum.conf && \
  yum reinstall -y filesystem && \
  yum clean all && \
  rm -rf /lambda/var/cache/yum /lambda/var/lib/yum/history

COPY lambda2.repo /lambda/etc/yum.repos.d/
COPY RPM-GPG-KEY-lambci /etc/pki/rpm-gpg/
RUN rpm --root /lambda --import /etc/pki/rpm-gpg/RPM-GPG-KEY-lambci

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

COPY ./make_zip.sh .

ENTRYPOINT ["sh", "make_zip.sh"]

