PCRE_SRC = pcre-8.36
ZLIB_SRC = zlib-1.2.8
LUA_SRC = lua-5.1.5
OPENSSL_SRC = openssl-1.0.1j
LIGHTTPD_SRC = lighttpd-1.4.35

KERNEL_BITS=64
SUBDIR = $(PCRE_SRC) $(ZLIB_SRC) $(LUA_SRC) $(LIGHTTPD_SRC)
CURDIR = $(PWD)

TAR = tar xvf
UNZIP = unzip

depend:
	$(TAR) $(OPENSSL_SRC).tar.gz
	(cd $(OPENSSL_SRC) && export KERNEL_BITS=64 && ./config --prefix=$(CURDIR)/openssl no-sse2 no-asm && make all && make install)
	$(TAR) $(LUA_SRC).tar.gz
	(cd $(LUA_SRC) && make macosx && make install INSTALL_TOP=$(CURDIR)/lua)
	$(TAR) $(ZLIB_SRC).tar.gz
	(cd $(ZLIB_SRC) && ./configure && make)
	$(TAR) $(PCRE_SRC).tar.gz
	(cd $(PCRE_SRC) && ./configure --prefix=$(CURDIR)/pcre && make && make install)
	
all:
	(cd $(LIGHTTPD_SRC) && ./configure --prefix="$(CURDIR)/lighttpd" \
		--with-lua LUA_CFLAGS="-I$(CURDIR)/lua/include" LUA_LIBS="$(CURDIR)/lua/lib/liblua.a"  \
		--with-pcre PCRECONFIG="$(CURDIR)/pcre/bin/pcre-config" \
		--with-openssl="$(CURDIR)/openssl" )

install:
	(cd $(LIGHTTPD_SRC) && make install)

clean:
	for dir in $(SUBDIR); do make -C $$dir clean || exit 1; done
