FROM ocaml/opam2:4.09

RUN sudo apt update && sudo apt upgrade -y

RUN sudo apt install -y pkg-config m4

RUN sudo mkdir /env_create

COPY OCaml/ env_create/

RUN opam install -y env_create/

RUN sudo mkdir /app

WORKDIR /app
