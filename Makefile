
all:
	cpp -P ebony.go.typ -o ebony.go
	cpp -P basic_test.go.typ -o basic_test.go
	go test
	go install