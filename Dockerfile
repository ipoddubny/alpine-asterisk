FROM alpine:latest
MAINTAINER Ivan Poddubny <ivan.poddubny@gmail.com>
WORKDIR /root/

COPY src ./src

ENV ASTERISK_VERSION 15.2.0

RUN apk update \
  && apk add libtool libuuid jansson libxml2 sqlite-libs readline libcurl openssl zlib libsrtp lua5.1-libs spandsp \
  && apk add --virtual asterisk-build-deps build-base patch bsd-compat-headers util-linux-dev ncurses-dev libresample \
        jansson-dev libxml2-dev sqlite-dev readline-dev curl-dev openssl-dev \
        zlib-dev libsrtp-dev lua-dev spandsp-dev \
  && wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz \
  && tar xzf asterisk-${ASTERISK_VERSION}.tar.gz \
  && cd asterisk-${ASTERISK_VERSION} \
  && sed -i -e 's/ASTSSL_LIBS:=$(OPENSSL_LIB)/ASTSSL_LIBS:=-Wl,--no-as-needed $(OPENSSL_LIB) -Wl,--as-needed/g' main/Makefile \
  && patch -p1 < ../src/musl-mutex-init.patch \
  && ./configure --with-pjproject-bundled \
  && make menuselect.makeopts \
  && ./menuselect/menuselect \
    --disable BUILD_NATIVE \
    --disable-category MENUSELECT_CORE_SOUNDS \
    --disable-category MENUSELECT_MOH \
    --disable-category MENUSELECT_EXTRA_SOUNDS \
    --disable app_externalivr \
    --disable app_adsiprog \
    --disable app_alarmreceiver \
    --disable app_getcpeid \
    --disable app_minivm \
    --disable app_morsecode \
    --disable app_mp3 \
    --disable app_nbscat \
    --disable app_zapateller \
    --disable chan_mgcp \
    --disable chan_skinny \
    --disable chan_unistim \
    --disable codec_lpc10 \
    --disable pbx_dundi \
    --disable res_adsi \
    --disable res_smdi \
    menuselect.makeopts \
  && make -j2 ASTCFLAGS="-Os -fomit-frame-pointer" ASTLDFLAGS="-Wl,--as-needed" \
  && scanelf --recursive --nobanner --osabi --etype "ET_DYN,ET_EXEC" . \
    | while read type osabi filename ; do \
      [ "$osabi" != "STANDALONE" ] || continue ; \
      strip "${filename}" ; \
    done \
  && make install \
  && cd .. \
  && apk del asterisk-build-deps \
  && rm -rf ./asterisk* \
  && rm -rf src \
  && rm -rf /var/cache/apk/*
