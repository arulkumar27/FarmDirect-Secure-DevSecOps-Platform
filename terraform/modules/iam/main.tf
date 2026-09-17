data "aws_iam_policy_document" "eks" {
    statement {
        principals {
            type="Service"
            identifiers=["eks.amazonaws.com"]
        }

        actions=["sts:AssumeRole"]
    } 
}

resource "aws_iam_role" "cluster" {
    name="${var.name}-eks-cluster-role"
    assume_role_policy=data.aws_iam_policy_document.eks.json
    tags=var.tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
    role=aws_iam_role.cluster.name
    policy_arn="arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "node" {
    statement {
        principals {
            type="Service"
            identifiers=["ec2.amazonaws.com"]
        }

        actions=["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "node" {
    name="${var.name}-eks-node-role"
    assume_role_policy=data.aws_iam_policy_document.node.json
    tags=var.tags
}

resource "aws_iam_role_policy_attachment" "worker" {
    role=aws_iam_role.node.name
    policy_arn="arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni" {
    role=aws_iam_role.node.name
    policy_arn="arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr" {
    role=aws_iam_role.node.name
    policy_arn="arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}
