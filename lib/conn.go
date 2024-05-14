package lib

import (
	"fmt"
	"io"
	"net/http"
)

func HandleRequest(w http.ResponseWriter, r *http.Request) {
	body, _ := io.ReadAll(r.Body)
	fmt.Fprintf(w, "Received: %s", string(body))
}

func StartNodeServer(addr string) {
	http.HandleFunc("/", HandleRequest)
	fmt.Printf("Starting server at %s\n", addr)
	http.ListenAndServe(addr, nil)
}
