FROM oraclelinux:7-slim
MAINTAINER heyangguo@emotibot.com

ARG PACKAGE_URL=https://repo.mysql.com/yum/mysql-5.7-community/docker/x86_64/mysql-community-server-minimal-5.7.22-1.el7.x86_64.rpm
ARG PACKAGE_URL_SHELL=https://repo.mysql.com/yum/mysql-tools-community/el/7/x86_64/mysql-shell-1.0.11-1.el7.x86_64.rpm

# Install server
RUN rpmkeys --import https://repo.mysql.com/RPM-GPG-KEY-mysql \
  && yum install -y $PACKAGE_URL $PACKAGE_URL_SHELL libpwquality \
  && yum clean all \
  && mkdir /docker-entrypoint-initdb.d

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# 生成容器共享目录 ， 其他容器可以挂载此目录，参数： --volumes-from 容器[name or id]
VOLUME /var/lib/mysql
COPY mgrinit.sh /
COPY sed.sh /

#RUN echo abc
COPY docker-entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
ENTRYPOINT ["/entrypoint.sh"]
# 健康自检查，example ,容器启动10s后开始检查，脚本未返回数值超时时间为5s，重试3次
# HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD /healthcheck.sh
HEALTHCHECK CMD /healthcheck.sh
COPY vim-minimal-7.4.160-4.el7.x86_64.rpm /tmp/vim-minimal-7.4.160-4.el7.x86_64.rpm
RUN rpm -ih /tmp/vim-minimal-7.4.160-4.el7.x86_64.rpm
COPY my.cnf /etc/my.cnf
EXPOSE 3306 33060
CMD ["mysqld"]
