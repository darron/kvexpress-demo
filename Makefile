all: build

build:
	packer build packer.json

cluster:
	cd terraform && terraform apply

destroy:
	cd terraform && terraform destroy -force
