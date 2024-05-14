package lib

import "sync"

type Node struct {
	ID     string
	Addr   string
	Load   int
	Status string
}

type Cluster struct {
	Nodes map[string]*Node
	mu    sync.Mutex
}

func NewCluster() *Cluster {
	return &Cluster{
		Nodes: make(map[string]*Node),
	}
}

func (c *Cluster) AddNode(id, addr string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	c.Nodes[id] = &Node{
		ID:     id,
		Addr:   addr,
		Load:   0,
		Status: "active",
	}
}

func (c *Cluster) GetNode(id string) (*Node, bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	node, exists := c.Nodes[id]
	return node, exists
}

func (c *Cluster) UpdateNodeLoad(id string, load int) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if node, exists := c.Nodes[id]; exists {
		node.Load = load
	}
}
