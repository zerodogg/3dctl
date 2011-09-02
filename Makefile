# 3dctl makefile

VERSION=$(shell ./3dctl --version|perl -pi -e 's/^\S+\D+//; chomp')

ifndef prefix
# This little trick ensures that make install will succeed both for a local
# user and for root. It will also succeed for distro installs as long as
# prefix is set by the builder.
prefix=$(shell perl -e 'if($$< == 0 or $$> == 0) { print "/usr" } else { print "$$ENV{HOME}/.local"}')

# Some additional magic here, what it does is set BINDIR to ~/bin IF we're not
# root AND ~/bin exists, if either of these checks fail, then it falls back to
# the standard $(prefix)/bin. This is also inside ifndef prefix, so if a
# prefix is supplied (for instance meaning this is a packaging), we won't run
# this at all
BINDIR ?= $(shell perl -e 'if(($$< > 0 && $$> > 0) and -e "$$ENV{HOME}/bin") { print "$$ENV{HOME}/bin";exit; } else { print "$(prefix)/bin"}')
endif

BINDIR ?= $(prefix)/bin
DATADIR ?= $(prefix)/share

DISTFILES = COPYING 3dctl INSTALL Makefile NEWS README TODO 3dctl.1

# Install 3dctl
install:
	mkdir -p "$(BINDIR)"
	cp 3dctl "$(BINDIR)"
	chmod 755 "$(BINDIR)/3dctl"
	[ -e 3dctl.1 ] && mkdir -p "$(DATADIR)/man/man1" && cp 3dctl.1 "$(DATADIR)/man/man1" || true
localinstall:
	mkdir -p "$(BINDIR)"
	ln -sf $(shell pwd)/3dctl $(BINDIR)/
	[ -e 3dctl.1 ] && mkdir -p "$(DATADIR)/man/man1" && ln -sf $(shell pwd)/3dctl.1 "$(DATADIR)/man/man1" || true
# Uninstall an installed 3dctl
uninstall:
	rm -f "$(BINDIR)/3dctl" "$(BINDIR)/gpconf" "$(DATADIR)/man/man1/3dctl.1"
	rm -rf "$(DATADIR)/3dctl"
# Clean up the tree
clean:
	rm -f `find|egrep '~$$'`
	rm -f 3dctl-*.tar.bz2
	rm -rf 3dctl-$(VERSION)
	rm -f 3dctl.1
# Create a manpage from the POD
man:
	pod2man --name "3dctl" --center "" --release "3dctl $(VERSION)" ./3dctl.pod ./3dctl.1
# Create the tarball
distrib: clean man
	mkdir -p 3dctl-$(VERSION)
	cp $(DISTFILES) ./3dctl-$(VERSION)
	tar -jcvf 3dctl-$(VERSION).tar.bz2 ./3dctl-$(VERSION)
	rm -rf 3dctl-$(VERSION)
	rm -f 3dctl.1
