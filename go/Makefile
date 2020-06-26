OUTPUT := main

.PHONY: build clean

download:
	go mod download

libupdate:
	go get -u
	go mod tidy -v

lint:
	gofmt -s -w .
	goimports -w .
	go vet ./...
	go list ./... | xargs -L1 golint -set_exit_status
	golint -set_exit_status ./...

build: lint
	go build -o $(OUTPUT)

exec: build
	./$(OUTPUT) ../data/sample.go ../data/sample.go.yaml

clean:
	rm $(OUTPUT)
