package lib

import "hash/fnv"

type HashRing struct {
	Nodes []string
}

func NewHashRing() *HashRing {
	return &HashRing{}
}

func (hr *HashRing) AddNode(node string) {
	hr.Nodes = append(hr.Nodes, node)
}

func (hr *HashRing) GetNode(key string) string {
	h := fnv.New32a()
	h.Write([]byte(key))
	hash := h.Sum32()
	idx := hash % uint32(len(hr.Nodes))
	return hr.Nodes[idx]
}
