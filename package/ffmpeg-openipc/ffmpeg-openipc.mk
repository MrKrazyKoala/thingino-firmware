################################################################################
#
# ffmpeg-openipc | updated 2022.08.10
# --disable-everything \
################################################################################

FFMPEG_OPENIPC_VERSION = 4.4.2
FFMPEG_OPENIPC_SOURCE = ffmpeg-$(FFMPEG_OPENIPC_VERSION).tar.xz
FFMPEG_OPENIPC_SITE = http://ffmpeg.org/releases

FFMPEG_OPENIPC_INSTALL_STAGING = NO

FFMPEG_OPENIPC_LICENSE = LGPL-2.1+, libjpeg license
FFMPEG_OPENIPC_LICENSE_FILES = LICENSE.md COPYING.LGPLv2.1

FFMPEG_OPENIPC_CONF_OPTS = \
	--prefix=/usr \
	  --enable-cross-compile \
  --enable-small \
  --disable-everything \
  --enable-gpl \
  --enable-version3 \
  --enable-ffmpeg \
  --enable-avformat \
  --enable-avcodec \
  --enable-parser=h264 \
  --enable-demuxer=mov \
  --enable-demuxer=mp4 \
  --enable-muxer=mp4 \
  --enable-decoder=h264 \
  --enable-protocol='file,tcp' \
  --enable-swscale \
  --enable-swresample \
  --enable-demuxer=rawvideo \
  --enable-muxer=rawvideo \
  --enable-encoder=rawvideo \
  --enable-decoder=rawvideo \
  --enable-pthreads \
  --enable-swscale \
  --enable-swresample \
  --extra-cflags="-Os"


FFMPEG_OPENIPC_DEPENDENCIES += host-pkgconf

# Default to --cpu=generic for MIPS architecture, in order to avoid a
# warning from ffmpeg's configure script.
ifeq ($(BR2_mips)$(BR2_mipsel)$(BR2_mips64)$(BR2_mips64el),y)
FFMPEG_OPENIPC_CONF_OPTS += --cpu=generic
else ifneq ($(GCC_TARGET_CPU),)
FFMPEG_OPENIPC_CONF_OPTS += --cpu="$(GCC_TARGET_CPU)"
else ifneq ($(GCC_TARGET_ARCH),)
FFMPEG_OPENIPC_CONF_OPTS += --cpu="$(GCC_TARGET_ARCH)"
endif

FFMPEG_OPENIPC_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_TOOLCHAIN_HAS_GCC_BUG_85180),y)
FFMPEG_OPENIPC_CONF_OPTS += --disable-optimizations
FFMPEG_OPENIPC_CFLAGS += -O0
endif

FFMPEG_OPENIPC_CONF_ENV += CFLAGS="$(FFMPEG_OPENIPC_CFLAGS)"

# Override FFMPEG_OPENIPC_CONFIGURE_CMDS: FFmpeg does not support --target and others
define FFMPEG_OPENIPC_CONFIGURE_CMDS
	(cd $(FFMPEG_OPENIPC_SRCDIR) && rm -rf config.cache && \
	$(TARGET_CONFIGURE_OPTS) \
	$(TARGET_CONFIGURE_ARGS) \
	$(FFMPEG_OPENIPC_CONF_ENV) \
	./configure \
		--enable-cross-compile \
		--cross-prefix=$(TARGET_CROSS) \
		--sysroot=$(STAGING_DIR) \
		--host-cc="$(HOSTCC)" \
		--arch=$(BR2_ARCH) \
		--target-os="linux" \
		--pkg-config="$(PKG_CONFIG_HOST_BINARY)" \
		$(FFMPEG_OPENIPC_CONF_OPTS) \
	)
endef

define FFMPEG_OPENIPC_REMOVE_EXAMPLE_SRC_FILES
	rm -rf $(TARGET_DIR)/usr/share/ffmpeg/examples
endef
FFMPEG_OPENIPC_POST_INSTALL_TARGET_HOOKS += FFMPEG_OPENIPC_REMOVE_EXAMPLE_SRC_FILES

$(eval $(autotools-package))
