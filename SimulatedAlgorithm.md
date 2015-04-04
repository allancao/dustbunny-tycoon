# Application Specification #

Applications using the network must have the following characteristics:

  * Delay tolerant
  * Loss tolerant
  * Relatively limited packet size (say 64 kb)
  * Independent packets - ie no segmentation and reassembly
    * Could use of fountain/erasure ECCs (ex. [raptor codes](http://en.wikipedia.org/wiki/Raptor_code)). This wont be implemented but might be something to talk about in the report.

# Information From Sources #

  * We are dealing with task-oriented mobility in ferries (defn from [Message ferrying approach for data delivery](http://portal.acm.org/citation.cfm?id=989483) - this sources deals with message oriented mobility)
  * I was originally considering a scheme where nodes cluster and 'gateway nodes' (not to be confused with the gateway nodes as defined in the network entities section below) are responsible for communicating with ferries (terminology from section 6 of [Message ferrying approach for data delivery](http://portal.acm.org/citation.cfm?id=989483)). This would come in stage 2 (if at all)

## Existing Algorithms ##

  * MANET protocols (DSDV, OSLR, AODV, DSR) only work for connected subgraphs (from [Routing in a delay tolerant network](http://portal.acm.org/citation.cfm?id=1015484&dl=GUIDE&coll=GUIDE&CFID=82345016&CFTOKEN=82922258))

# Our Project #

## General Premise ##

The network contains numerous uniquely identifiable source nodes. Each source node supports a limited number of properties (in the form of key/value pairs). The network is designed to synchronize a central repository with the current key/value pair for every source node.

## Network ##

### Network Entities ###

Terminology specific to this project.

**Message**: Contains data which updates the value associated with a source node, key pair.

**Source Node** (Abbreviated src): Nodes which generate messages to be delivered to gateways. A message from any source can be delivered to any gateway.

**Message Ferry** (Abbreviated  mf): Mobile transport mechanisms for messages. Provided a delayed link to transport messages from source nodes to destination gateways.

**Gateway**: The destination for messages. Idea is that gateways connect to the internet. Once messages reach a gateway, they are routed through the internet to their final destination. **No src-src communication** (at least initially)

### Network Topology - For Simulation ###

  * Source nodes and gateways distributed randomly and evenly (#src nodes >> #gateway nodes)
  * Multiple ferries with random trajectories

## General Algorithms Considerations ##

  * Packet timeout (from [Message ferrying approach for data delivery](http://portal.acm.org/citation.cfm?id=989483))
  * Use location aware partitions and ferries? - Probably not initially. I dont think it is needed unless we do src->src communication.
  * Are we implementing a routing algorithm or a simpler delivery algorithm
    * Routing can either be 'source routing' or 'per-hop' routing (from [Routing in a delay tolerant network](http://portal.acm.org/citation.cfm?id=1015484&dl=GUIDE&coll=GUIDE&CFID=82345016&CFTOKEN=82922258))
    * Note that src->src or gateway->src requires routing and that src->gateway does not
    * _Probably just implement message delivery initially_
  * Do source nodes store messages for inter-ferry transfer (ie message path: src1 -> mf1 -> src2 -> mf2 -> gateway) - **YES**
  * Do source nodes communicate with eachother (aka, clustering) (message path: src1 -> src2 -> mf1 -> gateway) - **NO** (much more complicated problem)
  * Source nodes should communicate directly with gateways if possible (message path: src -> gateway)

## Simplifications and Assumptions ##

  * All or nothing wireless links (ie no fading - either two nodes can transmit or they cant)

## Project Roadmap ##

There are a few stages to implementing and simulating our project. I am not sure how many we will get to (doing only the first will probably be sufficient). Each stage adds features from the last. The "->" shows message transmission.

  1. **src->mf->gateway**: Basic implementation (includes src1->mf1->src2->mf2->gateway support)
  1. **src->src->mf->gateway**: Add clustering. _Should_ be fairly simple if we assume a static source node configuration. This is where mesh networking gets added.
  1. **gateway->mf->src**: Adds duplex communication. This is likely to be MUCH more complicated to do well (I cant see us getting here). A very simple implementation might be possible.

# Algorithm - Stage 1 #

Support for one way updates including:
  * src->mf->gateway
  * src1->mf1->src2->mf2->gateway

## Packets ##

Two types of packets

### Update Packet ###

Sent by the source when the value for one of its keys gets updated.

Fields:
  * **Source ID**: Globally unique for each source node.
  * **Packet timestamp**: When the message was generated. Used for throwing away old packets. Note that this is NOT when the value was changed.
  * **Copied counter**: Number of times the packet has been copied by transfer nodes
  * **Key**: What value is being updated by this packet.
  * **Key update counter**: What is the version of the value in this packet. Increments each time the source modifies the value associated with the given key. If a ferry comes across two updates for a key (specific to a single source), it chooses to keep the newest value. Also used when gateway sends ack packets.
  * **Value**: The new value (associated with the key field). This is the payload - the data associated with the packet.

### ACK Packet ###

Sent by the gateway when it receives a source update.

Fields: Same as update packet (without the value field)

## Processes ##

### Source Node Process - Sending an Update ###

When the application writes a new value for a given key:
  1. Add one to the key update counter (for that key)
  1. If possible send an update to a gateway directly
  1. Wait for a message ferry to come in range
  1. Create an update packet and send it to the ferry
  1. Wait for another ferry
    1. If the ferry is carrying an ACK, END
    1. Else, create another update packet and send it to the ferry

### Transfer Node Process Behavior ###

Transfer nodes include ferry nodes and source nodes.
  1. If ferry-src communication -> do source node behavior first.
  1. Exchange ACK packets and remove redundant updated packets in buffer.
    1. If both nodes contain the same packet but have different copied counter values, updated the fields on both packets to 1+max(pk1,pk2).
  1. Exchange update packets
  1. Decide what packets to keep based on packet dropping rules describe below

### Gateway Node Process ###

## Packet Dropping ##

Since each transfer node has limited amount of memory, not all packets can be kept. The following will be used to determine which packets to keep.

Define the following weighting function (lower is better). Sort packets by weighting and keep as many as possible.

`w(pkt) = a*(pkt age) + b*(pkt copied counter) - c*(is packet an ack?)`


General notes on this:
  * I pulled this out of my ass so considering others might be a good idea
  * Bonus for ACK packets - might want to limit the bonus based on percent of packets which are acks
  * Want to consider the size of the packet?