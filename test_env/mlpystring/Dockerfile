FROM ocaml/opam2:4.09

RUN sudo apt update && sudo apt upgrade -y

RUN sudo apt install -y pkg-config m4

RUN opam update

RUN opam install -y dune ounit2

RUN sudo mkdir /app

WORKDIR /app
