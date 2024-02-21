.PHONY: clean build default

default: clean build

clean:
	./Scripts/build/build_all.sh clean-all

build:
	./Scripts/build/build_all.sh
