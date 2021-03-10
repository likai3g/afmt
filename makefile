PROJECT=afmt
all:
	alr build

install:
	alr build
	gprinstall -p -P$(PROJECT)

reinstall:
	gprinstall --uninstall -P$(PROJECT)
	alr build
	gprinstall -p -P$(PROJECT)

