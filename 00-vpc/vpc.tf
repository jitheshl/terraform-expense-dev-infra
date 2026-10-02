module "vpc"{
    source = "git::https://github.com/jitheshl/terraform-aws-vpc-module.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    cidr_block = var.cidr_block
    public_cidr_blocks = var.public_cidr_blocks
    private_cidr_blocks = var.private_cidr_blocks
    database_cidr_blocks = var.database_cidr_blocks
    is_peering_required = true
}