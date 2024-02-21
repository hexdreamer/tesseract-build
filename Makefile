.PHONY: clean build all

all: clean build

clean:
	./Scripts/build/build_all.sh clean-all

build:
	./Scripts/build/build_all.sh
