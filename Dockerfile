FROM centos:7 as builder

ENV LOG_LVL 0
ENV API_SECRET "mysecret"
ENV STUNSERVER "stun.l.google.com:19302"

RUN yum -y install --disableplugin=ovl epel-release

RUN yum -y update

RUN yum -y install wget yum-utils install jansson-devel \
		openssl openssl-devel sofia-sip-devel glib2-devel texinfo sngrep jq \
		openssh-server opus-devel libogg-devel libcurl-devel pkgconfig gengetopt \
		openssh-clients libconfig-devel libtool autoconf automake Gettext \
		cmake python3 python3-pip which git doxygen graphviz file \
	&& yum clean all

COPY ./sofia.tar.gz /usr/src

RUN pip3 install meson \
        && pip3 install ninja

RUN cd /usr/src \
        && git clone https://git.gnunet.org/libmicrohttpd.git \
        && cd libmicrohttpd \
        && ./autogen.sh \
        && ./configure --prefix=/usr --libdir=/usr/lib64 \
        && make \
        && make install

RUN cd /usr/src \
        && wget https://libnice.freedesktop.org/releases/libnice-0.1.18.tar.gz \
        && tar xvzf libnice-0.1.18.tar.gz \
        && cd libnice-0.1.18    \
        && meson --prefix=/usr build  \
        && ninja -C build  \
        && ninja -C build install

RUN cd /usr/src \
        && wget https://github.com/cisco/libsrtp/archive/v2.3.0.tar.gz \
        && tar xfv v2.3.0.tar.gz \
        && cd libsrtp-2.3.0 \
        && ./configure --prefix=/usr --enable-openssl --libdir=/usr/lib64 \
        && make shared_library \
        && make install

RUN cd /usr/src \
        && git clone https://github.com/sctplab/usrsctp \
        && cd usrsctp \
        && ./bootstrap \
        && ./configure --prefix=/usr --libdir=/usr/lib64 --disable-programs --disable-inet --disable-inet6 \
        && make && make install

RUN cd /usr/src \
        && git clone https://libwebsockets.org/repo/libwebsockets \
        && cd libwebsockets \
        && git checkout v3.2-stable \
        && mkdir build \
        && cd build \
        && cmake --libdir=/usr/lib64 -DLIB_SUFFIX=64 -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
        && make && make install

RUN cd /usr/src \
        && tar xvzf sofia.tar.gz \
        && cd sofia-sip-1.12.11 \
	#&& sh autogen.sh \
        && ./configure --prefix=/usr --libdir=/usr/lib64 \
        && make \
        && make install

RUN cd /usr/src  \
        && git clone https://github.com/meetecho/janus-gateway.git \
        && cd janus-gateway \
        && sh autogen.sh \
        && ./configure --prefix=/usr --libdir=/usr/lib64 --sysconfdir=/etc --enable-rest \
        && make && make install && make configs

RUN cd /usr/src/ \
        && rm -rf janus-gateway sofia-sip-1.12.11 libwebsockets usrsctp libsrtp-2.3.0 libnice-0.1.18.tar.gz libmicrohttpd

RUN yum -y remove python3 python3-pip cmake bind-license kernel-headers

COPY ./config/* /etc/janus/

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD /usr/bin/janus

