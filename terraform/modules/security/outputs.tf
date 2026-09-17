output "cluster_security_group_id" {
    value=aws_security_group.cluster.id
}

output "alb_security_group_id" {
    value=aws_security_group.alb.id
}

output "node_security_group_id" {
    value=aws_security_group.nodes.id
}

output "db_security_group_id" {
    value=aws_security_group.db.id
}
