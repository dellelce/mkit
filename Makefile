
BASE := base

help:
	@echo No help at the moment

build-base:
	@rm -rf tmp/base && mkdir tmp/base && cp -rp modules mkit*.sh tmp/base && \
	 cp Dockerfile.base tmp/base/Dockerfile && \
	 cd tmp/base && docker build -t $(BASE) . && rm -rf tmp/base
