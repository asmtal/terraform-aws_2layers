locals {
  max_subnet_length	= "${max(length(var.private_subnets))}"
  nat_gateway_count	= "${var.single_nat_gateway ? 1 : (var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length)}"
  vpc_id = "${element(
		concat(
			aws_vpc_ipv4_cidr_block_association.terraform-project.*.vpc_id,
			aws_vpc.terraform-project.*.id,
			list("")
		),
		0
	)}"
}

resource "aws_vpc" "terraform-project" {
  count = "${var.create_vpc ? 1 : 0}"
  cidr_block                       = "${var.cidr}"
  instance_tenancy                 = "${var.instance_tenancy}"
  enable_dns_hostnames             = "${var.enable_dns_hostnames}"
  enable_dns_support               = "${var.enable_dns_support}"
  tags = "${merge(
		map(
			"Name", format("%s", var.name)
		),
		var.tags,
		var.vpc_tags
	)}"
}

resource "aws_vpc_ipv4_cidr_block_association" "terraform-project" {
  count		= "${var.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0}"
  vpc_id	= "${aws_vpc.terraform-project.id}"
  cidr_block	= "${element(var.secondary_cidr_blocks, count.index)}"
}

resource "aws_vpc_dhcp_options" "terraform-project" {
  count			= "${var.create_vpc && var.enable_dhcp_options ? 1 : 0}"
  domain_name		= "${var.dhcp_options_domain_name}"
  domain_name_servers	= ["${var.dhcp_options_domain_name_servers}"]
  ntp_servers		= ["${var.dhcp_options_ntp_servers}"]
  netbios_name_servers	= ["${var.dhcp_options_netbios_name_servers}"]
  netbios_node_type	= "${var.dhcp_options_netbios_node_type}"
  tags = "${merge(
		map(
			"Name", format("%s", var.name)
		),
		var.tags,
		var.dhcp_options_tags
	)}"
}

resource "aws_vpc_dhcp_options_association" "terraform-project" {
  count			= "${var.create_vpc && var.enable_dhcp_options ? 1 : 0}"
  vpc_id		= "${local.vpc_id}"
  dhcp_options_id	= "${aws_vpc_dhcp_options.terraform-project.id}"
}

resource "aws_internet_gateway" "terraform-project" {
  count		= "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"
  vpc_id	= "${local.vpc_id}"
  tags = "${merge(
		map(
			"Name", format("%s", var.name)
		),
		var.tags,
		var.igw_tags
	)}"
}

resource "aws_route_table" "public" {
  count		= "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"
  vpc_id	= "${local.vpc_id}"
  tags = "${merge(
		map(
			"Name", format("%s-${var.public_subnet_suffix}", var.name)
		),
		var.tags,
		var.public_route_table_tags
	)}"
}

resource "aws_route" "public_internet_gateway" {
  count				= "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"
  route_table_id		= "${aws_route_table.public.id}"
  destination_cidr_block	= "0.0.0.0/0"
  gateway_id			= "${aws_internet_gateway.terraform-project.id}"
  timeouts {
    create			= "5m"
  }
}

resource "aws_route_table" "private" {
  count		= "${var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0}"
  vpc_id	= "${local.vpc_id}"
  tags		= "${merge(
			map(
				"Name", (var.single_nat_gateway ? "${var.name}-${var.private_subnet_suffix}" :
					format(
						"%s-${var.private_subnet_suffix}-%s",
						var.name,
						element(var.azs, count.index)
					)
				)
		
			),
			var.tags,
			var.private_route_table_tags
		)}"

  lifecycle {
    ignore_changes = ["propagating_vgws"]
  }
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count				= "${var.create_vpc && length(var.public_subnets) > 0 && (!var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0}"
  vpc_id			= "${local.vpc_id}"
  cidr_block			= "${element(concat(var.public_subnets, list("")), count.index)}"
  availability_zone		= "${element(var.azs, count.index)}"
  map_public_ip_on_launch	= "${var.map_public_ip_on_launch}"
  tags = "${merge(
		map(
			"Name", format(
				"%s-${var.public_subnet_suffix}-%s",
				var.name,
				element(var.azs, count.index)
			)
		),
		var.tags,
		var.public_subnet_tags
	)}"
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count			= "${var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"
  vpc_id		= "${local.vpc_id}"
  cidr_block		= "${var.private_subnets[count.index]}"
  availability_zone	= "${element(var.azs, count.index)}"
  tags = "${merge(
		map(
			"Name", format(
				"%s-${var.private_subnet_suffix}-%s",
				var.name,
				element(var.azs, count.index)
			)
		),
		var.tags,
		var.private_subnet_tags
	)}"
}

locals {
  nat_gateway_ips = "${split(
			",",
			(var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id))
		)}"
}

resource "aws_eip" "nat" {
  count	= "${var.create_vpc && (var.enable_nat_gateway && !var.reuse_nat_ips) ? local.nat_gateway_count : 0}"
  vpc	= true
  tags	= "${merge(
		map(
			"Name", format(
				"%s-%s",
				var.name,
				element(
					var.azs,
					(var.single_nat_gateway ? 0 : count.index)
				)
			)
		),
		var.tags,
		var.nat_eip_tags
	)}"
}

resource "aws_nat_gateway" "terraform-project" {
  count			= "${var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0}"
  allocation_id		= "${element(local.nat_gateway_ips, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id		= "${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"
  tags = "${merge(
		map(
			"Name", format(
				"%s-%s",
				var.name,
				element(
					var.azs,
					(var.single_nat_gateway ? 0 : count.index)
				)
			)
		),
		var.tags,
		var.nat_gateway_tags
	)}"
  depends_on		= ["aws_internet_gateway.terraform-project"]
}

resource "aws_route" "private_nat_gateway" {
  count				= "${var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0}"
  route_table_id		= "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block	= "0.0.0.0/0"
  nat_gateway_id		= "${element(aws_nat_gateway.terraform-project.*.id, count.index)}"
  timeouts {
    create			= "5m"
  }
}

resource "aws_route_table_association" "private" {
  count				= "${var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"
  subnet_id			= "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id		= "${element(aws_route_table.private.*.id, (var.single_nat_gateway ? 0 : count.index))}"
}

resource "aws_route_table_association" "public" {
  count				= "${var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"
  subnet_id			= "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id		= "${aws_route_table.public.id}"
}

resource "aws_default_vpc" "terraform-project" {
  count				= "${var.manage_default_vpc ? 1 : 0}"
  enable_dns_support		= "${var.default_vpc_enable_dns_support}"
  enable_dns_hostnames		= "${var.default_vpc_enable_dns_hostnames}"
  enable_classiclink		= "${var.default_vpc_enable_classiclink}"
  tags = "${merge(
		map(
			"Name", format(
				"%s",
				var.default_vpc_name
			)
		),
		var.tags,
		var.default_vpc_tags
	)}"
}
