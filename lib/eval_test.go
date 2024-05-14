package lib_test

import (
	"sqlc/lib"
	"testing"
)

func TestEval(t *testing.T) {
	cluster := lib.NewCluster()
	cluster.AddNode("node1", "localhost:8081")
	cluster.AddNode("node2", "localhost:8082")

	hr := lib.NewHashRing()
	hr.AddNode("node1")
	hr.AddNode("node2")

	lib.ExecuteSQL(cluster, hr, "SELECT user123")
	lib.ExecuteSQL(cluster, hr, "INSERT user456")
}
