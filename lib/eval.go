package lib

import (
	"fmt"
	"strings"
)

func ParseSQL(query string) (string, []string) {
	parts := strings.Fields(query)
	if len(parts) < 1 {
		return "", nil
	}
	command := strings.ToUpper(parts[0])
	args := parts[1:]
	return command, args
}

func ExecuteSQL(cluster *Cluster, hr *HashRing, query string) {
	command, args := ParseSQL(query)
	switch command {
	case "SELECT":
		if len(args) < 1 {
			fmt.Println("Error: Missing table name")
			return
		}
		key := args[0]
		node := hr.GetNode(key)
		fmt.Printf("SELECT: Redirecting query to node %s\n", node)
	case "INSERT":
		if len(args) < 2 {
			fmt.Println("Error: Missing table name or key")
			return
		}
		key := args[0]
		node := hr.GetNode(key)
		fmt.Printf("INSERT: Redirecting query to node %s\n", node)
	default:
		fmt.Println("Error: Unsupported SQL command")
	}
}
