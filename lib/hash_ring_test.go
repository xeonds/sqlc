package lib_test

import (
	"fmt"
	"sqlc/lib"
	"testing"
)

func TestHashRing(t *testing.T) {
	hr := lib.NewHashRing()
	hr.AddNode("node1")
	hr.AddNode("node2")

	fmt.Println("Key 'user123' maps to:", hr.GetNode("user123"))
	fmt.Println("Key 'user456' maps to:", hr.GetNode("user456"))

}
