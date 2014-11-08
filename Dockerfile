FROM centos:centos6
MAINTAINER tacahilo

RUN yum -y groupinstall "Development Tools"
RUN yum -y install bison
RUN yum -y install openssl-devel
RUN yum -y install pcre-devel
RUN yum -y install tar
RUN yum -y install wget
RUN yum -y install zlib-devel

RUN rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi
RUN rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
RUN yum -y install --enablerepo=remi libmemcached-last-devel

RUN yum -y install rubygem-rake
RUN gem update rake

WORKDIR /usr/local/src
RUN git clone https://github.com/sstephenson/ruby-build.git
RUN git clone --recursive https://github.com/matsumoto-r/ngx_mruby.git
RUN git clone https://github.com/nginx/nginx.git

WORKDIR /usr/local/src/ruby-build
RUN sh install.sh
RUN ruby-build 2.1.4 /usr/local/ruby-2.1.4
ENV PATH /usr/local/ruby-2.1.4/bin:$PATH

WORKDIR /usr/local/src/ngx_mruby
RUN perl -i -pe 's/(conf.gem.+mruby-redis)/#$1/' build_config.rb
RUN perl -i -pe 's/(conf.gem.+mruby-vedis)/#$1/' build_config.rb
RUN perl -i -pe 's/#(conf.gem.+mruby-memcached)/$1/' build_config.rb
ENV NGINX_SRC_ENV /usr/local/src/nginx
ENV NGINX_CONFIG_OPT_ENV --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' --add-module=/usr/local/src/ngx_mruby --add-module=/usr/local/src/ngx_mruby/dependence/ngx_devel_kit
RUN sh build.sh

# WORKDIR /usr/local/src/nginx
# RUN ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' --add-module=/usr/local/src/ngx_mruby --add-module=/usr/local/src/ngx_mruby/dependence/ngx_devel_kit
# RUN make
