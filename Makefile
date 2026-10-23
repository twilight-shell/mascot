PREFIX ?= /usr
QMLDIR ?= $(PREFIX)/lib/qt6/qml
DEST = $(DESTDIR)$(QMLDIR)/Twilight/Mascot

install:
	install -d $(DEST)
	cp -r Twilight/Mascot/. $(DEST)

uninstall:
	rm -rf $(DEST)

.PHONY: install uninstall
