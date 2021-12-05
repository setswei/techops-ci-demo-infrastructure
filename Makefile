
valid:
	-terraform fmt -recursive

plan:
	-terraform plan

deploy:
	-terraform apply --auto-approve