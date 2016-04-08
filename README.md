kvexpress demo
=======================

This demo was prepared for ["Running Consul at Scale—Journey from RFC to Production" at SREcon 2016 in Santa Clara, CA](https://www.usenix.org/conference/srecon16/program/presentation/froese).

Properly executed, it will spin up 3 Consul Servers and N number of Consul client nodes. These nodes will be setup with:

1. [Consul](https://www.consul.io/)
2. [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)
3. [Datadog Agent](https://github.com/DataDog/dd-agent)
4. [kvexpress](https://github.com/DataDog/kvexpress)
5. [sifter](https://github.com/darron/sifter)
6. [goshe](https://github.com/darron/goshe)
7. [Consul Template](https://github.com/hashicorp/consul-template)

All nodes will be connected to the Consul servers and a dynamically generated hosts file will be created and passed to all nodes using kvexpress.

This has been tested with 500 and 1000 client nodes successfully.

**IMPORTANT NOTE:** If you execute this demo - it will cost you money. Please don't leave your 123 nodes running any longer than you need to.

Requirements
----------------

1. [Amazon Web Services](https://aws.amazon.com/) account to run the VMs/nodes. This demo assumes that we'll be using EC2 Classic in US West 2.
2. [Datadog](https://www.datadoghq.com/) account to see the metrics generated. You can signup for a free trial [here](https://www.datadoghq.com/).
3. [Packer](https://www.packer.io/) to build the AMIs.
4. [Terraform](https://www.terraform.io/) to deploy the cluster of nodes.
5. [direnv](http://direnv.net/) to help load some environment variables.

NOTE: You can build a VM on AWS to build and deploy the cluster from. [Example script provided here](https://github.com/darron/kvexpress-demo/blob/master/ami-build/builder.sh)

Instructions
------------------

1. `cp envrc .envrc` - setup some AWS and Datadog specific API keys.
2. `cd terraform && cp variables.dist variables.tf` - setup some Terraform configuration.
3. `make build` - build and prepare the AMI with Packer.
4. Update `terraform/variables.tf` with the AMI id.
5. `make cluster` - build the entire cluster of nodes.
6. Once the first 3 nodes are created - in order to activate the hosts creation process, log into one of those three nodes and run the commands located in [hosts-activate.sh](https://github.com/darron/kvexpress-demo/blob/master/terraform/scripts/hosts-activate.sh)
7. As all the nodes are coming online, you should start seeing `kvexpress.in`, `kvexpress.out` and other [kvexpress](https://github.com/DataDog/kvexpress) related metrics flowing into datadog. Some example metrics can be seen [here](https://github.com/darron/kvexpress-demo/blob/master/example-metrics.jpg).
8. All dns queries to dnsmasq will generate `goshe.dnsmasq.queries` metrics through [goshe](https://github.com/darron/goshe).
9. Some example metrics definitions are [available here](https://gist.github.com/darron/440b42a567d4126eec0fab484a2d31b3).
10. Removing a node - just kill one or stop Consul on the node - will automatically update the dynamically generated hosts file located at `/etc/hosts.consul`. Run `sudo service consul stop` to stop Consul. Take a look at that file on all *other* nodes.
11. Every time the file changes, a diff is sent to Datadog. Take a look at [some example events](https://github.com/darron/kvexpress-demo/blob/master/kvexpress-events.jpg).
12. Make sure to destroy your cluster: `make destroy`. **PLEASE NOTE:** At larger cluster sizes - more than 200 nodes - Terraform may NOT be able to destroy your cluster cleanly because of AWS API errors. You may need to destroy your cluster using the web UI manually.
