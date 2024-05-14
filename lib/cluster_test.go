package lib_test

import (
	"fmt"
	"sqlc/lib"
	"testing"
)

func TestCluster(t *testing.T) {
	cluster := lib.NewCluster()
	cluster.AddNode("node1", "localhost:8081")
	cluster.AddNode("node2", "localhost:8082")

	fmt.Println(cluster.Nodes)
}
