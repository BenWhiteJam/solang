FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y libz-dev pkg-config libssl-dev git cmake ninja-build gcc g++ python

RUN git clone git://github.com/llvm/llvm-project

WORKDIR /llvm-project

RUN git checkout -b release_8.x origin/release/8.x

RUN sed -i '7 a #include <string>' llvm/include/llvm/Demangle/MicrosoftDemangleNodes.h

RUN cmake -G Ninja -DLLVM_ENABLE_ASSERTIONS=On -DLLVM_ENABLE_PROJECTS=clang  \
    -DLLVM_ENABLE_TERMINFO=Off -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DCMAKE_INSTALL_PREFIX=/llvm80 -B build llvm

RUN cmake --build build --target install

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y libz-dev pkg-config libssl-dev git cargo libffi-dev libstdc++-9-dev curl
RUN apt-get clean
RUN apt-get autoclean

COPY --from=builder /llvm80 /llvm80/

ENV PATH="/llvm80/bin:${PATH}"